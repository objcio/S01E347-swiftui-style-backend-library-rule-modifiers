import Foundation

public protocol EnvironmentKey {
    associatedtype Value
    static var defaultValue: Value { get }
}

public struct EnvironmentValues {
    public var request: Request
    public var remainingPath: [String]
    public var userDefined: [ObjectIdentifier: Any] = [:]

    public init(request: Request) {
        self.request = request
        assert(request.path.first == "/")
        remainingPath = (request.path as NSString).pathComponents
        assert(remainingPath.first == "/")
        remainingPath.removeFirst()
        userDefined = [:]
    }

    public subscript<Key: EnvironmentKey>(key: Key.Type = Key.self) -> Key.Value {
        get { (userDefined[ObjectIdentifier(key)] as? Key.Value) ?? Key.defaultValue }
        set { userDefined[ObjectIdentifier(key)] = newValue }
    }
}

struct EnvironmentWriter<Value, Content: Rule>: BuiltinRule, Rule {
    var keyPath: WritableKeyPath<EnvironmentValues, Value>
    var value: Value
    var content: Content

    func execute(environment: EnvironmentValues) async throws -> Response? {
        var copy = environment
        copy[keyPath: keyPath] = value
        return try await content.run(environment: copy)
    }
}

extension Rule {
    public func environment<Value>(_ keyPath: WritableKeyPath<EnvironmentValues, Value>, _ value: Value) -> some Rule {
        EnvironmentWriter(keyPath: keyPath, value: value, content: self)
    }
}

final class Box<A> {
    var value: A
    init(value: A) {
        self.value = value
    }
}

@propertyWrapper
public struct Environment<Value>: DynamicProperty {
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    var keyPath: KeyPath<EnvironmentValues, Value>
    var box: Box<EnvironmentValues?> = Box(value: nil)

    func install(_ env: EnvironmentValues) {
        box.value = env
    }

    public var wrappedValue: Value {
        guard let env = box.value else {
            fatalError("Using the environment outside of the rules")
        }
        return env[keyPath: keyPath]
    }
}

protocol DynamicProperty {
    func install(_ env: EnvironmentValues)
}
