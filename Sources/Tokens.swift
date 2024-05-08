import Collections
import Foundation

struct Token {
    let location: SourceLocation
    let kind: TokenKind
}

enum TokenKind {
    case identifier(Substring)
}

struct Tokens {
    var source: Source
    var scannedTokens = Deque<Token>()

    init(_ source: Source) {
        self.source = source
    }

    private mutating func traverseWhitespaceAndComments() ->
        (hasWhitespace: Bool, hasNewline: Bool)
    {
        var hasWhitespace = false
        var hasNewline = false
        while let character = source.content.first {
            if source.content.starts(with: "//") {
                let end = source.content.firstIndex { $0.isNewline } ?? source.content.endIndex
                source.advance(to: end)
            } else if character.isWhitespace {
                source.advance()

                hasWhitespace = true
                if character.isNewline {
                    hasNewline = true
                }   
            } else {
                break
            }
        }

        return (hasWhitespace, hasNewline)
    }

    private func isIdentifierHead(_ character: Character) -> Bool {
        return character.isLetter || character == "_"
    }

    private func isIdentifierCharacter(_ character: Character) -> Bool {
        return isIdentifierHead(character) || character.isNumber
    }

    private mutating func advance() throws {
        let _ = traverseWhitespaceAndComments()

        let start = self.source.location
        guard let character = source.content.first else { return }
        switch character {
            case _ where isIdentifierHead(character):
                let end = source
                    .content
                    .firstIndex { !isIdentifierCharacter($0) }
                    ?? source.content.endIndex
                let content = source.content.prefix(upTo: end)

                source.advance(to: end)
                scannedTokens.append(Token(location: start, kind: .identifier(content)))
            default:
                throw LexicalError.unknownToken(source)
        }
    }

    mutating func consume() throws -> Token {
        if scannedTokens.isEmpty { try advance() }

        if let token = scannedTokens.popFirst() {
            return token
        } else {
            throw LexicalError.unexpectedEOF
        }
    }

    mutating func isEOF() throws -> Bool {
        if scannedTokens.isEmpty { try advance() }

        return scannedTokens.isEmpty
    }
}

enum LexicalError: Error {
    case unexpectedEOF
    case unknownToken(Source)
}
