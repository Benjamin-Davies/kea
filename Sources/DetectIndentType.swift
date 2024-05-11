import SwiftSyntax

enum IndentType {
    case twoSpaces
    case fourSpaces
    case tab
}

func detectIndentType(_ syntax: SourceFileSyntax) -> IndentType {
    let visitor = IndentVisitor()
    visitor.walk(syntax)
    return visitor.indentType ?? .tab
}

fileprivate class IndentVisitor: SyntaxVisitor {
    var isNewline = true
    var indentType: IndentType?

    init() {
        super.init(viewMode: .sourceAccurate)
    }

    func visit(_ trivia: Trivia) {
        for piece in trivia {
            if indentType != nil {
                return
            }
            switch piece {
            case .spaces(let count):
                if isNewline {
                    if count == 2 {
                        indentType = .twoSpaces
                    } else if count == 4 {
                        indentType = .fourSpaces
                    }
                }
            case .tabs:
                if isNewline {
                    indentType = .tab
                }
            default:
                break
            }
            isNewline = piece.isNewline
        }
    }
    
    override func visit(_ node: TokenSyntax) -> SyntaxVisitorContinueKind {
        if indentType != nil {
            return .skipChildren
        }
        
        visit(node.leadingTrivia)
        isNewline = false
        visit(node.trailingTrivia)
        
        return .skipChildren
    }
}
