import FluentPostgreSQL
import Foundation

final class AcronymCategoryPivot: PostgreSQLUUIDPivot {    
    
    var id: UUID?

    typealias Left = Acronym
    typealias Right = Category
    
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    static let leftIDKey: LeftIDKey = \.acronymID
    static let rightIDKey: RightIDKey = \.categoryID

    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

extension AcronymCategoryPivot: Migration {
    static func prepare(on connection: PostgreSQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.acronymID, to: \Acronym.id)
            builder.reference(from: \.categoryID, to: \Category.id)
        }
    }
}
