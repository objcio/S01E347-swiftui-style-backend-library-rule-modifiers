import Foundation

extension Rule {
    public func path(_ component: String) -> some Rule {
        modifier(Path(expectedPathComponent: component))
    }
}

struct Path: RuleModifier {
    var expectedPathComponent: String

    func rules(_ content: Content) -> some Rule {
        PathReader { comp in
            if comp == expectedPathComponent {
                content
            }
        }
    }
}
