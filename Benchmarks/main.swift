import Foundation
import GitBrainSwift

struct BenchmarkRunner {
    func run() async throws {
        print("Running GitBrainSwift Benchmarks...")
        print("================================")
        
        var results: [BenchmarkResult] = []
        
        results.append(contentsOf: try await runKnowledgeBaseBenchmarks())
        results.append(contentsOf: try await runMemoryStoreBenchmarks())
        results.append(contentsOf: try await runMessageValidatorBenchmarks())
        
        let report = BenchmarkReport(timestamp: Date(), results: results)
        
        print("================================")
        print("All benchmarks completed!")
        print()
        print("Summary:")
        let passedCount = results.filter { $0.passed }.count
        let totalCount = results.count
        print("- Total tests: \(totalCount)")
        print("- Passed: \(passedCount)")
        print("- Failed: \(totalCount - passedCount)")
        print("- Pass rate: \(String(format: "%.1f", Double(passedCount) / Double(totalCount) * 100))%")
        
        let reportsDir = FileManager.default.temporaryDirectory.appendingPathComponent("GitBrainBenchmarkReports")
        try FileManager.default.createDirectory(at: reportsDir, withIntermediateDirectories: true)
        
        let reportPath = reportsDir.appendingPathComponent("benchmark_report_\(Int(Date().timeIntervalSince1970)).md")
        try report.saveReport(to: reportPath)
        print()
        print("Report saved to: \(reportPath.path)")
        
        let jsonPath = reportsDir.appendingPathComponent("benchmark_report_\(Int(Date().timeIntervalSince1970)).json")
        try report.saveJSON(to: jsonPath)
        print("JSON report saved to: \(jsonPath.path)")
        
        if totalCount - passedCount > 0 {
            print()
            print("⚠️ Some benchmarks failed to meet performance goals!")
            exit(1)
        }
    }
    
