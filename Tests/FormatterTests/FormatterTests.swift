import Kea
import SwiftParser
import XCTest

var totalFiles = 0

class FormatterTests: XCTestCase {
    func testFormatter() throws {
        let basePath = URL(fileURLWithPath: "TestData/FormatterTests")
        try testDirectory(basePath)

        print("Tested \(totalFiles) files")
    }
}

func testDirectory(_ dir: URL) throws {
    for subDir in try listDirectory(dir) {
        if subDir.hasDirectoryPath {
            try testDirectory(subDir)
        } else if subDir.pathComponents.last == "Canonical.swift" {
            try testLeafDirectory(dir)
        }
    }
}

func testLeafDirectory(_ dir: URL) throws {
    let canonicalFile = URL(fileURLWithPath: "Canonical.swift", relativeTo: dir)
    let canonical = try String(contentsOf: canonicalFile)

    for sourceFile in try listDirectory(dir) {
        let contents = try String(contentsOf: sourceFile)

        let source = Parser.parse(source: contents)
        let formatted = format(source)

        XCTAssert(formatted == canonical, "Unexpected formatting for \(sourceFile.lastPathComponent)")
        if formatted != canonical {
            let tempDir = TemporaryDirectory()
            try! canonical.write(
                to: tempDir.join(fileName: "Expected.swift"),
                atomically: true,
                encoding: .utf8)
            try! formatted.write(
                to: tempDir.join(fileName: "Actual.swift"),
                atomically: true,
                encoding: .utf8)

            let diff = Process()
            diff.currentDirectoryURL = tempDir.url
            diff.executableURL = URL(fileURLWithPath: "/usr/bin/diff")
            diff.arguments = ["-u", "Expected.swift", "Actual.swift"]
            try! diff.run()
            diff.waitUntilExit()
        }

        totalFiles += 1
    }
}

func listDirectory(_ url: URL) throws -> [URL] {
    try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
}

struct TemporaryDirectory: ~Copyable {
    let url: URL

    init() {
        url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    }

    deinit {
        try! FileManager.default.removeItem(at: url)
    }

    func join(fileName: String) -> URL {
        url.appendingPathComponent(fileName)
    }
}
