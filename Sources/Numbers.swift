import SwiftSyntax

func numbers(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    return NumberRewriter().visit(syntax)
}

private class NumberRewriter: SyntaxRewriter {
    override func visit(_ node: IntegerLiteralExprSyntax) -> ExprSyntax {
        var newNode = node
        newNode.literal = .integerLiteral(
            formatInteger(node.literal.text),
            leadingTrivia: node.literal.leadingTrivia,
            trailingTrivia: node.literal.trailingTrivia,
            presence: node.literal.presence)
        return ExprSyntax(newNode)
    }
}

public func formatInteger(_ text: String) -> String {
    let simplified = text
        .replacingOccurrences(of: "_", with: "")
        .replacingOccurrences(of: "+", with: "")

    switch simplified {
    case _ where simplified.hasPrefix("0b"):
        let stripped = String(simplified.dropFirst(2)).strippingLeadingZeroes()
        let targetCount = if stripped.count <= 4 {
            4
        } else {
            stripped.count.roundedUp(toMultipleOf: 8)
        }
        return "0b" + stripped.zeroPadding(until: targetCount).withUnderscores(every: 4)
    case _ where simplified.hasPrefix("0o"):
        let stripped = String(simplified.dropFirst(2)).strippingLeadingZeroes()
        let targetCount = if stripped.count <= 1 {
            1
        } else {
            stripped.count.roundedUp(toMultipleOf: 3)
        }
        return "0o" + stripped.zeroPadding(until: targetCount).withUnderscores(every: 3)
    case _ where simplified.hasPrefix("0x"):
        let stripped = String(simplified.dropFirst(2)).strippingLeadingZeroes()
        let targetCount = if stripped.count <= 1 {
            1
        } else if stripped.count <= 2 {
            2
        } else {
            stripped.count.roundedUp(toMultipleOf: 4)
        }
        return "0x" + stripped.zeroPadding(until: targetCount).withUnderscores(every: 4)
    default:
        let stripped = simplified.strippingLeadingZeroes()
        var newText = stripped.zeroPadding(until: 0)
        if text.count > 4 {
            newText = newText.withUnderscores(every: 3)
        }
        return newText
    }
}

fileprivate extension String {
    func strippingLeadingZeroes() -> String {
        for (i, char) in self.enumerated() {
            if char != "0" {
                var newText = self
                newText.removeFirst(i)
                return newText
            }
        }
        return self
    }

    func zeroPadding(until count: Int) -> String {
        if self.count < count {
            return String(repeating: "0", count: count - self.count) + self
        } else {
            return self
        }
    }

    func withUnderscores(every interval: Int, leftAlign: Bool = false) -> String {
        if self.count <= interval {
            return self
        }

        var remaining = [Character](self)
        var result = [Character]()
        if !leftAlign && remaining.count % interval > 0 {
            let n = remaining.count % interval
            result.append(contentsOf: remaining.prefix(upTo: n))
            remaining.removeFirst(n)
        }
        while !remaining.isEmpty {
            if !result.isEmpty {
                result.append(contentsOf: "_")
            }
            result.append(contentsOf: remaining.prefix(interval))
            remaining.removeFirst(interval)
        }
        return String(result)
    }
}

fileprivate extension Int {
    func roundedUp(toMultipleOf multiple: Int) -> Int {
        let remainder = self % multiple
        if remainder == 0 {
            return self
        } else {
            return self + multiple - remainder
        }
    }
}
