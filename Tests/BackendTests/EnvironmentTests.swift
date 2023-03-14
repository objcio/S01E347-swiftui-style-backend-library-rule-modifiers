import XCTest
import Backend

struct GreetingKey: EnvironmentKey {
    static var defaultValue: String = "Hello"
}

extension EnvironmentValues {
    var greeting: String {
        get { self[GreetingKey.self] }
        set { self[GreetingKey.self] = newValue }
    }
}

struct Greeting: Rule {
    @Environment(\.greeting) var greeting
    func rules() -> some Rule {
        greeting
    }
}

struct Home: Rule {
    func rules() -> some Rule {
        Greeting().path("greeting")
    }
}

struct RuleModifierTest: RuleModifier {
    @Environment(\.greeting) var greeting

    func rules(_ content: Content) -> some Rule {
        content.environment(\.greeting, "\(greeting) extended")
    }
}

final class EnvironmentTests: XCTestCase {
    func testUsers() async throws {
        let r0 = try await Greeting().run(environment: .init(request: .init(path: "/")))
        XCTAssertEqual(r0, Response(body: "Hello".toData))

        let rule = Greeting().environment(\.greeting, "Overridden")
        let r1 = try await rule.run(environment: .init(request: .init(path: "/")))
        XCTAssertEqual(r1, Response(body: "Overridden".toData))

        let rule2 = Home().environment(\.greeting, "Overridden")
        let r2 = try await rule2.run(environment: .init(request: .init(path: "/greeting")))
        XCTAssertEqual(r2, Response(body: "Overridden".toData))

    }

    func testRuleModifier() async throws {
        let rule = Greeting()
            .modifier(RuleModifierTest())
            .environment(\.greeting, "Good day")
        let r1 = try await rule.run(environment: .init(request: .init(path: "/")))
        XCTAssertEqual(r1, Response(body: "Good day extended".toData))

    }
}
