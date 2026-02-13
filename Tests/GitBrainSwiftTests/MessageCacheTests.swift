import Testing
@testable import GitBrainSwift
import Foundation

struct TaskTypeTests {
    @Test("TaskType raw values")
    func testRawValues() {
        #expect(TaskType.coding.rawValue == "coding")
        #expect(TaskType.review.rawValue == "review")
        #expect(TaskType.testing.rawValue == "testing")
        #expect(TaskType.documentation.rawValue == "documentation")
    }
    
    @Test("TaskType from raw value")
    func testFromRawValue() {
        #expect(TaskType(rawValue: "coding") == .coding)
        #expect(TaskType(rawValue: "review") == .review)
        #expect(TaskType(rawValue: "testing") == .testing)
        #expect(TaskType(rawValue: "documentation") == .documentation)
        #expect(TaskType(rawValue: "unknown") == nil)
    }
    
    @Test("TaskType Codable")
    func testCodable() throws {
        let original = TaskType.coding
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TaskType.self, from: data)
        #expect(decoded == original)
    }
    
    @Test("TaskType CaseIterable")
    func testCaseIterable() {
        #expect(TaskType.allCases.count == 4)
        #expect(TaskType.allCases.contains(.coding))
        #expect(TaskType.allCases.contains(.review))
        #expect(TaskType.allCases.contains(.testing))
        #expect(TaskType.allCases.contains(.documentation))
    }
}

struct TaskStatusTests {
    @Test("TaskStatus raw values")
    func testRawValues() {
        #expect(TaskStatus.pending.rawValue == "pending")
        #expect(TaskStatus.inProgress.rawValue == "in_progress")
        #expect(TaskStatus.completed.rawValue == "completed")
        #expect(TaskStatus.failed.rawValue == "failed")
        #expect(TaskStatus.cancelled.rawValue == "cancelled")
        #expect(TaskStatus.archived.rawValue == "archived")
    }
    
    @Test("TaskStatus valid transitions")
    func testValidTransitions() {
        #expect(TaskStatus.pending.canTransition(to: .inProgress) == true)
        #expect(TaskStatus.pending.canTransition(to: .cancelled) == true)
        #expect(TaskStatus.inProgress.canTransition(to: .completed) == true)
        #expect(TaskStatus.inProgress.canTransition(to: .failed) == true)
        #expect(TaskStatus.completed.canTransition(to: .archived) == true)
    }
    
    @Test("TaskStatus invalid transitions")
    func testInvalidTransitions() {
        #expect(TaskStatus.pending.canTransition(to: .completed) == false)
        #expect(TaskStatus.completed.canTransition(to: .inProgress) == false)
        #expect(TaskStatus.archived.canTransition(to: .pending) == false)
    }
    
    @Test("TaskStatus transition method")
    func testTransitionMethod() throws {
        let status = TaskStatus.pending
        let newStatus = try status.transition(to: .inProgress)
        #expect(newStatus == .inProgress)
    }
    
    @Test("TaskStatus transition throws")
    func testTransitionThrows() {
        let status = TaskStatus.completed
        do {
            let _ = try status.transition(to: .inProgress)
            Issue.record("Should have thrown")
        } catch let TaskStatus.TransitionError.invalidTransition(from, to) {
            #expect(from == .completed)
            #expect(to == .inProgress)
        } catch {
            Issue.record("Wrong error type")
        }
    }
    
    @Test("TaskStatus properties")
    func testProperties() {
        #expect(TaskStatus.pending.isArchivable == false)
        #expect(TaskStatus.completed.isArchivable == true)
        #expect(TaskStatus.pending.isTerminal == false)
        #expect(TaskStatus.completed.isTerminal == true)
        #expect(TaskStatus.pending.isActive == true)
        #expect(TaskStatus.completed.isActive == false)
    }
}

struct ReviewStatusTests {
    @Test("ReviewStatus raw values")
    func testRawValues() {
        #expect(ReviewStatus.pending.rawValue == "pending")
        #expect(ReviewStatus.inReview.rawValue == "in_review")
        #expect(ReviewStatus.approved.rawValue == "approved")
        #expect(ReviewStatus.rejected.rawValue == "rejected")
        #expect(ReviewStatus.needsChanges.rawValue == "needs_changes")
        #expect(ReviewStatus.applied.rawValue == "applied")
        #expect(ReviewStatus.archived.rawValue == "archived")
    }
    
    @Test("ReviewStatus valid transitions")
    func testValidTransitions() {
        #expect(ReviewStatus.pending.canTransition(to: .inReview) == true)
        #expect(ReviewStatus.pending.canTransition(to: .approved) == true)
        #expect(ReviewStatus.inReview.canTransition(to: .approved) == true)
        #expect(ReviewStatus.inReview.canTransition(to: .needsChanges) == true)
        #expect(ReviewStatus.approved.canTransition(to: .applied) == true)
        #expect(ReviewStatus.approved.canTransition(to: .archived) == true)
    }
    
