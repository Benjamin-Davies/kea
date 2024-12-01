import SwiftSyntax

let MAX_LINE_LENGTH = 100

public func format(_ syntax: SourceFileSyntax, rearrange: Bool) -> String {
    let indentType = detectIndentType(syntax)

    let preprocessed = preprocess(syntax, rearrange: rearrange)
    let exceptions = markExceptions(preprocessed)

    let tokens = tokens(preprocessed, exceptions: exceptions)
    let lines = Line(tokens: tokens, indentType: indentType).split()

    var output = ""
    for line in lines {
        line.write(to: &output)
        output.append("\n")
    }

    return output
}
