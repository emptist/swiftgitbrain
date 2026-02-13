import Testing
import Foundation
@testable import GitBrainSwift

@Suite("CodeStatus Tests")
struct CodeStatusTests {
    
    @Test("CodeStatus all cases")
    func allCases() {
        let allCases = CodeStatus.allCases
        #expect(allCases.count == 6)
        #expect(allCases.contains(.pending))
        #expect(allCases.contains(.reviewing))
        #expect(allCases.contains(.approved))
        #expect(allCases.contains(.rejected))
        #expect(allCases.contains(.merged))
        #expect(allCases.contains(.archived))
    }
    
    @Test("CodeStatus valid transitions")
    func validTransitions() {
        #expect(CodeStatus.pending.canTransition(to: .reviewing))
        #expect(CodeStatus.pending.canTransition(to: .approved))
        #expect(CodeStatus.pending.canTransition(to: .rejected))
        #expect(CodeStatus.reviewing.canTransition(to: .approved))
        #expect(CodeStatus.reviewing.canTransition(to: .rejected))
        #expect(CodeStatus.approved.canTransition(to: .merged))
        #expect(CodeStatus.approved.canTransition(to: .archived))
        #expect(CodeStatus.rejected.canTransition(to: .archived))
        #expect(CodeStatus.merged.canTransition(to: .archived))
    }
    
    @Test("CodeStatus invalid transitions")
    func invalidTransitions() {
        #expect(!CodeStatus.archived.canTransition(to: .pending))
        #expect(!CodeStatus.merged.canTransition(to: .reviewing))
        #expect(!CodeStatus.rejected.canTransition(to: .approved))
        #expect(!CodeStatus.reviewing.canTransition(to: .pending))
    }
    
    @Test("CodeStatus transition method")
    func transitionMethod() throws {
        let newStatus = try CodeStatus.pending.transition(to: .reviewing)
        #expect(newStatus == .reviewing)
    }
    
    @Test("CodeStatus transition throws")
    func transitionThrows() {
        #expect(throws: CodeStatus.TransitionError.self) {
            try CodeStatus.archived.transition(to: .pending)
        }
    }
    
    @Test("CodeStatus properties")
    func properties() {
        #expect(CodeStatus.pending.isArchivable == false)
        #expect(CodeStatus.approved.isArchivable == true)
        #expect(CodeStatus.rejected.isArchivable == true)
        #expect(CodeStatus.merged.isArchivable == true)
        
        #expect(CodeStatus.pending.isTerminal == false)
        #expect(CodeStatus.archived.isTerminal == true)
        
        #expect(CodeStatus.pending.isActive == true)
        #expect(CodeStatus.reviewing.isActive == true)
        #expect(CodeStatus.approved.isActive == false)
        #expect(CodeStatus.archived.isActive == false)
    }
}

@Suite("ScoreStatus Tests")
struct ScoreStatusTests {
    
    @Test("ScoreStatus all cases")
    func allCases() {
        let allCases = ScoreStatus.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.pending))
        #expect(allCases.contains(.requested))
        #expect(allCases.contains(.awarded))
        #expect(allCases.contains(.rejected))
        #expect(allCases.contains(.archived))
    }
    
    @Test("ScoreStatus valid transitions")
    func validTransitions() {
        #expect(ScoreStatus.pending.canTransition(to: .requested))
        #expect(ScoreStatus.requested.canTransition(to: .awarded))
        #expect(ScoreStatus.requested.canTransition(to: .rejected))
        #expect(ScoreStatus.awarded.canTransition(to: .archived))
        #expect(ScoreStatus.rejected.canTransition(to: .archived))
    }
    
    @Test("ScoreStatus invalid transitions")
    func invalidTransitions() {
        #expect(!ScoreStatus.pending.canTransition(to: .awarded))
        #expect(!ScoreStatus.archived.canTransition(to: .pending))
        #expect(!ScoreStatus.awarded.canTransition(to: .requested))
    }
    
    @Test("ScoreStatus transition method")
    func transitionMethod() throws {
        let newStatus = try ScoreStatus.pending.transition(to: .requested)
        #expect(newStatus == .requested)
    }
    
    @Test("ScoreStatus transition throws")
    func transitionThrows() {
        #expect(throws: ScoreStatus.TransitionError.self) {
            try ScoreStatus.archived.transition(to: .pending)
        }
    }
    
    @Test("ScoreStatus properties")
    func properties() {
        #expect(ScoreStatus.pending.isArchivable == false)
        #expect(ScoreStatus.awarded.isArchivable == true)
        #expect(ScoreStatus.rejected.isArchivable == true)
        
        #expect(ScoreStatus.pending.isTerminal == false)
        #expect(ScoreStatus.archived.isTerminal == true)
        
        #expect(ScoreStatus.pending.isActive == true)
        #expect(ScoreStatus.requested.isActive == true)
        #expect(ScoreStatus.awarded.isActive == false)
    }
}

