import SwiftSyntax

extension Trivia {
    mutating func ensureWhitespace() {
        if !self.contains(where: { $0.isWhitespace }) {
            var pieces = Array(pieces)
            pieces.append(.spaces(1))
            self = Trivia(pieces: pieces)
        }
    }

    mutating func ensureNewline() {
        if !self.contains(where: { $0.isNewline }) {
            var pieces = pieces
            while let last = pieces.last, last.isWhitespace {
                pieces.removeLast()
            }
            pieces.append(.newlines(1))
            self = Trivia(pieces: pieces)
        }
    }
}
