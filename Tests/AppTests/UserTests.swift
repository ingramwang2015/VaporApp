@testable import App
import Vapor
import XCTest
import FluentPostgreSQL

final class UserTests: XCTestCase {
    
    func testUserCanBeRetrievedFromAPI() throws {
        let expectedName = "Alice"
        let expectedUsername = "alice"
        
        let revertEnvironmentArgs = ["vapor", "revert", "--all", "-y"]
        var revertConfig = Config.default()
        var revertServices = Services.default()
        var revertEnv = Environment.testing
        
        revertEnv.arguments = revertEnvironmentArgs
        
        try App.configure(&revertConfig, &revertEnv, &revertServices)
        
        let revertApp = try Application(config: revertConfig, environment: revertEnv, services: revertServices)
        try boot(revertApp)
        
        try revertApp.asyncRun().wait()
        
        let conn = try revertApp.newConnection(to: .psql).wait()
        
        let user = User(name: expectedName, username: expectedUsername)
        let savedUser = try user.save(on: conn).wait()
        
        _ = try User(name: "Luke", username: "lukes").save(on: conn).wait()
        
        let responder = try revertApp.make(Responder.self)
        
        let request = HTTPRequest(method: .GET, url: URL(string: "/api/users")!)
        let wrappedRequest = Request(http: request, using: revertApp)
        
        let reponse = try responder.respond(to: wrappedRequest).wait()
        
        let data = reponse.http.body.data
        let users = try JSONDecoder().decode([User].self, from: data!)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].name, expectedName)
        XCTAssertEqual(users[0].name, expectedUsername)
        XCTAssertEqual(users[0].id, savedUser.id)
        
        conn.close()
    }
}
