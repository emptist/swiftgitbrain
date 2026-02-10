#!/usr/bin/env swift

import Foundation
import GitBrainSwift

@main
struct CheckMessages {
    static func main() async throws {
        print("=== GitBrainSwift Message Checker ===")
        print()
        
        guard let sharedWorktreePath = ProcessInfo.processInfo.environment["SHARED_WORKTREE"] else {
            print("Error: SHARED_WORKTREE environment variable not set")
            print()
            print("Usage:")
            print("  export SHARED_WORKTREE=/path/to/shared-worktree")
            print("  swift CheckMessages.swift")
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
            communication: communication,
            memoryManager: brainStateManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )
        
        print("Initializing CoderAI...")
        try await coder.initialize()
        print("✓ CoderAI initialized")
        print()
        
        print("=== Checking for Messages ===")
        print()
        
        let messages = try await communication.receiveMessages(for: "coder")
        
        if messages.isEmpty {
            print("No messages found")
            print()
            print("Waiting for OverseerAI to send collaboration proposal...")
            print()
            print("Shared Worktree: \(sharedWorktreePath)")
            print()
            return
        }
        
        print("Found \(messages.count) message(s):")
        print()
        
        for (index, message) in messages.enumerated() {
            print("--- Message \(index + 1) ---")
            print("From: \(message.fromAI)")
            print("Type: \(message.messageType)")
            print("Timestamp: \(message.timestamp)")
            print("Content:")
            print("  \(message.content)")
            print()
            
            if message.messageType == .status {
                let status = message.content["status"] as? String ?? ""
                
                if status == "COLLABORATION_PROPOSAL" {
                    print("=== Collaboration Proposal Received ===")
                    print()
                    print("OverseerAI is proposing collaboration!")
                    print()
                    
                    let overseerRole = message.content["overseer_role"] as? [String: Any]
                    let coderRole = message.content["coder_role"] as? [String: Any]
                    let whatWeveDone = message.content["what_weve_done"] as? [String] ?? []
                    let proposedAgreement = message.content["proposed_agreement"] as? [String: Any]
                    
                    print("OverseerAI Role:")
                    if let overseerName = overseerRole?["name"] as? String {
                        print("  Name: \(overseerName)")
                    }
                    if let overseerPurpose = overseerRole?["purpose"] as? String {
                        print("  Purpose: \(overseerPurpose)")
                    }
                    if let overseerCapabilities = overseerRole?["capabilities"] as? [String] {
                        print("  Capabilities:")
                        for capability in overseerCapabilities {
                            print("    - \(capability)")
                        }
                    }
                    if let overseerResponsibilities = overseerRole?["responsibilities"] as? [String] {
                        print("  Responsibilities:")
                        for responsibility in overseerResponsibilities {
                            print("    \(responsibility)")
                        }
                    }
                    print()
                    
                    print("CoderAI Role:")
                    if let coderName = coderRole?["name"] as? String {
                        print("  Name: \(coderName)")
                    }
                    if let coderPurpose = coderRole?["purpose"] as? String {
                        print("  Purpose: \(coderPurpose)")
                    }
                    if let coderCapabilities = coderRole?["capabilities"] as? [String] {
                        print("  Capabilities:")
                        for capability in coderCapabilities {
                            print("    - \(capability)")
                        }
                    }
                    if let coderResponsibilities = coderRole?["responsibilities"] as? [String] {
                        print("  Responsibilities:")
                        for responsibility in coderResponsibilities {
                            print("    \(responsibility)")
                        }
                    }
                    print()
                    
                    print("What We've Done:")
                    for item in whatWeveDone {
                        print("  ✓ \(item)")
                    }
                    print()
                    
                    print("Proposed Agreement:")
                    if let overseerResp = proposedAgreement?["overseer_responsibilities"] as? [String] {
                        print("  OverseerAI Responsibilities:")
                        for resp in overseerResp {
                            print("    \(resp)")
                        }
                    }
                    if let coderResp = proposedAgreement?["coder_responsibilities"] as? [String] {
                        print("  CoderAI Responsibilities:")
                        for resp in coderResp {
                            print("    \(resp)")
                        }
                    }
                    if let commRules = proposedAgreement?["communication_rules"] as? [String] {
                        print("  Communication Rules:")
                        for rule in commRules {
                            print("    \(rule)")
                        }
                    }
                    print()
                    
                    print("=== Agreement Response ===")
                    print()
                    print("Do you agree to this collaboration proposal?")
                    print("  [y] Yes, I agree")
                    print("  [n] No, I have concerns")
                    print("  [q] Quit")
                    print()
                    
                    if let response = readLine() {
                        switch response.lowercased() {
                        case "y", "yes":
                            print()
                            print("✓ Agreement accepted!")
                            print()
                            
                            let agreementMessage = MessageBuilder.createStatusMessage(
                                fromAI: "coder",
                                toAI: "overseer",
                                status: "AGREEMENT_ACCEPTED",
                                details: [
                                    "agreement": "accepted",
                                    "understanding": "I understand my role and responsibilities",
                                    "ready": "Ready to receive tasks",
                                    "timestamp": ISO8601DateFormatter().string(from: Date())
                                ]
                            )
                            
                            let messageURL = try await communication.sendMessage(agreementMessage, from: "coder", to: "overseer")
                            print("✓ Agreement response sent to OverseerAI")
                            print("  Message path: \(messageURL.path)")
                            print()
                            print("=== Collaboration Established ===")
                            print()
                            print("OverseerAI and CoderAI are now collaborating!")
                            print()
                            print("Next steps:")
                            print("  1. OverseerAI will assign tasks")
                            print("  2. CoderAI will implement tasks")
                            print("  3. CoderAI will submit code for review")
                            print("  4. OverseerAI will review and approve/reject")
                            print()
                            
                        case "n", "no":
                            print()
                            print("✗ Agreement not accepted")
                            print()
                            print("Please provide your concerns:")
                            if let concerns = readLine() {
                                print()
                                let concernMessage = MessageBuilder.createStatusMessage(
                                    fromAI: "coder",
                                    toAI: "overseer",
                                    status: "AGREEMENT_DECLINED",
                                    details: [
                                        "concerns": concerns,
                                        "timestamp": ISO8601DateFormatter().string(from: Date())
                                    ]
                                )
                                
                                let messageURL = try await communication.sendMessage(concernMessage, from: "coder", to: "overseer")
                                print("✓ Concerns sent to OverseerAI")
                                print("  Message path: \(messageURL.path)")
                                print()
                            }
                            
                        case "q", "quit":
                            print()
                            print("Exiting...")
                            return
                            
                        default:
                            print()
                            print("Invalid response. Please try again.")
                        }
                    }
                } else {
                    print("Status message received: \(status)")
                }
            } else {
                print("Message type: \(message.messageType)")
                await coder.processMessage(message)
            }
        }
    }
    
    static func readLine() -> String? {
        print("> ", terminator: "")
        return readLine()
    }
}