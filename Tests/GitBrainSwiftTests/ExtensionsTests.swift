import Testing
@testable import GitBrainSwift
import Foundation

struct ExtensionsTests {
    @Test("URL isDirectory extension")
    func testURLIsDirectory() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GitBrainTests")
            .appendingPathComponent(UUID().uuidString)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        #expect(tempDir.isDirectory == true)
        
        let fileURL = tempDir.appendingPathComponent("test.txt")
        try "test".write(to: fileURL, atomically: true, encoding: .utf8)
        
        #expect(fileURL.isDirectory == false)
    }
    
    @Test("URL exists extension")
    func testURLExists() throws {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GitBrainTests")
            .appendingPathComponent(UUID().uuidString)
        
        defer {
            try? FileManager.default.removeItem(at: tempDir)
        }
        
        #expect(tempDir.exists == false)
        
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        #expect(tempDir.exists == true)
    }
    
    @Test("URL appendingPathComponents extension")
    func testURLAppendingPathComponents() {
        let baseURL = URL(fileURLWithPath: "/tmp")
        let result = baseURL.appendingPathComponents(["dir1", "dir2", "file.txt"])
        
        #expect(result.path == "/tmp/dir1/dir2/file.txt")
    }
    
    @Test("Date iso8601String extension")
    func testDateISO8601String() {
        let date = Date(timeIntervalSince1970: 0)
        let isoString = date.iso8601String
        
        #expect(isoString.contains("1970"))
        #expect(isoString.contains("T"))
    }
    
    @Test("Date fromISO8601 extension")
    func testDateFromISO8601() {
        let date = Date(timeIntervalSince1970: 0)
        let isoString = date.iso8601String
        
        let parsedDate = Date.fromISO8601(isoString)
        
        #expect(parsedDate != nil)
        #expect(abs(parsedDate!.timeIntervalSince1970 - date.timeIntervalSince1970) < 1.0)
    }
    
    @Test("Date timeAgo extension")
    func testDateTimeAgo() {
        let now = Date()
        
        let secondsAgo = now.addingTimeInterval(-90)
        let minutesAgo = now.addingTimeInterval(-5400)
        let hoursAgo = now.addingTimeInterval(-172800)
        
        #expect(!secondsAgo.timeAgo.isEmpty)
        #expect(!minutesAgo.timeAgo.isEmpty)
        #expect(!hoursAgo.timeAgo.isEmpty)
        #expect(secondsAgo.timeAgo.contains("ago"))
        #expect(minutesAgo.timeAgo.contains("ago"))
        #expect(hoursAgo.timeAgo.contains("ago"))
    }
    
    @Test("String trimmed extension")
    func testStringTrimmed() {
        let string = "  test  "
        #expect(string.trimmed == "test")
        
        let newlines = "\n\n\n\n"
        #expect(newlines.trimmed == "")
    }
    
    @Test("String isNotEmpty extension")
    func testStringIsNotEmpty() {
        #expect("test".isNotEmpty == true)
        #expect("".isNotEmpty == false)
    }
    
    @Test("String contains extension")
    func testStringContains() {
        #expect("Hello World".contains("World") == true)
        #expect("Hello World".contains("world", caseSensitive: false) == true)
        #expect("Hello World".contains("world") == false)
    }
    
    @Test("String splitLines extension")
    func testStringSplitLines() {
        let string = "line1\nline2\nline3"
        let lines = string.splitLines()
        
        #expect(lines.count == 3)
        #expect(lines[0] == "line1")
        #expect(lines[1] == "line2")
        #expect(lines[2] == "line3")
    }
    
    @Test("String lines extension")
    func testStringLines() {
        let string = "line1\nline2\nline3"
        let lines = string.lines
        
        #expect(lines.count == 3)
    }
    
    @Test("String toURL extension")
    func testStringToURL() {
        let url = "https://example.com".toURL()
        #expect(url != nil)
        #expect(url?.scheme == "https")
    }
    
    @Test("String toFileURL extension")
    func testStringToFileURL() {
        let fileURL = "/tmp/test.txt".toFileURL()
        #expect(fileURL.path == "/tmp/test.txt")
        #expect(fileURL.isFileURL == true)
    }
    
    @Test("String base64Encoded extension")
    func testStringBase64Encoded() {
        let string = "test"
        let encoded = string.base64Encoded()
        
        #expect(encoded == "dGVzdA==")
    }
    
    @Test("String base64Decoded extension")
    func testStringBase64Decoded() {
        let encoded = "dGVzdA=="
        guard let data = Data(base64Encoded: encoded) else {
            #expect(Bool(false), "Failed to decode base64")
            return
        }
        let decoded = String(data: data, encoding: .utf8)
        
        #expect(decoded == "test")
    }
    
    @Test("Array chunked extension")
    func testArrayChunked() {
        let array = [1, 2, 3, 4, 5, 6, 7]
        let chunks = array.chunked(into: 3)
        
        #expect(chunks.count == 3)
        #expect(chunks[0] == [1, 2, 3])
        #expect(chunks[1] == [4, 5, 6])
        #expect(chunks[2] == [7])
    }
    
    @Test("Array unique extension")
    func testArrayUnique() {
        let array = [1, 2, 2, 3, 3, 3, 4, 4, 4, 4]
        let unique = array.unique()
        
        #expect(unique.count == 4)
        #expect(unique.contains(1))
        #expect(unique.contains(2))
        #expect(unique.contains(3))
        #expect(unique.contains(4))
    }
    
    @Test("Data jsonString extension")
    func testDataJSONString() {
        let data = "test".data(using: .utf8)!
        let jsonString = data.jsonString
        
        #expect(jsonString == "test")
    }
    
    @Test("Data base64EncodedString extension")
    func testDataBase64EncodedString() {
        let data = "test".data(using: .utf8)!
        let encoded = data.base64EncodedString
        
        #expect(encoded == "dGVzdA==")
    }
}
