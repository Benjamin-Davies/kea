import SwiftOperators
import SwiftSyntax

func preprocess(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    return try! SourceFileSyntax(OperatorTable.standardOperators.foldAll(syntax))!
}
