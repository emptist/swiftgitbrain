import Testing
import Foundation
@testable import GitBrainSwift

@Suite("Message Protocol Tests")
struct MessageProtocolTests {
    
    @Test("TaskMessage creates with correct fields")
    func testTaskMessageCreation() async throws {
        let message = TaskMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-001"),
            title: "Implement feature",
            description: "Add user authentication",
            workType: .coding
        )
        
        #expect(message.from == .monitor)
        #expect(message.to == .creator)
        #expect(message.taskId == WorkItemID("task-001"))
        #expect(message.title == "Implement feature")
        #expect(message.status == .pending)
        #expect(message.priority == .normal)
        #expect(message.files == nil)
        #expect(message.deadline == nil)
    }
    
    @Test("TaskMessage with files and deadline")
    func testTaskMessageWithFiles() async throws {
        let files = [
            FileReference(path: "Sources/Test.swift", version: "abc123", metadata: ["branch": "main"])
        ]
        let deadline = Date().addingTimeInterval(3600)
        
        let message = TaskMessage(
            from: .monitor,
            to: .creator,
            priority: .high,
            taskId: WorkItemID("task-002"),
            title: "Fix bug",
            description: "Fix the critical bug",
            workType: .coding,
            status: .pending,
            files: files,
            deadline: deadline
        )
        
        #expect(message.priority == .high)
        #expect(message.files?.count == 1)
        #expect(message.files?[0].path == "Sources/Test.swift")
        #expect(message.deadline != nil)
    }
    
    @Test("CodeMessage creates with correct fields")
    func testCodeMessageCreation() async throws {
        let files = [
            FileReference(path: "Sources/Auth.swift", version: "def456")
        ]
        
        let message = CodeMessage(
            from: .creator,
            to: .monitor,
            codeId: WorkItemID("code-001"),
            title: "Feature implementation",
            description: "Added authentication",
            files: files,
            branch: "feature/auth",
            commitSha: "def456"
        )
        
        #expect(message.from == .creator)
        #expect(message.to == .monitor)
        #expect(message.codeId == WorkItemID("code-001"))
        #expect(message.files.count == 1)
        #expect(message.branch == "feature/auth")
        #expect(message.commitSha == "def456")
        #expect(message.status == .pending)
    }
    
    @Test("ReviewMessage creates with correct fields")
    func testReviewMessageCreation() async throws {
        let message = ReviewMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-001"),
            approved: true,
            reviewer: "Monitor-AI",
            feedback: "Great work!"
        )
        
        #expect(message.from == .monitor)
        #expect(message.to == .creator)
        #expect(message.taskId == WorkItemID("task-001"))
        #expect(message.approved == true)
        #expect(message.reviewer == "Monitor-AI")
        #expect(message.feedback == "Great work!")
        #expect(message.comments == nil)
        #expect(message.status == .pending)
    }
    
    @Test("ReviewMessage with comments")
    func testReviewMessageWithComments() async throws {
        let file = FileReference(path: "Sources/Test.swift", version: "abc123")
        let comments = [
            ReviewComment(
                file: file,
                startLine: 10,
                endLine: 15,
                type: .warning,
                severity: .major,
                message: "Consider error handling"
            )
        ]
        
        let message = ReviewMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-001"),
            approved: false,
            reviewer: "Monitor-AI",
            comments: comments,
            feedback: "Needs improvements"
        )
        
        #expect(message.approved == false)
        #expect(message.comments?.count == 1)
        #expect(message.comments?[0].type == .warning)
        #expect(message.comments?[0].severity == .major)
    }
    
    @Test("ScoreMessage creates with correct fields")
    func testScoreMessageCreation() async throws {
        let message = ScoreMessage(
            from: .creator,
            to: .monitor,
            taskId: WorkItemID("task-001"),
            requestedScore: 10,
            justification: "Completed all requirements"
        )
        
        #expect(message.from == .creator)
        #expect(message.to == .monitor)
        #expect(message.taskId == WorkItemID("task-001"))
        #expect(message.requestedScore == 10)
        #expect(message.awardedScore == nil)
        #expect(message.awardReason == nil)
        #expect(message.rejectReason == nil)
        #expect(message.status == .pending)
    }
    
    @Test("ScoreMessage with award")
    func testScoreMessageWithAward() async throws {
        let message = ScoreMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-001"),
            requestedScore: 10,
            justification: "Completed all requirements",
            awardedScore: 8,
            awardReason: "Good work, minor issues",
            status: .awarded
        )
        
        #expect(message.awardedScore == 8)
        #expect(message.awardReason == "Good work, minor issues")
        #expect(message.status == .awarded)
    }
    
    @Test("FeedbackMessage creates with correct fields")
    func testFeedbackMessageCreation() async throws {
        let message = FeedbackMessage(
            from: .monitor,
            to: .creator,
            feedbackType: .suggestion,
            subject: "Improvement",
            content: "Consider using cache"
        )
        
        #expect(message.from == .monitor)
        #expect(message.to == .creator)
        #expect(message.feedbackType == .suggestion)
        #expect(message.subject == "Improvement")
        #expect(message.content == "Consider using cache")
        #expect(message.relatedTaskId == nil)
        #expect(message.response == nil)
        #expect(message.status == .pending)
    }
    
    @Test("HeartbeatMessage creates with correct fields")
    func testHeartbeatMessageCreation() async throws {
        let message = HeartbeatMessage(
            from: .creator,
            to: .monitor,
            status: .active,
            currentTask: "Implementing feature"
        )
        
        #expect(message.from == .creator)
        #expect(message.to == .monitor)
        #expect(message.status == .active)
        #expect(message.currentTask == "Implementing feature")
        #expect(message.metadata == nil)
    }
    
    @Test("HeartbeatMessage with metadata")
    func testHeartbeatMessageWithMetadata() async throws {
        let metadata = ["memory": "512MB", "cpu": "50%"]
        
        let message = HeartbeatMessage(
            from: .creator,
            to: .monitor,
            status: .active,
            currentTask: "Working",
            metadata: metadata
        )
        
        #expect(message.metadata?["memory"] == "512MB")
        #expect(message.metadata?["cpu"] == "50%")
    }
    
    @Test("Messages use RoleType for type safety")
    func testRoleTypeSafety() async throws {
        let message = TaskMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-002"),
            title: "Test",
            description: "Test",
            workType: .coding
        )
        
        #expect(message.from == .monitor)
        #expect(message.to == .creator)
        
        let allRoles = RoleType.allCases
        #expect(allRoles.count == 2)
        #expect(allRoles.contains(.creator))
        #expect(allRoles.contains(.monitor))
    }
    
    @Test("Messages are Codable")
    func testMessagesCodable() async throws {
        let original = TaskMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-003"),
            title: "Test",
            description: "Test description",
            workType: .coding
        )
        
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(TaskMessage.self, from: data)
        
        #expect(decoded.id == original.id)
        #expect(decoded.from == original.from)
        #expect(decoded.to == original.to)
        #expect(decoded.taskId == original.taskId)
    }
    
    @Test("Messages are Sendable")
    func testMessagesSendable() async throws {
        let message = TaskMessage(
            from: .monitor,
            to: .creator,
            taskId: WorkItemID("task-004"),
            title: "Test",
            description: "Test",
            workType: .coding
        )
        
        Task {
            let _ = message
        }
    }
    
    @Test("FileReference works correctly")
    func testFileReference() async throws {
        let ref1 = FileReference(path: "Test.swift", version: "abc", metadata: ["branch": "main"])
        let ref2 = FileReference(path: "Test.swift", version: "abc", metadata: ["branch": "main"])
        let ref3 = FileReference(path: "Other.swift")
        
        #expect(ref1 == ref2)
        #expect(ref1 != ref3)
        #expect(ref1.path == "Test.swift")
        #expect(ref1.version == "abc")
        #expect(ref1.metadata?["branch"] == "main")
        #expect(ref3.version == nil)
        #expect(ref3.metadata == nil)
    }
    
    @Test("ReviewComment works correctly")
    func testReviewComment() async throws {
        let file = FileReference(path: "Test.swift")
        let comment = ReviewComment(
            file: file,
            startLine: 10,
            endLine: 15,
            type: .error,
            severity: .critical,
            message: "Missing error handling",
            suggestion: "Add try-catch block"
        )
        
        #expect(comment.file.path == "Test.swift")
        #expect(comment.lineRange == 10...15)
        #expect(comment.type == .error)
        #expect(comment.severity == .critical)
        #expect(comment.suggestion == "Add try-catch block")
    }
    
    @Test("CommentSeverity enum values")
    func testCommentSeverity() async throws {
        let allSeverities = CommentSeverity.allCases
        #expect(allSeverities.count == 4)
        #expect(allSeverities.contains(.critical))
        #expect(allSeverities.contains(.major))
        #expect(allSeverities.contains(.minor))
        #expect(allSeverities.contains(.nitpick))
    }

    @Test("MessageID creates with correct fields")
    func testMessageIDCreation() async throws {
        let id1 = MessageID("msg-001")
        let id2 = MessageID("msg-002")
        
        #expect(id1.rawValue == "msg-001")
        #expect(id2.rawValue == "msg-002")
        #expect(id1 != id2)
    }

    @Test("MessageID equality works correctly")
    func testMessageIDEquality() async throws {
        let id1 = MessageID("msg-001")
        let id2 = MessageID("msg-001")
        let id3 = MessageID("msg-002")
        
        #expect(id1 == id2)
        #expect(id1 != id3)
    }

    @Test("WorkItemID creates with correct fields")
    func testWorkItemIDCreation() async throws {
        let id1 = WorkItemID("task-001")
        let id2 = WorkItemID("code-001")
        
        #expect(id1.rawValue == "task-001")
        #expect(id2.rawValue == "code-001")
        #expect(id1 != id2)
    }

    @Test("WorkItemID equality works correctly")
    func testWorkItemIDEquality() async throws {
        let id1 = WorkItemID("task-001")
        let id2 = WorkItemID("task-001")
        let id3 = WorkItemID("task-002")
        
        #expect(id1 == id2)
        #expect(id1 != id3)
    }

    @Test("FileReference creates with correct fields")
    func testFileReferenceCreation() async throws {
        let ref1 = FileReference(path: "Test.swift", version: "abc", metadata: ["branch": "main"])
        let ref2 = FileReference(path: "Other.swift")
        
        #expect(ref1.path == "Test.swift")
        #expect(ref1.version == "abc")
        #expect(ref1.metadata?["branch"] == "main")
        #expect(ref2.path == "Other.swift")
        #expect(ref2.version == nil)
        #expect(ref2.metadata == nil)
    }

    @Test("FileReference equality works correctly")
    func testFileReferenceEquality() async throws {
        let ref1 = FileReference(path: "Test.swift", version: "abc", metadata: ["branch": "main"])
        let ref2 = FileReference(path: "Test.swift", version: "abc", metadata: ["branch": "main"])
        let ref3 = FileReference(path: "Other.swift")
        
        #expect(ref1 == ref2)
        #expect(ref1 != ref3)
    }

    @Test("WorkType enum values")
    func testWorkTypeEnum() async throws {
        let allTypes = WorkType.allCases
        
        #expect(allTypes.contains(.coding))
        #expect(allTypes.contains(.review))
        #expect(allTypes.contains(.testing))
        #expect(allTypes.contains(.documentation))
        #expect(allTypes.contains(.research))
        #expect(allTypes.contains(.analysis))
        #expect(allTypes.contains(.writing))
        #expect(allTypes.contains(.translation))
    }
}
