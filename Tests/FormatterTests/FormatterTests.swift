import SwiftParser
import XCTest
import Kea

class FormatterTests: XCTestCase {
    func testFormatter() throws {
        let basePath = URL(fileURLWithPath: "TestData/FormatterTests")
        for subFolder in try FileManager.default.contentsOfDirectory(at: basePath, includingPropertiesForKeys: nil) {
            let canonicalFile = URL(fileURLWithPath: "Canonical.swift", relativeTo: subFolder)
            let canonical = try String(contentsOf: canonicalFile)

            for sourceFile in try FileManager.default.contentsOfDirectory(at: subFolder, includingPropertiesForKeys: nil) {
                let contents = try String(contentsOf: sourceFile)

                let source = Parser.parse(source: contents)
                let formatted = format(source)

                XCTAssertEqual(canonical, formatted.description)
            }
        }
    }
}
