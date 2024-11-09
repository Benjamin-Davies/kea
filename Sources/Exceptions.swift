import SwiftSyntax

func markExceptions(_ syntax: some SyntaxProtocol) -> Exceptions {
    let exceptions = Exceptions()
    exceptions.walk(syntax)
    return exceptions
}

class Exceptions: SyntaxVisitor {
    var hangingLists: Set<LabeledExprListSyntax> = []

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        hangingLists.insert(node.arguments)
        return .visitChildren
    }

    override func visit(_ node: InitializerClauseSyntax) -> SyntaxVisitorContinueKind {
        walk(node.value)
        if let expr = FunctionCallExprSyntax(node.value) {
            hangingLists.remove(expr.arguments)
        }

        return .skipChildren
    }
}
