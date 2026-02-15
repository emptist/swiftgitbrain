import Foundation
import GitBrainSwift

@main
struct CreatorDaemon {
    static func main() async {
        let config = DaemonConfig(
            aiName: "Creator",
            role: .creator,
            pollInterval: 1.0,
            heartbeatInterval: 30.0,
            autoHeartbeat: true,
            processMessages: true
        )
        
        let dbConfig = DatabaseConfig(
            host: "localhost",
            port: 5432,
            database: "gitbrain",
            username: "postgres",
            password: "postgres"
        )
        
        let dbManager = DatabaseManager(config: dbConfig)
        let daemon = AIDaemon(config: config, databaseManager: dbManager)
        
        await daemon.setCallbacks(
            onTaskReceived: { task in
                print("📥 Task received: \(task.taskId)")
                print("   From: \(task.fromAI)")
                print("   Description: \(task.description)")
                print("   Type: \(task.taskType)")
                print("   Priority: \(task.priority)")
                
                await handleTask(task, daemon: daemon)
            },
            onReviewReceived: { review in
                print("📝 Review received: \(review.taskId)")
                print("   From: \(review.fromAI)")
                print("   Approved: \(review.approved)")
                print("   Reviewer: \(review.reviewer)")
                
                if let feedback = review.feedback {
                    print("   Feedback: \(feedback)")
                }
            },
            onCodeReceived: { code in
                print("💻 Code received: \(code.codeId)")
                print("   From: \(code.fromAI)")
                print("   Title: \(code.title)")
                print("   Files: \(code.files)")
            },
            onScoreReceived: { score in
                print("🏆 Score received: \(score.taskId)")
                print("   From: \(score.fromAI)")
                print("   Requested: \(score.requestedScore)")
                print("   Justification: \(score.qualityJustification)")
            },
            onFeedbackReceived: { feedback in
                print("💬 Feedback received: \(feedback.subject)")
                print("   From: \(feedback.fromAI)")
                print("   Type: \(feedback.feedbackType)")
                print("   Content: \(feedback.content)")
            },
            onHeartbeatReceived: { heartbeat in
                print("💓 Heartbeat from: \(heartbeat.fromAI)")
                print("   Role: \(heartbeat.aiRole)")
                print("   Status: \(heartbeat.status)")
                if let task = heartbeat.currentTask {
                    print("   Current Task: \(task)")
                }
            },
            onError: { error in
                print("❌ Daemon error: \(error.localizedDescription)")
            }
        )
        
        do {
            try await daemon.start()
            print("✅ Creator Daemon started")
            print("🔄 Polling for messages every 1 second")
            print("💓 Sending heartbeats every 30 seconds")
            print("Press Ctrl+C to stop")
            
            try await Task.sleep(for: .seconds(TimeInterval.infinity))
        } catch {
            print("❌ Failed to start daemon: \(error)")
        }
    }
    
    static func handleTask(_ task: TaskMessageModel, daemon: AIDaemon) async {
        print("\n🔄 Processing task: \(task.taskId)")
        print("   Type: \(task.taskType)")
        print("   Description: \(task.description)")
        
        do {
            _ = try await daemon.sendMessage(
                to: task.fromAI,
                type: .feedback,
                content: SendableContent([
                    "feedback_type": "progress",
                    "subject": "Task \(task.taskId) Started",
                    "content": "Working on: \(task.description)"
                ])
            )
            print("   ✅ Sent progress update to \(task.fromAI)")
        } catch {
            print("   ❌ Failed to send progress update: \(error)")
        }
    }
}
