#!/usr/bin/env swift

import Foundation
import GitBrainSwift

@main
struct OverseerKeepAlive {
    static func main() async {
        let logger = Logger()
        let counterFile = CounterFile(
            counterPath: "GitBrain/keepalive_counter.txt",
            logger: logger
        )
        
        print("🤖 OverseerAI Keep-Alive Starting...")
        print("   Interval: 90 seconds")
        print("   Counter file: GitBrain/keepalive_counter.txt")
        print("")
        
        while true {
            do {
                let value = await counterFile.increment()
                let timestamp = Date().iso8601String
                print("[\(timestamp)] 🔥 OverseerAI heartbeat #\(value)")
                
                try await Task.sleep(nanoseconds: 90_000_000_000)
            } catch {
                logger.error("Keep-alive error: \(error)")
                try await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }
}
