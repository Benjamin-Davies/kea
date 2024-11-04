struct Line {
    var tokens: [Token]

    var minStickiness: UInt {
        return tokens[0..<tokens.count - 1] // Skip the last token
            .map { $0.stickiness }
            .min() ?? .max
    }

    var length: Int {
        struct LengthAccumulator: AppendString {
            var length: Int = 0

            mutating func append(_ string: String) {
                length += string.count
            }
        }

        var accumulator = LengthAccumulator()
        write(to: &accumulator)
        return accumulator.length
    }

    func write(to string: inout some AppendString) {
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
                && (minStickiness == 0 || line.length > MAX_LINE_LENGTH)

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
        }

        return outputLines
    }

    func split(onStickiness stickiness: UInt) -> [Line] {
        var lines = [Line]()
        var isStartOfLine = true

        for token in tokens {
            let isEndOfLine = token.stickiness <= stickiness

            if isStartOfLine {
                lines.append(Line(tokens: [token]))
            } else {
                lines[lines.count - 1].tokens.append(token)
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
