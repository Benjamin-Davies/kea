import SwiftSyntax

let MAX_LINE_LENGTH = 100

public func format(_ syntax: SourceFileSyntax) -> String {
    let indentType = detectIndentType(syntax)

    let lines = Line(tokens: syntax.tokens, indentType: indentType).split()

    var output = ""
    for line in lines {
        line.write(to: &output)
        output.append("\n")
    }

    return output
}
