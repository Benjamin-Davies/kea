struct Line {
    var tokens: [Token]

    var indent: Int = 0
    let indentType: IndentType

    var hasNewline: Bool {
        if tokens.count <= 1 {
            return false
        }
        return tokens[0..<tokens.count - 1]
            .contains { $0.newline || $0.doubleNewline }
    }

    var minStickiness: UInt {
        if tokens.count <= 1 {
            return .max
        }
        return tokens[0..<tokens.count - 1]  // Skip the last token
            .map { $0.stickiness }
            .min() ?? .max
    }

    func length(_ indentType: IndentType) -> Int {
        struct LengthAccumulator: AppendString {
            var length: Int = 0

            mutating func append(_ string: String) {
                if string == "\t" {
                    length += 4
                } else {
                    length += string.count
                }
            }
        }

        var accumulator = LengthAccumulator()
        write(to: &accumulator)
        return accumulator.length
    }

    func write(to string: inout some AppendString) {
        for _ in 0..<indent {
            string.append(indentType.string)
        }

        var previous: Token?
        for (i, token) in tokens.enumerated() {
            if token.omitIfNotLastOnLine && i < tokens.count - 1 {
                continue
            }

            if let previous {
                if !(previous.attachRight || token.attachLeft) {
                    string.append(" ")
                }
            }

            string.append(token.text)
            previous = token
        }
    }

    func split() -> [Line] {
        var outputLines = [Line]()
        var stack = [self]

        while let line = stack.popLast() {
            let minStickiness = line.minStickiness

            let shouldSplit =
                minStickiness < UInt.max
                && (line.hasNewline || line.length(indentType) > MAX_LINE_LENGTH)

            if shouldSplit {
                let newLines = line.split(onStickiness: minStickiness)
                if newLines.count > 1 {
                    stack.append(contentsOf: newLines.reversed())
                    continue
                } else {
                    print("Split failed")
                    print(line)
                }
            }
            outputLines.append(line)

            if line.tokens.last?.doubleNewline == true {
                outputLines.append(Line(tokens: [], indent: 0, indentType: line.indentType))
            }
        }

        return outputLines
    }

    func split(onStickiness threshold: UInt) -> [Line] {
        var lines = [Line]()
        var isStartOfLine = true
        var indentStack = [IndentReason](repeating: .normal, count: indent)

        for token in tokens {
            let isEndOfLine = token.stickiness <= threshold

            if isStartOfLine && token.endIndent {
                while indentStack.last == .hanging {
                    indentStack.removeLast()
                }
                if !indentStack.isEmpty {
                    indentStack.removeLast()
                }
            }
            if isStartOfLine && token.hangingIndent && indentStack.last != .hanging {
                indentStack.append(.hanging)
            }

            if isStartOfLine {
                lines.append(
                    Line(tokens: [token], indent: indentStack.count, indentType: indentType))
            } else {
                lines[lines.count - 1].tokens.append(token)
            }

            if isEndOfLine && token.startIndent {
                indentStack.append(.normal)
            }

            isStartOfLine = isEndOfLine
        }

        return lines
    }
}

private enum IndentReason {
    case normal
    case hanging
}

protocol AppendString {
    mutating func append(_ string: String)
}

extension String: AppendString {}