    @Test("ReviewStatus invalid transitions")
    func testInvalidTransitions() {
        #expect(ReviewStatus.pending.canTransition(to: .applied) == false)
        #expect(ReviewStatus.applied.canTransition(to: .approved) == false)
        #expect(ReviewStatus.archived.canTransition(to: .pending) == false)
    }
    
    @Test("ReviewStatus properties")
    func testProperties() {
        #expect(ReviewStatus.pending.isArchivable == false)
        #expect(ReviewStatus.applied.isArchivable == true)
        #expect(ReviewStatus.pending.isTerminal == false)
        #expect(ReviewStatus.applied.isTerminal == true)
        #expect(ReviewStatus.pending.requiresAction == true)
        #expect(ReviewStatus.inReview.requiresAction == false)
    }
}

struct ReviewCommentTests {
    @Test("ReviewComment initialization")
    func testInit() {
        let comment = ReviewComment(
            file: "test.swift",
            line: 42,
            type: .error,
            message: "Test error"
        )
        
        #expect(comment.file == "test.swift")
        #expect(comment.line == 42)
        #expect(comment.type == .error)
        #expect(comment.message == "Test error")
    }
    
    @Test("ReviewComment CommentType raw values")
    func testCommentTypeRawValues() {
        #expect(ReviewComment.CommentType.error.rawValue == "error")
        #expect(ReviewComment.CommentType.warning.rawValue == "warning")
        #expect(ReviewComment.CommentType.suggestion.rawValue == "suggestion")
        #expect(ReviewComment.CommentType.info.rawValue == "info")
    }
    
    @Test("ReviewComment Codable")
    func testCodable() throws {
        let original = ReviewComment(
            file: "main.swift",
            line: 10,
            type: .warning,
            message: "Unused variable"
        )
        
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ReviewComment.self, from: data)
        
        #expect(decoded.file == original.file)
        #expect(decoded.line == original.line)
        #expect(decoded.type == original.type)
        #expect(decoded.message == original.message)
    }
    
    @Test("ReviewComment Equatable")
    func testEquatable() {
        let comment1 = ReviewComment(file: "test.swift", line: 1, type: .error, message: "Error")
        let comment2 = ReviewComment(file: "test.swift", line: 1, type: .error, message: "Error")
        let comment3 = ReviewComment(file: "other.swift", line: 1, type: .error, message: "Error")
        
        #expect(comment1 == comment2)
        #expect(comment1 != comment3)
    }
    
    @Test("ReviewComment array Codable")
    func testArrayCodable() throws {
        let comments = [
            ReviewComment(file: "a.swift", line: 1, type: .error, message: "Error 1"),
            ReviewComment(file: "b.swift", line: 2, type: .warning, message: "Warning 1"),
            ReviewComment(file: "a.swift", line: 10, type: .suggestion, message: "Suggestion 1")
        ]
        
        let data = try JSONEncoder().encode(comments)
        let decoded = try JSONDecoder().decode([ReviewComment].self, from: data)
        
        #expect(decoded.count == 3)
        #expect(decoded[0].file == "a.swift")
        #expect(decoded[1].file == "b.swift")
        #expect(decoded[2].type == .suggestion)
    }
}

struct TaskMessageModelTests {
    @Test("TaskMessageModel initialization")
    func testInit() {
        let messageId = UUID()
        let timestamp = Date()
        
        let model = TaskMessageModel(
            messageId: messageId,
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: timestamp,
            taskId: "task-001",
            description: "Test task",
            taskType: .coding,
            priority: 5,
            files: ["main.swift"],
            deadline: nil,
            status: .pending,
            messagePriority: .normal
        )
        
        #expect(model.messageId == messageId)
        #expect(model.fromAI == "CoderAI")
        #expect(model.toAI == "OverseerAI")
        #expect(model.taskId == "task-001")
        #expect(model.description == "Test task")
        #expect(model.taskType == "coding")
        #expect(model.priority == 5)
        #expect(model.files == ["main.swift"])
        #expect(model.status == "pending")
        #expect(model.messagePriority == 3)
    }
    
    @Test("TaskMessageModel enum conversions")
    func testEnumConversions() {
        let model = TaskMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            taskId: "task-001",
            description: "Test task",
            taskType: .review,
            priority: 3,
            files: nil,
            deadline: nil,
            status: .inProgress,
            messagePriority: .high
        )
        
