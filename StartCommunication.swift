#!/usr/bin/env swift

import Foundation
import GitBrainSwift

@main
struct StartCommunication {
    static func main() async throws {
        print("=== GitBrainSwift Communication Setup ===")
        print()
        
        guard let owner = ProcessInfo.processInfo.environment["GITHUB_OWNER"],
              let repo = ProcessInfo.processInfo.environment["GITHUB_REPO"],
              let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
            print("Error: Required environment variables not set")
            print()
            print("Please set the following environment variables:")
            print("  export GITHUB_OWNER=\"your-username\"")
            print("  export GITHUB_REPO=\"your-repo\"")
            print("  export GITHUB_TOKEN=\"ghp_xxx\"")
            print()
            print("Or run:")
            print("  GITHUB_OWNER=your-username GITHUB_REPO=your-repo GITHUB_TOKEN=ghp_xxx swift StartCommunication.swift")
            return
        }
        
        print("Configuration:")
        print("  Owner: \(owner)")
        print("  Repo: \(repo)")
        print("  Token: \(String(token.prefix(10)))...")
        print()
        
        let brainstateBase = URL(fileURLWithPath: "./brainstates")
        let sharedWorktreeBase = URL(fileURLWithPath: "./shared-worktree")
        
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
        
        let brainStateManager = BrainStateManager(brainstateBase: brainstateBase)
        let memoryStore = MemoryStore()
        let knowledgeBase = KnowledgeBase(base: brainstateBase)
        let gitHubCommunication = GitHubCommunication(
            owner: owner,
            repo: repo,
            token: token
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
            communication: gitHubCommunication,
            memoryManager: brainStateManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )
        
        print("Initializing OverseerAI...")
        try await overseer.initialize()
        print("✓ OverseerAI initialized")
        print()
        
        let coderRoleConfig = RoleConfig(
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
        )
        
        let coder = CoderAI(
            system: system,
            roleConfig: coderRoleConfig,
            communication: gitHubCommunication,
            memoryManager: brainStateManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )
        
        print("Initializing CoderAI...")
        try await coder.initialize()
        print("✓ CoderAI initialized")
        print()
        
        print("=== Roles and Capabilities ===")
        print()
        print("OverseerAI:")
        print("  - Review code submissions")
        print("  - Approve or reject code")
        print("  - Provide feedback on code")
        print("  - Assign tasks to CoderAI")
        print("  - Monitor progress")
        print("  - Enforce quality standards")
        print()
        print("CoderAI:")
        print("  - Write code")
        print("  - Implement features")
        print("  - Fix bugs")
        print("  - Refactor code")
        print("  - Write tests")
        print("  - Document code")
        print("  - Apply feedback")
        print("  - Submit code for review")
        print()
        
        print("=== What We've Done ===")
        print()
        print("✓ Fixed Swift 6.2 Sendable protocol violations")
        print("  - Updated BrainStateManager to use SendableContent")
        print("  - Updated MemoryStore to use SendableContent")
        print("  - Updated KnowledgeBase to handle SendableContent")
        print("  - Updated BaseRole protocol methods")
        print("  - Fixed Logger concurrency safety")
        print("  - Updated CoderAI and OverseerAI")
        print("  - Updated ViewModels")
        print()
        print("✓ Created project infrastructure")
        print("  - Added comprehensive .gitignore")
        print("  - Created project-level rules")
        print("  - Removed Python transition files")
        print()
        print("✓ Project builds successfully with Swift 6.2")
        print()
        
        print("=== Sending Initial Message to CoderAI ===")
        print()
        
        let initialMessage = MessageBuilder.createStatusMessage(
            fromAI: "overseer",
            toAI: "coder",
            status: "ROLES_ESTABLISHED",
            details: [
                "overseer_capabilities": overseerRoleConfig.capabilities,
                "coder_capabilities": coderRoleConfig.capabilities,
                "communication_method": "github_issues",
                "ready_for_tasks": true
            ]
        )
        
        let messageURL = try await overseer.sendMessage(initialMessage)
        print("✓ Initial message sent to CoderAI")
        print("  Issue URL: \(messageURL)")
        print()
        
        print("=== Communication Ready ===")
        print()
        print("OverseerAI and CoderAI are now ready to collaborate!")
        print()
        print("Next steps:")
        print("  1. OverseerAI can assign tasks to CoderAI")
        print("  2. CoderAI will receive tasks via GitHub Issues")
        print("  3. CoderAI will submit code via Pull Requests")
        print("  4. OverseerAI will review and approve/reject")
        print()
    }
}