@Suite("FeedbackStatus Tests")
struct FeedbackStatusTests {
    
    @Test("FeedbackStatus all cases")
    func allCases() {
        let allCases = FeedbackStatus.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.pending))
        #expect(allCases.contains(.read))
        #expect(allCases.contains(.acknowledged))
        #expect(allCases.contains(.actioned))
        #expect(allCases.contains(.archived))
    }
    
    @Test("FeedbackStatus valid transitions")
    func validTransitions() {
        #expect(FeedbackStatus.pending.canTransition(to: .read))
        #expect(FeedbackStatus.pending.canTransition(to: .acknowledged))
        #expect(FeedbackStatus.read.canTransition(to: .acknowledged))
        #expect(FeedbackStatus.read.canTransition(to: .actioned))
        #expect(FeedbackStatus.acknowledged.canTransition(to: .actioned))
        #expect(FeedbackStatus.acknowledged.canTransition(to: .archived))
        #expect(FeedbackStatus.actioned.canTransition(to: .archived))
    }
    
    @Test("FeedbackStatus invalid transitions")
    func invalidTransitions() {
        #expect(!FeedbackStatus.pending.canTransition(to: .actioned))
        #expect(!FeedbackStatus.archived.canTransition(to: .pending))
        #expect(!FeedbackStatus.actioned.canTransition(to: .read))
    }
    
    @Test("FeedbackStatus transition method")
    func transitionMethod() throws {
        let newStatus = try FeedbackStatus.pending.transition(to: .read)
        #expect(newStatus == .read)
    }
    
    @Test("FeedbackStatus transition throws")
    func transitionThrows() {
        #expect(throws: FeedbackStatus.TransitionError.self) {
            try FeedbackStatus.archived.transition(to: .pending)
        }
    }
    
    @Test("FeedbackStatus properties")
    func properties() {
        #expect(FeedbackStatus.pending.isArchivable == false)
        #expect(FeedbackStatus.actioned.isArchivable == true)
        #expect(FeedbackStatus.acknowledged.isArchivable == true)
        
        #expect(FeedbackStatus.pending.isTerminal == false)
        #expect(FeedbackStatus.archived.isTerminal == true)
        
        #expect(FeedbackStatus.pending.isActive == true)
        #expect(FeedbackStatus.read.isActive == true)
        #expect(FeedbackStatus.acknowledged.isActive == true)
        #expect(FeedbackStatus.actioned.isActive == false)
    }
}

@Suite("CodeMessageModel Tests")
struct CodeMessageModelTests {
    
    @Test("CodeMessageModel initialization")
    func initialization() {
        let model = CodeMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            codeId: "CODE-001",
            title: "Test Code",
            description: "Test description",
            files: ["file1.swift", "file2.swift"],
            branch: "main",
            commitSha: "abc123",
            status: .pending,
            messagePriority: .normal
        )
        
        #expect(model.codeId == "CODE-001")
        #expect(model.title == "Test Code")
        #expect(model.files.count == 2)
        #expect(model.branch == "main")
        #expect(model.commitSha == "abc123")
        #expect(model.status == "pending")
    }
    
    @Test("CodeMessageModel enum conversions")
    func enumConversions() {
        let model = CodeMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            codeId: "CODE-001",
            title: "Test",
            description: "Test",
            files: [],
            status: .reviewing,
            messagePriority: .high
        )
        
        #expect(model.statusEnum == .reviewing)
    }
    
    @Test("CodeMessageModel status transition")
    func statusTransition() throws {
        let model = CodeMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            codeId: "CODE-001",
            title: "Test",
            description: "Test",
            files: [],
            status: .pending,
            messagePriority: .normal
        )
        
        try model.transitionStatus(to: .reviewing)
        #expect(model.status == "reviewing")
        
        try model.transitionStatus(to: .approved)
        #expect(model.status == "approved")
    }
    
    @Test("CodeMessageModel invalid transition throws")
    func invalidTransitionThrows() {
        let model = CodeMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            codeId: "CODE-001",
            title: "Test",
            description: "Test",
            files: [],
            status: .archived,
            messagePriority: .normal
        )
        
        #expect(throws: CodeStatus.TransitionError.self) {
            try model.transitionStatus(to: .pending)
        }
    }
}

