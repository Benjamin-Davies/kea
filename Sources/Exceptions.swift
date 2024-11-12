import SwiftSyntax

func markExceptions(_ syntax: some SyntaxProtocol) -> Exceptions {
    let exceptions = Exceptions()
    exceptions.walk(syntax)
    return exceptions
}

class Exceptions: SyntaxVisitor {
    var hangingLists: Set<LabeledExprListSyntax> = []
    var singleLineItemLists: Set<CodeBlockItemListSyntax> = []

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
        if node.statements.count <= 1 && node.statements.first?.item.isSimple ?? true {
            singleLineItemLists.insert(node.statements)
        }
        return .visitChildren
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

fileprivate extension CodeBlockItemSyntax.Item {
    var isSimple: Bool {
        switch self {
        case let .stmt(stmt):
            return stmt.isSimple
        case let .expr(expr):
            return expr.isSimple
        default:
            return false
        }
    }
}

fileprivate extension StmtSyntax {
    var isSimple: Bool {
        if let returnStmt = ReturnStmtSyntax(self) {
            return returnStmt.expression?.isSimple ?? true
        } else {
            return false
        }
    }
}

fileprivate extension ExprSyntax {
    var isSimple: Bool {
        return !isAssignment
    }

    var isAssignment: Bool {
        guard let infixExpr = InfixOperatorExprSyntax(self) else {
            return false
        }
        if AssignmentExprSyntax(infixExpr.operator) != nil {
            return true
        } else if let op = BinaryOperatorExprSyntax(infixExpr.operator) {
            return op.operator.text.last == "="
                && !["==", ">=", "<="].contains(op.operator.text)
        } else {
            return false
        }
    }
}
