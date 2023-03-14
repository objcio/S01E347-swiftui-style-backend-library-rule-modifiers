import Foundation

@resultBuilder
public struct RuleBuilder {
    public static func buildPartialBlock<R: Rule>(first: R) -> some Rule {
        first
    }

    public static func buildPartialBlock<D: ToData>(first: D) -> some Rule {
        Response(body: first.toData)
    }

    public static func buildPartialBlock<R0: Rule, R1: Rule>(accumulated: R0, next: R1) -> some Rule {
        RulePair(r0: accumulated, r1: next)
    }

    public static func buildPartialBlock<R0: Rule, R1: ToData>(accumulated: R0, next: R1) -> some Rule {
        RulePair(r0: accumulated, r1: Response(body: next.toData))
    }

    public static func buildEither<R0: Rule, R1: Rule>(first component: R0) -> Either<R0, R1> {
        Either<R0, R1>.left(component)
    }

    public static func buildEither<R0: Rule, R1: Rule>(second component: R1) -> Either<R0, R1> {
        Either<R0, R1>.right(component)
    }

    public static func buildOptional<R: Rule>(_ component: R?) -> R? {
        return component
    }
}

extension Optional: Rule, BuiltinRule where Wrapped: Rule {
    func execute(environment: EnvironmentValues) async throws -> Response? {
        try await self?.run(environment: environment)
    }
}

public enum Either<R0: Rule, R1: Rule>: BuiltinRule, Rule {
    case left(R0)
    case right(R1)

    func execute(environment: EnvironmentValues) async throws -> Response? {
        switch self {
        case .left(let r): return try await r.run(environment: environment)
        case .right(let r): return try await r.run(environment: environment)
        }
    }
}

struct RulePair<R0: Rule, R1: Rule>: BuiltinRule, Rule {
    var r0: R0
    var r1: R1
    func execute(environment: EnvironmentValues) async throws -> Response? {
        if let r = try await r0.run(environment: environment) {
            return r
        }
        return try await r1.run(environment: environment)
    }
}