    func runKnowledgeBaseBenchmarks() async throws -> [BenchmarkResult] {
        print("\n📊 KnowledgeBase Benchmarks")
        print("----------------------------")
        
        var results: [BenchmarkResult] = []
        
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("GitBrainBenchmarks_\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        let mockRepository = MockKnowledgeRepository()
        let knowledgeBase = KnowledgeBase(repository: mockRepository)
        
        let iterations = 1000
        
        let startTime = Date()
        for i in 0..<iterations {
            try await knowledgeBase.addKnowledge(category: "test", key: "key_\(i)", value: SendableContent(["value": "value_\(i)"]))
        }
        let setTime = Date().timeIntervalSince(startTime)
        let setAverage = setTime / Double(iterations)
        let setPassed = setAverage < 0.001
        print("AddKnowledge operation: \(String(format: "%.3f", setAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "KnowledgeBase", operation: "AddKnowledge", duration: setTime, iterations: iterations, average: setAverage, goal: 0.001, passed: setPassed))
        
        let getStartTime = Date()
        for i in 0..<iterations {
            _ = try await knowledgeBase.getKnowledge(category: "test", key: "key_\(i)")
        }
        let getTime = Date().timeIntervalSince(getStartTime)
        let getAverage = getTime / Double(iterations)
        let getPassed = getAverage < 0.0001
        print("GetKnowledge operation: \(String(format: "%.3f", getAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "KnowledgeBase", operation: "GetKnowledge", duration: getTime, iterations: iterations, average: getAverage, goal: 0.0001, passed: getPassed))
        
        let searchStartTime = Date()
        _ = try await knowledgeBase.searchKnowledge(category: "test", query: "value")
        let searchTime = Date().timeIntervalSince(searchStartTime)
        let searchPassed = searchTime < 0.01
        print("SearchKnowledge operation: \(String(format: "%.3f", searchTime * 1000)) ms per 1000 items")
        results.append(BenchmarkResult(component: "KnowledgeBase", operation: "SearchKnowledge", duration: searchTime, iterations: 1000, average: searchTime / 1000, goal: 0.01, passed: searchPassed))
        
        let deleteStartTime = Date()
        for i in 0..<iterations {
            try await knowledgeBase.deleteKnowledge(category: "test", key: "key_\(i)")
        }
        let deleteTime = Date().timeIntervalSince(deleteStartTime)
        let deleteAverage = deleteTime / Double(iterations)
        let deletePassed = deleteAverage < 0.001
        print("DeleteKnowledge operation: \(String(format: "%.3f", deleteAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "KnowledgeBase", operation: "DeleteKnowledge", duration: deleteTime, iterations: iterations, average: deleteAverage, goal: 0.001, passed: deletePassed))
        
        try FileManager.default.removeItem(at: tempDir)
        
        return results
    }
    
    func runMemoryStoreBenchmarks() async throws -> [BenchmarkResult] {
        print("\n📊 MemoryStore Benchmarks")
        print("----------------------------")
        
        var results: [BenchmarkResult] = []
        
        let memoryStore = MemoryStore()
        
        let iterations = 1000
        
        let startTime = Date()
        for i in 0..<iterations {
            await memoryStore.set("key_\(i)", value: SendableContent(["value": "value_\(i)"]))
        }
        let setTime = Date().timeIntervalSince(startTime)
        let setAverage = setTime / Double(iterations)
        let setPassed = setAverage < 0.0005
        print("Set operation: \(String(format: "%.3f", setAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "MemoryStore", operation: "Set", duration: setTime, iterations: iterations, average: setAverage, goal: 0.0005, passed: setPassed))
        
        let getStartTime = Date()
        for i in 0..<iterations {
            _ = await memoryStore.get("key_\(i)")
        }
        let getTime = Date().timeIntervalSince(getStartTime)
        let getAverage = getTime / Double(iterations)
        let getPassed = getAverage < 0.00005
        print("Get operation: \(String(format: "%.3f", getAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "MemoryStore", operation: "Get", duration: getTime, iterations: iterations, average: getAverage, goal: 0.00005, passed: getPassed))
        
        let deleteStartTime = Date()
        for i in 0..<iterations {
            _ = await memoryStore.delete("key_\(i)")
        }
        let deleteTime = Date().timeIntervalSince(deleteStartTime)
        let deleteAverage = deleteTime / Double(iterations)
        let deletePassed = deleteAverage < 0.0005
        print("Delete operation: \(String(format: "%.3f", deleteAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "MemoryStore", operation: "Delete", duration: deleteTime, iterations: iterations, average: deleteAverage, goal: 0.0005, passed: deletePassed))
        
        let clearStartTime = Date()
        await memoryStore.clear()
        let clearTime = Date().timeIntervalSince(clearStartTime)
        let clearPassed = clearTime < 0.01
        print("Clear operation: \(String(format: "%.3f", clearTime * 1000)) ms per 1000 items")
        results.append(BenchmarkResult(component: "MemoryStore", operation: "Clear", duration: clearTime, iterations: 1000, average: clearTime / 1000, goal: 0.01, passed: clearPassed))
        
        return results
    }
    
    func runMessageValidatorBenchmarks() async throws -> [BenchmarkResult] {
        print("\n📊 MessageValidator Benchmarks")
        print("----------------------------")
        
        var results: [BenchmarkResult] = []
        
        let validator = MessageValidator()
        
        let iterations = 1000
        
        let messageContent = SendableContent([
            "type": "task",
            "task_id": "task-001",
            "description": "Test task",
            "task_type": "coding",
            "priority": 5
        ])
        
        let startTime = Date()
        for _ in 0..<iterations {
            try await validator.validate(content: messageContent)
        }
        let validateTime = Date().timeIntervalSince(startTime)
        let validateAverage = validateTime / Double(iterations)
        let validatePassed = validateAverage < 0.001
        print("Validate operation: \(String(format: "%.3f", validateAverage * 1000)) ms per operation")
        results.append(BenchmarkResult(component: "MessageValidator", operation: "Validate", duration: validateTime, iterations: iterations, average: validateAverage, goal: 0.001, passed: validatePassed))
        
        return results
    }
}

let runner = BenchmarkRunner()
try await runner.run()