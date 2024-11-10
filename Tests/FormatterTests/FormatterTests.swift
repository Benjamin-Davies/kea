import Kea
import SwiftParser
import XCTest

class FormatterTests: XCTestCase {
    func testFormatter() throws {
        let basePath = URL(fileURLWithPath: "TestData/FormatterTests")

        var totalFiles = 0
        for subFolder in try listDirectory(basePath) {
            let canonicalFile = URL(fileURLWithPath: "Canonical.swift", relativeTo: subFolder)
            let canonical = try String(contentsOf: canonicalFile)

            for sourceFile in try listDirectory(subFolder) {
                let contents = try String(contentsOf: sourceFile)

                let source = Parser.parse(source: contents)
                let formatted = format(source)

                XCTAssertEqual(formatted, canonical)

                totalFiles += 1
            }
        }

        print("Tested \(totalFiles) files")
    }
}

func listDirectory(_ url: URL) throws -> [URL] {
    try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
}
