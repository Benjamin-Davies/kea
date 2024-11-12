import SwiftSyntax
import SwiftOperators

func preprocess(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    return try! SourceFileSyntax(OperatorTable.standardOperators.foldAll(syntax))!
}
