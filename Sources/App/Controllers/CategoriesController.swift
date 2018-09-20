import Vapor

struct CategoriesController: RouteCollection {
    
    func boot(router: Router) throws {
        let categoriesRouter = router.grouped("api", "categories")
        categoriesRouter.post(Category.self, use: createHandle)
        categoriesRouter.get(use: getAllHandle)
        categoriesRouter.get(Category.parameter, use: getHandle)
        categoriesRouter.get(Category.parameter, "acronyms", use: getAcronymsHandle)
    }
    
    func getAcronymsHandle(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(Category.self).flatMap(to: [Acronym].self) { category in
            try category.acronyms.query(on: req).all()
        }
    }
    
    func createHandle(_ req: Request, category: Category) throws -> Future<Category> {
        return category.save(on: req)
    }
    
    func getAllHandle(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    func getHandle(_ req: Request) throws -> Future<Category> {
        return try req.parameters.next(Category.self)
    }
    
}
