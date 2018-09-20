import Vapor

struct CategoriesController: RouteCollection {
    
    func boot(router: Router) throws {
        let categoriesRouter = router.grouped("api", "categories")
        categoriesRouter.post(Category.self, use: createHandle)
        categoriesRouter.get(use: getAllHandle)
    }
    
}

func createHandle(_ req: Request, category: Category) throws -> Future<Category> {
    return category.save(on: req)
}

func getAllHandle(_ req: Request) throws -> Future<[Category]> {
    return Category.query(on: req).all()
}

func getHandle(<#parameters#>) -> <#return type#> {
    <#function body#>
}
