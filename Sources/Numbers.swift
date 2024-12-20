import SwiftSyntax

func numbers(_ syntax: SourceFileSyntax) -> SourceFileSyntax {
    return NumberRewriter().visit(syntax)
}

private class NumberRewriter: SyntaxRewriter {
    override func visit(_ node: FloatLiteralExprSyntax) -> ExprSyntax {
        var newNode = node
        newNode.literal = .floatLiteral(
            formatFloat(node.literal.text),
            leadingTrivia: node.literal.leadingTrivia,
            trailingTrivia: node.literal.trailingTrivia,
            presence: node.literal.presence)
        return ExprSyntax(newNode)
    }

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

private func formatFloat(_ text: String) -> String {
    let simplified =
        text
        .replacingOccurrences(of: "_", with: "")
        .replacingOccurrences(of: "+", with: "")

    if simplified.starts(with: "0x") {
        return HexFloat(simplified).toString()
    } else {
        return DecimalFloat(simplified).toString()
    }
}

private func formatInteger(_ text: String) -> String {
    let simplified =
        text
        .replacingOccurrences(of: "_", with: "")
        .replacingOccurrences(of: "+", with: "")

    switch simplified {
    case _ where simplified.hasPrefix("0b"):
        let stripped = String(simplified.dropFirst(2)).strippingLeadingZeroes()
        let targetCount =
            if stripped.count <= 4 {
                4
            } else {
                stripped.count.roundedUp(toMultipleOf: 8)
            }
        return "0b" + stripped.zeroPadding(until: targetCount).withUnderscores(every: 4)
    case _ where simplified.hasPrefix("0o"):
        let stripped = String(simplified.dropFirst(2)).strippingLeadingZeroes()
        let targetCount =
            if stripped.count <= 1 {
                1
            } else if stripped.count <= 2 {
                2
            } else {
                stripped.count.roundedUp(toMultipleOf: 3)
            }
        return "0o" + stripped.zeroPadding(until: targetCount).withUnderscores(every: 3)
    case _ where simplified.hasPrefix("0x"):
        let stripped = String(simplified.dropFirst(2)).strippingLeadingZeroes()
        let targetCount =
            if stripped.count <= 1 {
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

/// Value = 0.significand * 10^exponent
struct DecimalFloat {
    let significand: String
    let exponent: Int

    init(_ input: String) {
        let parts = input.split(separator: "e")
        var significand = String(parts[0])
        var exponent = if parts.count == 2 { Int(parts[1])! } else { 0 }

        if let index = significand.firstIndex(of: ".") {
            exponent += significand.distance(from: significand.startIndex, to: index)
            significand.remove(at: index)
        } else {
            exponent += significand.count
        }

        let beforeCount = significand.count
        significand = significand.strippingLeadingZeroes()
        let afterCount = significand.count
        exponent -= beforeCount - afterCount

        significand = significand.strippingTrailingZeroes()

        if significand.isEmpty {
            significand = "0"
            exponent = 0
        }

        self.significand = significand
        self.exponent = exponent
    }

    func toString() -> String {
        if self.exponent <= 9 && self.exponent > -3 {
            self.toFixedPointString()
        } else {
            self.toScientificString()
        }
    }

    func toFixedPointString() -> String {
        if self.exponent <= 0 {
            let fractionalPart = String(repeating: "0", count: -self.exponent) + self.significand
            return "0." + fractionalPart.withUnderscores(every: 3, leftAlign: true)
        } else {
            var significand = self.significand
            if significand.count < self.exponent {
                significand =
                    significand + String(repeating: "0", count: self.exponent - significand.count)
            }

            let wholePart = String(significand.prefix(self.exponent))
            let fractionalPart = String(significand.dropFirst(self.exponent))

            var result = wholePart.withUnderscores(every: 3)
            if fractionalPart.isEmpty {
                result += ".0"
            } else {
                result += "." + fractionalPart.withUnderscores(every: 3, leftAlign: true)
            }
            return result
        }
    }

    func toScientificString() -> String {
        let wholePart = String(self.significand.prefix(1))
        let fractionalPart = String(self.significand.dropFirst())
        let exponent = String(self.exponent - 1)

        var result = wholePart.withUnderscores(every: 3)
        if !fractionalPart.isEmpty {
            result += "." + fractionalPart.withUnderscores(every: 3, leftAlign: true)
        }
        result += "e" + exponent
        return result
    }
}

/// Value = 0.significandBits * 2^exponent
struct HexFloat {
    let significandBits: [Bool]
    let exponent: Int

    init(_ input: String) {
        let parts = input.trimmingPrefix("0x").split(separator: "p")
        var significand = String(parts[0])
        var exponent = Int(parts[1])!

        if let index = significand.firstIndex(of: ".") {
            exponent += 4 * significand.distance(from: significand.startIndex, to: index)
            significand.remove(at: index)
        } else {
            exponent += 4 * significand.count
        }

        var significandBits = [Bool]()
        for char in significand {
            let value = Int(String(char), radix: 16)!
            for i in 0..<4 {
                significandBits.append((value & (8 >> i)) != 0)
            }
        }

        let beforeCount = significandBits.count
        significandBits = Array(significandBits.drop { $0 == false })
        let afterCount = significandBits.count
        exponent -= beforeCount - afterCount

        significandBits = significandBits.reversed().drop { $0 == false }.reversed()

        if significandBits.isEmpty {
            exponent = 0
        }

        self.significandBits = significandBits
        self.exponent = exponent
    }

    func toString() -> String {
        if significandBits.isEmpty {
            return "0x0p0"
        }

        var fractionalPartBits = Array(significandBits.dropFirst())
        while fractionalPartBits.count % 16 != 0 {
            fractionalPartBits.append(false)
        }

        var fractionalPart = String()
        for i in 0..<fractionalPartBits.count / 4 {
            var nibble = 0
            for j in 0..<4 {
                if fractionalPartBits[4 * i + j] {
                    nibble |= 8 >> j
                }
            }
            fractionalPart += String(format: "%1x", nibble)
        }

        var result = "0x1"
        if !fractionalPart.isEmpty {
            result += "." + fractionalPart.withUnderscores(every: 4, leftAlign: true)
        }
        result += "p" + String(exponent - 1)
        return result
    }
}

extension String {
    fileprivate func strippingLeadingZeroes() -> String {
        for (i, char) in self.enumerated() {
            if char != "0" {
                var newText = self
                newText.removeFirst(i)
                return newText
            }
        }
        return self
    }

    fileprivate func strippingTrailingZeroes() -> String {
        for (i, char) in self.reversed().enumerated() {
            if char != "0" {
                var newText = self
                newText.removeLast(i)
                return newText
            }
        }
        return self
    }

    fileprivate func zeroPadding(until count: Int) -> String {
        if self.count < count {
            return String(repeating: "0", count: count - self.count) + self
        } else {
            return self
        }
    }

    fileprivate func withUnderscores(every interval: Int, leftAlign: Bool = false) -> String {
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
            if remaining.count > interval {
                remaining.removeFirst(interval)
            } else {
                remaining.removeAll()
            }
        }
        return String(result)
    }
}

extension Int {
    fileprivate func roundedUp(toMultipleOf multiple: Int) -> Int {
        let remainder = self % multiple
        if remainder == 0 {
            return self
        } else {
            return self + multiple - remainder
        }
    }
}
