import Foundation

struct BenchmarkResult: Sendable {
    let component: String
    let operation: String
    let duration: TimeInterval
    let iterations: Int
    let average: TimeInterval
    let goal: TimeInterval
    let passed: Bool
}

struct BenchmarkKey: Hashable, Sendable {
    let component: String
    let operation: String
}

struct BenchmarkReport: Sendable {
    let timestamp: Date
    let results: [BenchmarkResult]
    
    func generateMarkdown() -> String {
        var markdown = "# GitBrainSwift Benchmark Report\n\n"
        markdown += "Generated: \(ISO8601DateFormatter().string(from: timestamp))\n\n"
        
        let groupedResults = Dictionary(grouping: results) { $0.component }
        
        for (component, componentResults) in groupedResults.sorted(by: { $0.key < $1.key }) {
            markdown += "## \(component)\n\n"
            markdown += "| Operation | Duration (ms) | Average (ms) | Goal (ms) | Status |\n"
            markdown += "|-----------|--------------|--------------|-----------|--------|\n"
            
            for result in componentResults.sorted(by: { $0.operation < $1.operation }) {
                let status = result.passed ? "✅ Pass" : "❌ Fail"
                markdown += "| \(result.operation) | \(String(format: "%.3f", result.duration * 1000)) | \(String(format: "%.3f", result.average * 1000)) | \(String(format: "%.3f", result.goal * 1000)) | \(status) |\n"
            }
            
            markdown += "\n"
        }
        
        let passedCount = results.filter { $0.passed }.count
        let totalCount = results.count
        markdown += "## Summary\n\n"
        markdown += "- Total tests: \(totalCount)\n"
        markdown += "- Passed: \(passedCount)\n"
        markdown += "- Failed: \(totalCount - passedCount)\n"
        markdown += "- Pass rate: \(String(format: "%.1f", Double(passedCount) / Double(totalCount) * 100))%\n"
        
        return markdown
    }
    
    func generateJSON() -> String {
        let data: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: timestamp),
            "results": results.map { result in
                [
                    "component": result.component,
                    "operation": result.operation,
                    "duration": result.duration,
                    "iterations": result.iterations,
                    "average": result.average,
                    "goal": result.goal,
                    "passed": result.passed
                ]
            }
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
    
    func saveReport(to url: URL) throws {
        let markdown = generateMarkdown()
        try markdown.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func saveJSON(to url: URL) throws {
        let json = generateJSON()
        try json.write(to: url, atomically: true, encoding: .utf8)
    }
    
    func compare(with otherReport: BenchmarkReport) -> String {
        var comparison = "# Benchmark Comparison\n\n"
        comparison += "Comparing current run with previous run\n\n"
        
        let currentResults = Dictionary(grouping: results) { BenchmarkKey(component: $0.component, operation: $0.operation) }
        let previousResults = Dictionary(grouping: otherReport.results) { BenchmarkKey(component: $0.component, operation: $0.operation) }
        
        comparison += "| Component | Operation | Current (ms) | Previous (ms) | Change |\n"
        comparison += "|-----------|-----------|--------------|---------------|--------|\n"
        
        let sortedKeys = currentResults.keys.sorted { 
            if $0.component != $1.component {
                return $0.component < $1.component
            }
            return $0.operation < $1.operation
        }
        
        for key in sortedKeys {
            if let current = currentResults[key]?.first,
               let previous = previousResults[key]?.first {
                let change = ((current.average - previous.average) / previous.average) * 100
                let changeString = String(format: "%.1f%%", change)
                let changeEmoji = change > 20 ? "📈" : change < -20 ? "📉" : "➡️"
                comparison += "| \(current.component) | \(current.operation) | \(String(format: "%.3f", current.average * 1000)) | \(String(format: "%.3f", previous.average * 1000)) | \(changeEmoji) \(changeString) |\n"
            }
        }
        
        return comparison
    }
}