@Suite("ScoreMessageModel Tests")
struct ScoreMessageModelTests {
    
    @Test("ScoreMessageModel initialization")
    func initialization() {
        let model = ScoreMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            taskId: "TASK-001",
            requestedScore: 10,
            qualityJustification: "Excellent work",
            status: .pending,
            messagePriority: .normal
        )
        
        #expect(model.taskId == "TASK-001")
        #expect(model.requestedScore == 10)
        #expect(model.qualityJustification == "Excellent work")
        #expect(model.status == "pending")
        #expect(model.awardedScore == nil)
    }
    
    @Test("ScoreMessageModel with awarded score")
    func withAwardedScore() {
        let model = ScoreMessageModel(
            messageId: UUID(),
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: Date(),
            taskId: "TASK-001",
            requestedScore: 10,
            qualityJustification: "Good work",
            awardedScore: 8,
            awardReason: "Minor improvements needed",
            status: .awarded,
            messagePriority: .normal
        )
        
        #expect(model.awardedScore == 8)
        #expect(model.awardReason == "Minor improvements needed")
        #expect(model.statusEnum == .awarded)
    }
    
    @Test("ScoreMessageModel status transition")
    func statusTransition() throws {
        let model = ScoreMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            taskId: "TASK-001",
            requestedScore: 10,
            qualityJustification: "Test",
            status: .pending,
            messagePriority: .normal
        )
        
        try model.transitionStatus(to: .requested)
        #expect(model.status == "requested")
    }
}

@Suite("FeedbackMessageModel Tests")
struct FeedbackMessageModelTests {
    
    @Test("FeedbackMessageModel initialization")
    func initialization() {
        let model = FeedbackMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            feedbackType: "suggestion",
            subject: "Test Feedback",
            content: "This is a test feedback",
            relatedTaskId: "TASK-001",
            status: .pending,
            messagePriority: .normal
        )
        
        #expect(model.feedbackType == "suggestion")
        #expect(model.subject == "Test Feedback")
        #expect(model.content == "This is a test feedback")
        #expect(model.relatedTaskId == "TASK-001")
        #expect(model.status == "pending")
    }
    
    @Test("FeedbackMessageModel with response")
    func withResponse() {
        let model = FeedbackMessageModel(
            messageId: UUID(),
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: Date(),
            feedbackType: "acknowledgment",
            subject: "Re: Test Feedback",
            content: "Thank you for the feedback",
            response: "Action taken",
            status: .actioned,
            messagePriority: .normal
        )
        
        #expect(model.response == "Action taken")
        #expect(model.statusEnum == .actioned)
    }
    
    @Test("FeedbackMessageModel status transition")
    func statusTransition() throws {
        let model = FeedbackMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            feedbackType: "test",
            subject: "Test",
            content: "Test",
            status: .pending,
            messagePriority: .normal
        )
        
        try model.transitionStatus(to: .read)
        #expect(model.status == "read")
        
        try model.transitionStatus(to: .acknowledged)
        #expect(model.status == "acknowledged")
    }
}

@Suite("HeartbeatMessageModel Tests")
struct HeartbeatMessageModelTests {
    
    @Test("HeartbeatMessageModel initialization")
    func initialization() {
        let model = HeartbeatMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            aiRole: "coder",
            status: "active",
            currentTask: "Implementing message types",
            metadata: ["version": "1.0"]
        )
        
        #expect(model.aiRole == "coder")
        #expect(model.status == "active")
        #expect(model.currentTask == "Implementing message types")
        #expect(model.metadata?["version"] == "1.0")
    }
    
    @Test("HeartbeatMessageModel minimal")
    func minimal() {
        let model = HeartbeatMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            aiRole: "coder",
            status: "active"
        )
        
        #expect(model.aiRole == "coder")
        #expect(model.status == "active")
        #expect(model.currentTask == nil)
        #expect(model.metadata == nil)
    }
}
