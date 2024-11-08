struct Token {
    let text: String

    /// UInt.max means it will never be split
    var stickiness: UInt = UInt.max

    var attachLeft: Bool = false
    var attachRight: Bool = false

    var startIndent: Bool = false
    var endIndent: Bool = false

    var newline: Bool = false
    var doubleNewline: Bool = false
    var omitIfNotLastOnLine: Bool = false

    init(_ text: String) {
        self.text = text.trimmingWhitespace()
    }
}

extension String {
    func trimmingWhitespace() -> String {
        var s = self
        while s.last?.isWhitespace == true {
            s.removeLast()
        }
        while s.first?.isWhitespace == true {
            s.removeFirst()
        }
        return s
    }
}
