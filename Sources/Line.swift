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

    var length: Int {
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
        if tokens.allSatisfy({ $0.text.isEmpty }) {
            return
        }
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
        var lines = [Line]()
        var stack = [self]
        var lastLineCount = 0

        while !stack.isEmpty {
            while let line = stack.popLast() {
                let minStickiness = line.minStickiness

                let shouldSplit =
                    minStickiness < UInt.max
                    && (line.hasNewline || line.length > MAX_LINE_LENGTH)

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
                lines.append(line)
            }
            lines = splitLopsided(lines)
            reindent(&lines, startingAt: indent)

            if lines.count > lastLineCount && lines.contains(where: { $0.length > MAX_LINE_LENGTH }) {
                // Reset and try again
                lastLineCount = lines.count
                stack = lines.reversed()
                lines = []
            }
        }

        return withBlankLines(lines)
    }

    func split(onStickiness threshold: UInt) -> [Line] {
        var lines = [Line]()
        var isStartOfLine = true

        for token in tokens {
            let isEndOfLine = token.stickiness <= threshold

            if isStartOfLine {
                lines.append(
                    Line(tokens: [token], indent: indent, indentType: indentType))
            } else {
                lines[lines.count - 1].tokens.append(token)
            }

            isStartOfLine = isEndOfLine
        }

        return lines
    }
}

fileprivate func splitLopsided(_ lines: [Line]) -> [Line] {
    var shouldSplit = Set<Int>()
    var openStack = [(Int, Bool)]()
    var index = 0
    for line in lines {
        for (i, token) in line.tokens.enumerated() {
            if token.startIndent {
                let isSplit = i == line.tokens.count - 1
                openStack.append((index, isSplit))
            }
            if token.endIndent, let (matchingIndex, matchingIsSplit) = openStack.popLast() {
                if i == 0 && !matchingIsSplit {
                    shouldSplit.insert(matchingIndex)
                }
            }
            index += 1
        }
    }
    if shouldSplit.isEmpty {
        return lines
    }

    var newLines = [Line]()
    index = 0
    for line in lines {
        var lastSplit = 0
        for (j, _) in line.tokens.enumerated() {
            if shouldSplit.contains(index) {
                let newLine = Line(
                    tokens: Array(line.tokens[lastSplit...j]),
                    indent: line.indent,
                    indentType: line.indentType)
                newLines.append(newLine)
                lastSplit = j + 1
            }
            index += 1
        }
        if lastSplit < line.tokens.count {
            newLines.append(Line(
                tokens: Array(line.tokens[lastSplit...]),
                indent: line.indent,
                indentType: line.indentType))
        }
    }

    return newLines
}

fileprivate func reindent(_ lines: inout [Line], startingAt startIndent: Int) {
    var depth = 0
    var stack = [Indent](repeating: .normal(depth), count: startIndent)
    for (i, line) in lines.enumerated() {
        if line.tokens.isEmpty {
            continue
        }

        if let token = line.tokens.first {
            if token.startIndent {
                depth += 1
            }
            if token.endIndent {
                depth -= 1
            }
        }
        while !stack.isEmpty && stack.last!.depth > depth {
            stack.removeLast()
        }

        if line.tokens.first?.hangingIndent == true {
            if stack.last?.reason != .hanging {
                stack.append(.hanging(depth))
            }
        } else if line.tokens.first?.doubleHangingIndent == true {
            if stack.last?.reason != .hanging {
                stack.append(.hanging(depth))
                stack.append(.hanging(depth))
            }
        } else {
            while stack.last?.reason == .hanging {
                stack.removeLast()
            }
        }

        lines[i].indent = stack.count

        // Consider all start- and end-indents when calculating depth
        // (we already considered the first token above)
        for token in line.tokens[1...] {
            if token.startIndent {
                depth += 1
            }
            if token.endIndent {
                depth -= 1
            }
        }
        // But only consider the last token when deciding whether to indent
        if line.tokens.last?.startIndent == true {
            stack.append(.normal(depth))
        }
    }
}

fileprivate struct Indent {
    let depth: Int
    let reason: IndentReason

    static func normal(_ depth: Int) -> Indent {
        Indent(depth: depth, reason: .normal)
    }

    static func hanging(_ depth: Int) -> Indent {
        Indent(depth: depth, reason: .hanging)
    }
}

fileprivate enum IndentReason {
    case normal
    case hanging
}

fileprivate func withBlankLines(_ lines: [Line]) -> [Line] {
    var result = [Line]()
    for line in lines {
        if result.last?.tokens.last?.doubleNewline == true {
            result.append(Line(tokens: [], indentType: result.last!.indentType))
        }
        result.append(line)
    }
    return result
}

protocol AppendString {
    mutating func append(_ string: String)
}

extension String: AppendString {}
