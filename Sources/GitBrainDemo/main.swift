import Foundation
import GitBrainSwift

@main
struct CollaborationDemo {
    static func main() async {
        print("=== GitBrainSwift Collaboration Demo ===")
        print()

        let sharedWorktreePath = "./demo_shared"
        let brainstatePath = "./demo_brainstates"

        let sharedWorktreeURL = URL(fileURLWithPath: sharedWorktreePath)
        let brainstateURL = URL(fileURLWithPath: brainstatePath)

        print("Setting up demo environment...")
        print("  Shared worktree: \(sharedWorktreePath)")
        print("  Brainstates: \(brainstatePath)")
        print()

        let communication = SharedWorktreeCommunication(sharedWorktree: sharedWorktreeURL)
        let memoryManager = BrainStateManager(brainstateBase: brainstateURL)
        let memoryStore = MemoryStore()
        let knowledgeBase = KnowledgeBase(base: brainstateURL)

        let systemConfig = SystemConfig(
            name: "Demo System",
            version: "1.0.0",
            maildirBase: sharedWorktreePath,
            brainstateBase: brainstatePath,
            checkInterval: 5,
            configCheckInterval: 10,
            hotReload: false,
            autoSave: true,
            saveInterval: 30,
            roles: [
                "coder": RoleConfig(
                    name: "coder",
                    roleType: .coder,
                    enabled: true,
                    mailbox: "coder",
                    brainstateFile: "coder_state.json",
                    capabilities: [
                        "write_code",
                        "implement_features",
                        "fix_bugs",
                        "refactor_code",
                        "write_tests",
                        "document_code",
                        "apply_feedback",
                        "submit_for_review"
                    ]
                ),
                "overseer": RoleConfig(
                    name: "overseer",
                    roleType: .overseer,
                    enabled: true,
                    mailbox: "overseer",
                    brainstateFile: "overseer_state.json",
                    capabilities: [
                        "review_code",
                        "approve_code",
                        "reject_code",
                        "request_changes",
                        "provide_feedback",
                        "assign_tasks",
                        "monitor_progress",
                        "enforce_quality_standards"
                    ]
                )
            ]
        )

        let coderRoleConfig = systemConfig.roles["coder"]!
        let overseerRoleConfig = systemConfig.roles["overseer"]!

        let coder = CoderAI(
            system: systemConfig,
            roleConfig: coderRoleConfig,
            communication: communication,
            memoryManager: memoryManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )

        let overseer = OverseerAI(
            system: systemConfig,
            roleConfig: overseerRoleConfig,
            communication: communication,
            memoryManager: memoryManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )

        print("Initializing CoderAI...")
        try? await coder.initialize()
        print("✓ CoderAI initialized")

        print("Initializing OverseerAI...")
        try? await overseer.initialize()
        print("✓ OverseerAI initialized")

        print("Setting up role directories...")
        _ = try? await communication.setupRoleDirectory(for: "coder")
        _ = try? await communication.setupRoleDirectory(for: "overseer")
        print("✓ Role directories created")
        print()

        print("=== Scenario 1: OverseerAI assigns a task to CoderAI ===")
        let taskID = "task_001"
        let taskDescription = "Implement a simple greeting function"

        print("OverseerAI assigning task '\(taskID)' to CoderAI...")
        try? await overseer.assignTask(
            taskID: taskID,
            coder: "coder",
            description: taskDescription,
            taskType: "coding"
        )
        print("✓ Task assigned")
        print()

        print("=== Scenario 2: CoderAI receives and processes the task ===")
        let coderMessages = try? await coder.receiveMessages()
        print("CoderAI received \(coderMessages?.count ?? 0) messages")

        if let messages = coderMessages, !messages.isEmpty {
            for message in messages {
                print("  Processing message: \(message.messageType.rawValue)")
                await coder.processMessage(message)
            }
        }
        print()

        print("=== Scenario 3: CoderAI implements the task ===")
        print("CoderAI implementing task...")
        let codeSubmission = await coder.implementTask()
        if let submission = codeSubmission {
            print("✓ Code generated:")
            print("  Task ID: \(submission.data["task_id"] as? String ?? "")")
            print("  Language: \(submission.data["language"] as? String ?? "")")
            print("  Code preview:")
            if let code = submission.data["code"] as? String {
                let lines = code.components(separatedBy: "\n")
                for line in lines.prefix(5) {
                    print("    \(line)")
                }
                if lines.count > 5 {
                    print("    ...")
                }
            }
        }
        print()

        print("=== Scenario 4: CoderAI submits code for review ===")
        print("CoderAI submitting code to OverseerAI...")
        try? await coder.submitCode(reviewer: "overseer")
        print("✓ Code submitted")
        print()

        print("=== Scenario 5: OverseerAI receives and reviews the code ===")
        let overseerMessages = try? await overseer.receiveMessages()
        print("OverseerAI received \(overseerMessages?.count ?? 0) messages")

        if let messages = overseerMessages, !messages.isEmpty {
            for message in messages {
                print("  Processing message: \(message.messageType.rawValue)")
                await overseer.processMessage(message)
            }
        }
        print()

        print("=== Scenario 6: OverseerAI reviews the code ===")
        print("OverseerAI reviewing code...")
        let reviewResult = await overseer.reviewCode(taskID: taskID)
        if let review = reviewResult {
            let reviewDict = review.toAnyDict()
            print("✓ Review completed:")
            print("  Approved: \(reviewDict["approved"] as? Bool ?? false)")
            print("  Reviewer: \(reviewDict["reviewer"] as? String ?? "")")
            if let comments = reviewDict["comments"] as? [[String: Any]] {
                print("  Comments:")
                for comment in comments {
                    let line = comment["line"] as? Int ?? 0
                    let type = comment["type"] as? String ?? ""
                    let message = comment["message"] as? String ?? ""
                    print("    Line \(line) [\(type)]: \(message)")
                }
            }
        }
        print()

        print("=== Scenario 7: OverseerAI approves the code ===")
        if let review = reviewResult, let approved = review.toAnyDict()["approved"] as? Bool, approved {
            print("OverseerAI approving code...")
            try? await overseer.approveCode(taskID: taskID, coder: "coder")
            print("✓ Code approved")
        } else {
            print("OverseerAI requesting changes...")
            try? await overseer.requestChanges(
                taskID: taskID,
                feedback: "Please add more documentation",
                coder: "coder"
            )
            print("✓ Changes requested")
        }
        print()

        print("=== Scenario 8: CoderAI receives approval/rejection ===")
        let coderMessages2 = try? await coder.receiveMessages()
        print("CoderAI received \(coderMessages2?.count ?? 0) messages")

        if let messages = coderMessages2, !messages.isEmpty {
            for message in messages {
                print("  Processing message: \(message.messageType.rawValue)")
                await coder.processMessage(message)
            }
        }
        print()

        print("=== Final Status ===")
        let coderStatus = await coder.getStatus()
        let overseerStatus = await overseer.getStatus()

        print("CoderAI Status:")
        if let currentTask = coderStatus.data["current_task"] as? [String: Any] {
            print("  Current task: \(currentTask["task_id"] as? String ?? "none")")
            print("  Status: \(currentTask["status"] as? String ?? "unknown")")
        }
        print("  Tasks completed: \(coderStatus.data["task_history_count"] as? Int ?? 0)")
        print("  Code submissions: \(coderStatus.data["code_history_count"] as? Int ?? 0)")
        print()

        print("OverseerAI Status:")
        print("  Review queue: \(overseerStatus.data["review_queue_count"] as? Int ?? 0)")
        print("  Reviews completed: \(overseerStatus.data["review_history_count"] as? Int ?? 0)")
        print("  Approved tasks: \(overseerStatus.data["approved_tasks_count"] as? Int ?? 0)")
        print("  Rejected tasks: \(overseerStatus.data["rejected_tasks_count"] as? Int ?? 0)")
        print()

        print("=== Demo Complete ===")
        print()
        print("To clean up demo files, run:")
        print("  rm -rf \(sharedWorktreePath)")
        print("  rm -rf \(brainstatePath)")
    }
}
