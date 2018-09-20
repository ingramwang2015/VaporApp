import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    func boot(router: Router) throws {
        
        let acronymsRoutes = router.grouped("api", "acronyms")
        acronymsRoutes.get(use: getAllHandle)
        acronymsRoutes.post(Acronym.self, use: createHandle)
        acronymsRoutes.get(Acronym.parameter, use: getHandle)
        acronymsRoutes.put(Acronym.parameter, use: updateHandle)
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandle)
        acronymsRoutes.get("search", use: searchHandle)
        acronymsRoutes.get("first", use: getFirstHandle)
        acronymsRoutes.get("sort", use: sortHandle)
        acronymsRoutes.get(Acronym.parameter ,"user", use: getUserHandle)
        acronymsRoutes.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandle)
        acronymsRoutes.get(Acronym.parameter, "categories", use: getCategoriesHandle)
    }
    
    func getCategoriesHandle(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
            try acronym.categories.query(on: req).all()
        }
    }
    
    func addCategoriesHandle(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { acronym, category in
            let povit = try AcronymCategoryPivot(acronym.requireID(), category.requireID())
            return povit.save(on: req).transform(to: .created)
        }
    }
    
    func getUserHandle(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
            acronym.user.get(on: req)
        }
    }
    
    func createHandle(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
        return acronym.save(on: req)
    }
    
    func getHandle(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func updateHandle(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self)) { acronym, updateAcronym in
            acronym.short = updateAcronym.short
            acronym.long = updateAcronym.long
            acronym.userID = updateAcronym.userID
            return acronym.save(on: req)
        }
    }

    func deleteHandle(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters
            .next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    func searchHandle(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at:"term"] else {
            throw Abort(.badRequest)
        }
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
        }.all()
    }
    
    func getFirstHandle(_ req: Request) throws -> Future<Acronym> {
        return Acronym.query(on: req).first().map(to: Acronym.self) { acronym in
            guard let acronym = acronym else {
                throw Abort(.notFound)
            }
            return acronym
        }
    }

    func sortHandle(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).sort(\.short, .ascending).all()
    }
    
    func getAllHandle(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
}
