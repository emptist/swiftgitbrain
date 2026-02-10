#!/usr/bin/env swift

import Foundation
import GitBrainSwift

@main
struct EstablishCollaboration {
    static func main() async throws {
        print("=== GitBrainSwift Collaboration Setup ===")
        print()
        
        guard let sharedWorktreePath = ProcessInfo.processInfo.environment["SHARED_WORKTREE"] else {
            print("Error: SHARED_WORKTREE environment variable not set")
            print()
            print("Usage:")
            print("  export SHARED_WORKTREE=/path/to/shared-worktree")
            print("  swift EstablishCollaboration.swift")
            return
        }
        
        let sharedWorktreeURL = URL(fileURLWithPath: sharedWorktreePath)
        let brainstateBase = URL(fileURLWithPath: "./brainstates")
        
        let communication = SharedWorktreeCommunication(sharedWorktree: sharedWorktreeURL)
        let brainStateManager = BrainStateManager(brainstateBase: brainstateBase)
        let memoryStore = MemoryStore()
        let knowledgeBase = KnowledgeBase(base: brainstateBase)
        
        let system = SystemConfig(
            name: "GitBrainSwift Workspace",
            version: "1.0.0",
            maildirBase: "./mailboxes",
            brainstateBase: brainstateBase.path,
            checkInterval: 60,
            configCheckInterval: 300,
            hotReload: true,
            autoSave: true,
            saveInterval: 30,
            roles: [:]
        )
        
        let overseerRoleConfig = RoleConfig(
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
        
        let overseer = OverseerAI(
            system: system,
            roleConfig: overseerRoleConfig,
            communication: communication,
            memoryManager: brainStateManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )
        
        print("Initializing OverseerAI...")
        try await overseer.initialize()
        print("✓ OverseerAI initialized")
        print()
        
        print("=== Setting Up Communication ===")
        print()
        
        try await communication.setupRoleDirectory(for: "overseer")
        try await communication.setupRoleDirectory(for: "coder")
        print("✓ Communication directories created")
        print()
        
        print("=== Sending Collaboration Proposal ===")
        print()
        
        let collaborationMessage = MessageBuilder.createStatusMessage(
            fromAI: "overseer",
            toAI: "coder",
            status: "COLLABORATION_PROPOSAL",
            details: [
                "sender": "overseer",
                "recipient": "coder",
                "purpose": "Establish collaboration agreement between OverseerAI and CoderAI",
                "overseer_role": [
                    "name": "OverseerAI",
                    "purpose": "Coordinate between AIs, review code submissions, manage task assignment, enforce quality standards",
                    "capabilities": overseerRoleConfig.capabilities,
                    "responsibilities": [
                        "Assign tasks to CoderAI",
                        "Review code submissions",
                        "Provide feedback and approve/reject code",
                        "Monitor progress and enforce quality standards"
                    ]
                ],
                "coder_role": [
                    "name": "CoderAI",
                    "purpose": "Implement coding tasks, generate code based on requirements, submit code for review, handle feedback and revisions",
                    "capabilities": [
                        "write_code",
                        "implement_features",
                        "fix_bugs",
                        "refactor_code",
                        "write_tests",
                        "document_code",
                        "apply_feedback",
                        "submit_for_review"
                    ],
                    "responsibilities": [
                        "Receive tasks from OverseerAI",
                        "Implement features and write code",
                        "Submit code via Pull Requests",
                        "Handle feedback and revisions"
                    ]
                ],
                "what_weve_done": [
                    "Fixed Swift 6.2 Sendable protocol violations",
                    "Updated BrainStateManager to use SendableContent",
                    "Updated MemoryStore to use SendableContent",
                    "Updated KnowledgeBase to handle SendableContent",
                    "Updated BaseRole protocol methods",
                    "Fixed Logger concurrency safety",
                    "Updated CoderAI and OverseerAI",
                    "Updated ViewModels",
                    "Created comprehensive .gitignore",
                    "Created project-level rules",
                    "Removed Python transition files",
                    "Project builds successfully"
                ],
                "communication_protocol": [
                    "method": "shared_worktree",
                    "path": sharedWorktreePath,
                    "message_types": [
                        "task",
                        "code",
                        "review",
                        "feedback",
                        "approval",
                        "rejection",
                        "status",
                        "heartbeat"
                    ]
                ],
                "proposed_agreement": [
                    "overseer_responsibilities": [
                        "1. OverseerAI will assign tasks to CoderAI",
                        "2. OverseerAI will review code submissions",
                        "3. OverseerAI will provide feedback on code",
                        "4. OverseerAI will approve or reject code",
                        "5. OverseerAI will monitor progress",
                        "6. OverseerAI will enforce quality standards"
                    ],
                    "coder_responsibilities": [
                        "1. CoderAI will receive tasks from OverseerAI",
                        "2. CoderAI will implement features and write code",
                        "3. CoderAI will submit code for review",
                        "4. CoderAI will handle feedback",
                        "5. CoderAI will make revisions as needed",
                        "6. CoderAI will document code"
                    ],
                    "communication_rules": [
                        "1. Use shared worktree for real-time communication",
                        "2. Use GitHub Issues for persistent messaging",
                        "3. All messages will be in SendableContent format",
                        "4. Respect actor boundaries for thread safety",
                        "5. Follow Swift 6.2 best practices"
                    ]
                ],
                "next_steps": [
                    "1. CoderAI should acknowledge this message",
                    "2. CoderAI should confirm understanding of roles",
                    "3. CoderAI should agree to responsibilities",
                    "4. OverseerAI will assign first task after agreement"
                ]
            ]
        )
        
        let messageURL = try await communication.sendMessage(collaborationMessage, from: "overseer", to: "coder")
        print("✓ Collaboration proposal sent to CoderAI")
        print("  Message path: \(messageURL.path)")
        print()
        
        print("=== Waiting for CoderAI Response ===")
        print()
        print("CoderAI should:")
        print("  1. Check shared worktree for messages")
        print("  2. Review collaboration proposal")
        print("  3. Respond with agreement or concerns")
        print()
        print("To check for messages, CoderAI can run:")
        print("  swift CheckMessages.swift")
        print()
        
        print("=== Collaboration Status ===")
        print()
        print("OverseerAI: Ready and waiting for agreement")
        print("Shared Worktree: \(sharedWorktreePath)")
        print("Brainstate: \(brainstateBase.path)")
        print()
    }
}