        #expect(model.taskTypeEnum == .review)
        #expect(model.statusEnum == .inProgress)
        #expect(model.messagePriorityEnum == .high)
    }
    
    @Test("TaskMessageModel default values")
    func testDefaultValues() {
        let model = TaskMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            taskId: "task-001",
            description: "Test task",
            taskType: .testing,
            priority: 1
        )
        
        #expect(model.files == nil)
        #expect(model.deadline == nil)
        #expect(model.status == "pending")
        #expect(model.messagePriority == 3)
        #expect(model.statusEnum == .pending)
        #expect(model.messagePriorityEnum == .normal)
    }
    
    @Test("TaskMessageModel status transition")
    func testStatusTransition() throws {
        let model = TaskMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            taskId: "task-001",
            description: "Test task",
            taskType: .coding,
            priority: 1,
            status: .pending
        )
        
        #expect(model.statusEnum == .pending)
        
        try model.transitionStatus(to: .inProgress)
        #expect(model.statusEnum == .inProgress)
        
        try model.transitionStatus(to: .completed)
        #expect(model.statusEnum == .completed)
    }
    
    @Test("TaskMessageModel invalid transition throws")
    func testInvalidTransitionThrows() {
        let model = TaskMessageModel(
            messageId: UUID(),
            fromAI: "CoderAI",
            toAI: "OverseerAI",
            timestamp: Date(),
            taskId: "task-001",
            description: "Test task",
            taskType: .coding,
            priority: 1,
            status: .completed
        )
        
        do {
            try model.transitionStatus(to: .inProgress)
            Issue.record("Should have thrown")
        } catch {
        }
    }
}

struct ReviewMessageModelTests {
    @Test("ReviewMessageModel initialization")
    func testInit() {
        let messageId = UUID()
        let timestamp = Date()
        let comments = [
            ReviewComment(file: "main.swift", line: 10, type: .error, message: "Error")
        ]
        
        let model = ReviewMessageModel(
            messageId: messageId,
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: timestamp,
            taskId: "task-001",
            approved: false,
            reviewer: "OverseerAI",
            comments: comments,
            feedback: "Needs fixes",
            filesReviewed: ["main.swift"],
            status: .pending,
            messagePriority: .high
        )
        
        #expect(model.messageId == messageId)
        #expect(model.fromAI == "OverseerAI")
        #expect(model.toAI == "CoderAI")
        #expect(model.taskId == "task-001")
        #expect(model.approved == false)
        #expect(model.reviewer == "OverseerAI")
        #expect(model.comments?.count == 1)
        #expect(model.feedback == "Needs fixes")
        #expect(model.filesReviewed == ["main.swift"])
        #expect(model.status == "pending")
        #expect(model.messagePriority == 2)
    }
    
    @Test("ReviewMessageModel getCommentsByFile")
    func testGetCommentsByFile() {
        let comments = [
            ReviewComment(file: "a.swift", line: 1, type: .error, message: "E1"),
            ReviewComment(file: "b.swift", line: 2, type: .warning, message: "W1"),
            ReviewComment(file: "a.swift", line: 10, type: .suggestion, message: "S1")
        ]
        
        let model = ReviewMessageModel(
            messageId: UUID(),
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: Date(),
            taskId: "task-001",
            approved: true,
            reviewer: "OverseerAI",
            comments: comments
        )
        
        let byFile = model.getCommentsByFile()
        
        #expect(byFile.count == 2)
        #expect(byFile["a.swift"]?.count == 2)
        #expect(byFile["b.swift"]?.count == 1)
        #expect(byFile["a.swift"]?[0].line == 1)
        #expect(byFile["a.swift"]?[1].line == 10)
    }
    
    @Test("ReviewMessageModel getCommentsByFile empty")
    func testGetCommentsByFileEmpty() {
        let model = ReviewMessageModel(
            messageId: UUID(),
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: Date(),
            taskId: "task-001",
            approved: true,
            reviewer: "OverseerAI",
            comments: nil
        )
        
        let byFile = model.getCommentsByFile()
        #expect(byFile.isEmpty)
    }
    
    @Test("ReviewMessageModel enum conversions")
    func testEnumConversions() {
        let model = ReviewMessageModel(
            messageId: UUID(),
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: Date(),
            taskId: "task-001",
            approved: true,
            reviewer: "OverseerAI",
            status: .inReview,
            messagePriority: .critical
        )
        
        #expect(model.statusEnum == .inReview)
        #expect(model.messagePriorityEnum == .critical)
    }
    
    @Test("ReviewMessageModel status transition")
    func testStatusTransition() throws {
        let model = ReviewMessageModel(
            messageId: UUID(),
            fromAI: "OverseerAI",
            toAI: "CoderAI",
            timestamp: Date(),
            taskId: "task-001",
            approved: false,
            reviewer: "OverseerAI",
            status: .pending
        )
        
        #expect(model.statusEnum == .pending)
        
        try model.transitionStatus(to: .inReview)
        #expect(model.statusEnum == .inReview)
        
        try model.transitionStatus(to: .approved)
        #expect(model.statusEnum == .approved)
        
        try model.transitionStatus(to: .applied)
        #expect(model.statusEnum == .applied)
    }
}
