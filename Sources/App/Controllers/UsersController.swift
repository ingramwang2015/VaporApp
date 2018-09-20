import Vapor
import Fluent

struct UsersController: RouteCollection {
    
    func boot(router: Router) throws {
        let usersRouter = router.grouped("api", "users")
        usersRouter.post(User.self, use: createHandle)
        usersRouter.get(use: getAllHandle)
        usersRouter.get(User.parameter, use: getHandle)
        usersRouter.get(User.parameter, "acronyms", use: getAcronymsHandle)
    }
    
    func getAcronymsHandle(_ req: Request) throws -> Future<[Acronym]> {
        return try req.parameters.next(User.self).flatMap(to: [Acronym].self) { user in
            try user.acronym.query(on: req).all()
        }
    }
    
    func createHandle(_ req: Request, user: User) throws -> Future<User> {
        return user.save(on: req)
    }
    
    func getAllHandle(_ req: Request) throws -> Future<[User]> {
        return User.query(on: req).all()
    }
    
    func getHandle(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(User.self)
    }
    
}


