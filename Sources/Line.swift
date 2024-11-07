struct Line {
    var tokens: [Token]

    var indent: Int = 0
    let indentType: IndentType

    var minStickiness: UInt {
        if tokens.count <= 1 {
            return .max
        }
        return tokens[0..<tokens.count - 1] // Skip the last token
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

        for (i, token) in tokens.enumerated() {
            if i > 0 {
                let previous = tokens[i - 1]
                if !(previous.attachRight || token.attachLeft) {
                    string.append(" ")
                }
            }

            string.append(token.text)
        }
    }

    func split() -> [Line] {
        var outputLines = [Line]()
        var stack = [self]

        while let line = stack.popLast() {
            let minStickiness = line.minStickiness

            let shouldSplit = minStickiness >= 0
                && (minStickiness == 0 || line.length(indentType) > MAX_LINE_LENGTH)

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

    func split(onStickiness stickiness: UInt) -> [Line] {
        var lines = [Line]()
        var isStartOfLine = true
        var indent = self.indent

        for token in tokens {
            let isEndOfLine = token.stickiness <= stickiness || token.doubleNewline

            if isStartOfLine && token.endIndent {
                indent -= 1
                if indent < 0 {
                    print("Indent is negative")
                    indent = 0
                }
            }

            if isStartOfLine {
                lines.append(Line(tokens: [token], indent: indent, indentType: indentType))
            } else {
                lines[lines.count - 1].tokens.append(token)
            }

            if isEndOfLine && token.startIndent {
                indent += 1
            }

            isStartOfLine = isEndOfLine
        }

        return lines
    }
}

protocol AppendString {
    mutating func append(_ string: String)
}

extension String: AppendString {}
