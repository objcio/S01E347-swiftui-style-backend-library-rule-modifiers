public protocol RuleModifier {
    associatedtype Result: Rule
    func rules(_ content: Content) -> Result
}

public struct Content: Rule, BuiltinRule {
    private var rule: any Rule

    public init<R: Rule>(rule: R) {
        self.rule = rule
    }

    func execute(environment: EnvironmentValues) async throws -> Response? {
        try await rule.run(environment: environment)
    }
}

struct Modified<R: Rule, M: RuleModifier>: Rule, BuiltinRule {
    var content: R
    var modifier: M

    func execute(environment: EnvironmentValues) async throws -> Response? {
        install(environment: environment, on: modifier)
        return try await modifier
            .rules(.init(rule: content))
            .run(environment: environment)
    }

}

extension Rule {
    public func modifier<M: RuleModifier>(_ modifier: M) -> some Rule {
        Modified(content: self, modifier: modifier)
    }
}
