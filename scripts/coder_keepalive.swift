#!/usr/bin/env swift

import Foundation
import GitBrainSwift

@main
struct CoderKeepAlive {
    static func main() async {
        let logger = Logger()
        let counterFile = CounterFile(
            counterPath: "GitBrain/keepalive_counter.txt",
            logger: logger
        )
        
        print("🤖 CoderAI Keep-Alive Starting...")
        print("   Interval: 60 seconds")
        print("   Counter file: GitBrain/keepalive_counter.txt")
        print("")
        
        while true {
            do {
                let value = await counterFile.increment()
                let timestamp = Date().iso8601String
                print("[\(timestamp)] 🔥 CoderAI heartbeat #\(value)")
                
                try await Task.sleep(nanoseconds: 60_000_000_000)
            } catch {
                logger.error("Keep-alive error: \(error)")
                try await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }
}
