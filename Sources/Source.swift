import Foundation

struct Source {
    var location: SourceLocation
    var content: Substring

    init(contentsOfFile path: String) throws {
        let content = try String(contentsOfFile: path)
        self.location = SourceLocation(startOfFile: path)
        self.content = Substring(content)
    }

    mutating func advance(to index: String.Index) {
        while content.startIndex < index {
            advance()
        }
    }

    mutating func advance() {
        let character = content.removeFirst()
        location.advance(character: character)
    }
}

struct SourceLocation {
    let path: String
    var line: UInt
    var column: UInt

    init(startOfFile path: String) {
        self.path = path
        self.line = 1
        self.column = 1
    }

    mutating func advance(character: Character) {
        if character.isNewline {
            line += 1
            column = 1
        } else {
            column += 1
        }
    }
}
