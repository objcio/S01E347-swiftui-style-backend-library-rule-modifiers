import XCTest
import Backend

struct Profile: Rule {
    var id: Int
    func rules() -> some Rule {
        "User Profile \(id)"
    }
}

struct Users: Rule {
    func rules() -> some Rule {
        PathReader { comp in
            if let id = Int(comp) {
                Profile(id: id)
            } else {
                "Not found"
            }
        }
        "User Index"
    }
}

struct Root: Rule {
    func rules() -> some Rule {
        Users().path("users")
        "Index"
    }
}

final class BackendTests: XCTestCase {
    func testUsers() async throws {
        let result0 = try await Users().run(environment: .init(request: .init(path: "/")))
        XCTAssertEqual(result0, Response(body: "User Index".toData))

        let result1 = try await Root().run(environment: .init(request: .init(path: "/")))
        XCTAssertEqual(result1, Response(body: "Index".toData))

        let result2 = try await Root().run(environment: .init(request: .init(path: "/users")))
        XCTAssertEqual(result2, Response(body: "User Index".toData))

        let result3 = try await Root().run(environment: .init(request: .init(path: "/users/1")))
        XCTAssertEqual(result3, Response(body: "User Profile 1".toData))

        let result4 = try await Root().run(environment: .init(request: .init(path: "/users/foo")))
        XCTAssertEqual(result4, Response(body: "Not found".toData))
    }
}
