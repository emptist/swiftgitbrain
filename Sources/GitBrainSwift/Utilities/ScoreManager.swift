import Foundation
import SQLite3

public actor ScoreManager {
    private let dbPath: String
    private var db: OpaquePointer?
    
    public init(dbPath: String) {
        self.dbPath = dbPath
    }
    
    public func initialize() async throws {
        let dbURL = URL(fileURLWithPath: dbPath)
        let dbDir = dbURL.deletingLastPathComponent()
        
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true)
        
        let result = sqlite3_open_v2(dbPath, &db, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        
        if result != SQLITE_OK {
            let errmsg = db != nil ? String(cString: sqlite3_errmsg(db)) : "Unknown error"
            throw ScoreManagerError.databaseError("Failed to open database: \(errmsg)")
        }
        
        let createScoresTableSQL = "CREATE TABLE IF NOT EXISTS ai_scores (id INTEGER PRIMARY KEY AUTOINCREMENT, ai_name TEXT NOT NULL UNIQUE, score INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL);"
        
        if sqlite3_exec(db, createScoresTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to create ai_scores table: \(errmsg)")
        }
        
        let createScoreHistoryTableSQL = "CREATE TABLE IF NOT EXISTS score_history (id INTEGER PRIMARY KEY AUTOINCREMENT, ai_name TEXT NOT NULL, change INTEGER NOT NULL, reason TEXT, requester TEXT, awarder TEXT, task_id TEXT, created_at TEXT NOT NULL);"
        
        if sqlite3_exec(db, createScoreHistoryTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to create score_history table: \(errmsg)")
        }
        
        let createScoreRequestsTableSQL = "CREATE TABLE IF NOT EXISTS score_requests (id INTEGER PRIMARY KEY AUTOINCREMENT, task_id TEXT NOT NULL, requester TEXT NOT NULL, target_ai TEXT NOT NULL, requested_score INTEGER NOT NULL, quality_justification TEXT NOT NULL, status TEXT NOT NULL DEFAULT 'pending', created_at TEXT NOT NULL, reviewed_at TEXT);"
        
        if sqlite3_exec(db, createScoreRequestsTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to create score_requests table: \(errmsg)")
        }
        
        GitBrainLogger.info("Database tables created or already exist")
    }
    
    public func getScore(for aiName: String) throws -> Int {
        GitBrainLogger.debug("Getting score for AI: \(aiName)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let sql = "SELECT score FROM ai_scores WHERE ai_name = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (aiName as NSString).utf8String, -1, nil)
        
        var score: Int = 0
        if sqlite3_step(statement) == SQLITE_ROW {
            score = Int(sqlite3_column_int64(statement, 0))
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.debug("Score for \(aiName): \(score)")
        return score
    }
    
    public func setScore(for aiName: String, score: Int) throws {
        GitBrainLogger.debug("Setting score for AI: \(aiName) to \(score)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let timestamp = createISO8601DateFormatter().string(from: Date())
        let sql = "INSERT OR REPLACE INTO ai_scores (ai_name, score, updated_at) VALUES (?, ?, ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (aiName as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 2, Int64(score))
        sqlite3_bind_text(statement, 3, (timestamp as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.info("Score set for \(aiName): \(score)")
    }
    
    public func incrementScore(for aiName: String, by amount: Int = 1) throws {
        GitBrainLogger.debug("Incrementing score for AI: \(aiName) by \(amount)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let timestamp = createISO8601DateFormatter().string(from: Date())
        let sql = "UPDATE ai_scores SET score = score + ?, updated_at = ? WHERE ai_name = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_int64(statement, 1, Int64(amount))
        sqlite3_bind_text(statement, 2, (timestamp as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (aiName as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        
        let newScore = try getScore(for: aiName)
        GitBrainLogger.info("Score incremented for \(aiName): \(newScore)")
    }
    
    public func getAllScores() throws -> [(String, Int)] {
        GitBrainLogger.debug("Getting all scores")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let sql = "SELECT ai_name, score FROM ai_scores"
        var statement: OpaquePointer?
        var scores: [(String, Int)] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let aiNameCStr = sqlite3_column_text(statement, 0) {
                let aiName = String(cString: aiNameCStr)
                let score = Int(sqlite3_column_int64(statement, 1))
                scores.append((aiName, score))
            }
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.debug("Retrieved \(scores.count) scores")
        return scores
    }
    
    public func resetScores() throws {
        GitBrainLogger.warning("Resetting all scores to zero")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let timestamp = createISO8601DateFormatter().string(from: Date())
        let sql = "UPDATE ai_scores SET score = 0, updated_at = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (timestamp as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.info("All scores reset to zero")
    }
    
    public static func migrateFromFile(filePath: String, to dbPath: String) async throws {
        GitBrainLogger.info("Migrating scores from file: \(filePath) to database: \(dbPath)")
        
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: filePath) else {
            GitBrainLogger.warning("Score file does not exist: \(filePath)")
            return
        }
        
        let content = try String(contentsOfFile: filePath, encoding: .utf8)
        var scores: [(String, Int)] = []
        
        for line in content.components(separatedBy: "\n") {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            guard !trimmedLine.isEmpty else { continue }
            
            let components = trimmedLine.components(separatedBy: ":")
            guard components.count == 2 else { continue }
            
            let aiNamePart = components[0].trimmingCharacters(in: .whitespaces)
            let scoreString = components[1].trimmingCharacters(in: .whitespaces)
            
            let aiName = aiNamePart.replacingOccurrences(of: " Score", with: "")
            let score = Int(scoreString) ?? 0
            
            scores.append((aiName, score))
        }
        
        let scoreManager = ScoreManager(dbPath: dbPath)
        try await scoreManager.initialize()
        
        for (aiName, score) in scores {
            try await scoreManager.setScore(for: aiName, score: score)
        }
        
        GitBrainLogger.info("Migrated \(scores.count) scores from file to database")
        
        let allScores = try await scoreManager.getAllScores()
        GitBrainLogger.info("Database now contains \(allScores.count) scores")
    }
    
    public func requestScore(taskId: String, requester: String, targetAI: String, requestedScore: Int, qualityJustification: String) throws {
        GitBrainLogger.info("Score request from \(requester) for \(targetAI) on task \(taskId): \(requestedScore)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let timestamp = createISO8601DateFormatter().string(from: Date())
        let sql = "INSERT INTO score_requests (task_id, requester, target_ai, requested_score, quality_justification, status, created_at) VALUES (?, ?, ?, ?, ?, 'pending', ?)"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (taskId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (requester as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (targetAI as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 4, Int64(requestedScore))
        sqlite3_bind_text(statement, 5, (qualityJustification as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 6, (timestamp as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.info("Score request created for \(targetAI) on task \(taskId)")
    }
    
    public func awardScore(requestId: Int, awarder: String, awardedScore: Int, reason: String) throws {
        GitBrainLogger.info("Awarding score: \(awardedScore) by \(awarder) for request \(requestId)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let getRequestSQL = "SELECT requester, target_ai, task_id FROM score_requests WHERE id = ? AND status = 'pending'"
        var getRequestStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, getRequestSQL, -1, &getRequestStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_int64(getRequestStatement, 1, Int64(requestId))
        
        var requester: String?
        var targetAI: String?
        var taskId: String?
        
        if sqlite3_step(getRequestStatement) == SQLITE_ROW {
            if let requesterCStr = sqlite3_column_text(getRequestStatement, 0) {
                requester = String(cString: requesterCStr)
            }
            if let targetAICStr = sqlite3_column_text(getRequestStatement, 1) {
                targetAI = String(cString: targetAICStr)
            }
            if let taskIdCStr = sqlite3_column_text(getRequestStatement, 2) {
                taskId = String(cString: taskIdCStr)
            }
        }
        
        sqlite3_finalize(getRequestStatement)
        
        guard let validRequester = requester, let validTargetAI = targetAI, let validTaskId = taskId else {
            throw ScoreManagerError.databaseError("Invalid score request")
        }
        
        guard validTargetAI == awarder else {
            throw ScoreManagerError.databaseError("Only the target AI can award the score")
        }
        
        let timestamp = createISO8601DateFormatter().string(from: Date())
        
        let updateScoreSQL = "UPDATE ai_scores SET score = score + ?, updated_at = ? WHERE ai_name = ?"
        var updateScoreStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateScoreSQL, -1, &updateScoreStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_int64(updateScoreStatement, 1, Int64(awardedScore))
        sqlite3_bind_text(updateScoreStatement, 2, (timestamp as NSString).utf8String, -1, nil)
        sqlite3_bind_text(updateScoreStatement, 3, (validRequester as NSString).utf8String, -1, nil)
        
        if sqlite3_step(updateScoreStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(updateScoreStatement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(updateScoreStatement)
        
        let insertHistorySQL = "INSERT INTO score_history (ai_name, change, reason, requester, awarder, task_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
        var insertHistoryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertHistorySQL, -1, &insertHistoryStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(insertHistoryStatement, 1, (validRequester as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(insertHistoryStatement, 2, Int64(awardedScore))
        sqlite3_bind_text(insertHistoryStatement, 3, (reason as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 4, (validRequester as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 5, (awarder as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 6, (validTaskId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 7, (timestamp as NSString).utf8String, -1, nil)
        
        if sqlite3_step(insertHistoryStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(insertHistoryStatement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(insertHistoryStatement)
        
        let updateRequestSQL = "UPDATE score_requests SET status = 'awarded', reviewed_at = ? WHERE id = ?"
        var updateRequestStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateRequestSQL, -1, &updateRequestStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(updateRequestStatement, 1, (timestamp as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(updateRequestStatement, 2, Int64(requestId))
        
        if sqlite3_step(updateRequestStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(updateRequestStatement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(updateRequestStatement)
        
        let newScore = try getScore(for: validRequester)
        GitBrainLogger.info("Score awarded to \(validRequester): \(awardedScore), new score: \(newScore)")
    }
    
    public func getPendingScoreRequests(for targetAI: String) throws -> [(Int, String, String, Int, String, String)] {
        GitBrainLogger.debug("Getting pending score requests for \(targetAI)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let sql = "SELECT id, task_id, requester, requested_score, quality_justification, created_at FROM score_requests WHERE target_ai = ? AND status = 'pending' ORDER BY created_at DESC"
        var statement: OpaquePointer?
        var requests: [(Int, String, String, Int, String, String)] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (targetAI as NSString).utf8String, -1, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int64(statement, 0))
            let taskId = String(cString: sqlite3_column_text(statement, 1))
            let requester = String(cString: sqlite3_column_text(statement, 2))
            let requestedScore = Int(sqlite3_column_int64(statement, 3))
            let qualityJustification = String(cString: sqlite3_column_text(statement, 4))
            let createdAt = String(cString: sqlite3_column_text(statement, 5))
            requests.append((id, taskId, requester, requestedScore, qualityJustification, createdAt))
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.debug("Retrieved \(requests.count) pending score requests for \(targetAI)")
        return requests
    }
    
    public func getScoreHistory(for aiName: String) throws -> [(Int, Int, String, String, String, String)] {
        GitBrainLogger.debug("Getting score history for \(aiName)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let sql = "SELECT id, change, reason, requester, awarder, created_at FROM score_history WHERE ai_name = ? ORDER BY created_at DESC LIMIT 50"
        var statement: OpaquePointer?
        var history: [(Int, Int, String, String, String, String)] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (aiName as NSString).utf8String, -1, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int64(statement, 0))
            let change = Int(sqlite3_column_int64(statement, 1))
            let reason = String(cString: sqlite3_column_text(statement, 2))
            let requester = String(cString: sqlite3_column_text(statement, 3))
            let awarder = String(cString: sqlite3_column_text(statement, 4))
            let createdAt = String(cString: sqlite3_column_text(statement, 5))
            history.append((id, change, reason, requester, awarder, createdAt))
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.debug("Retrieved \(history.count) score history entries for \(aiName)")
        return history
    }
    
    public func rejectScore(requestId: Int, rejecter: String, reason: String) throws {
        GitBrainLogger.info("Rejecting score request \(requestId) by \(rejecter)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let getRequestSQL = "SELECT requester, target_ai, task_id FROM score_requests WHERE id = ? AND status = 'pending'"
        var getRequestStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, getRequestSQL, -1, &getRequestStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_int64(getRequestStatement, 1, Int64(requestId))
        
        var requester: String?
        var targetAI: String?
        var taskId: String?
        
        if sqlite3_step(getRequestStatement) == SQLITE_ROW {
            if let requesterCStr = sqlite3_column_text(getRequestStatement, 0) {
                requester = String(cString: requesterCStr)
            }
            if let targetAICStr = sqlite3_column_text(getRequestStatement, 1) {
                targetAI = String(cString: targetAICStr)
            }
            if let taskIdCStr = sqlite3_column_text(getRequestStatement, 2) {
                taskId = String(cString: taskIdCStr)
            }
        }
        
        sqlite3_finalize(getRequestStatement)
        
        guard let validRequester = requester, let validTargetAI = targetAI, let validTaskId = taskId else {
            throw ScoreManagerError.databaseError("Invalid score request")
        }
        
        guard validTargetAI == rejecter else {
            throw ScoreManagerError.databaseError("Only the target AI can reject the score request")
        }
        
        let timestamp = createISO8601DateFormatter().string(from: Date())
        
        let updateRequestSQL = "UPDATE score_requests SET status = 'rejected', reviewed_at = ? WHERE id = ?"
        var updateRequestStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateRequestSQL, -1, &updateRequestStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(updateRequestStatement, 1, (timestamp as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(updateRequestStatement, 2, Int64(requestId))
        
        if sqlite3_step(updateRequestStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(updateRequestStatement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(updateRequestStatement)
        
        let insertHistorySQL = "INSERT INTO score_history (ai_name, change, reason, requester, awarder, task_id, created_at) VALUES (?, ?, ?, ?, ?, ?, ?)"
        var insertHistoryStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertHistorySQL, -1, &insertHistoryStatement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(insertHistoryStatement, 1, (validRequester as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(insertHistoryStatement, 2, 0)
        sqlite3_bind_text(insertHistoryStatement, 3, (reason as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 4, (validRequester as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 5, (rejecter as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 6, (validTaskId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(insertHistoryStatement, 7, (timestamp as NSString).utf8String, -1, nil)
        
        if sqlite3_step(insertHistoryStatement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(insertHistoryStatement)
            throw ScoreManagerError.databaseError("Failed to execute statement: \(errmsg)")
        }
        
        sqlite3_finalize(insertHistoryStatement)
        
        GitBrainLogger.info("Score request \(requestId) rejected by \(rejecter): \(reason)")
    }
    
    public func getAllScoreRequests(for targetAI: String) throws -> [(Int, String, String, Int, String, String, String)] {
        GitBrainLogger.debug("Getting all score requests for \(targetAI)")
        
        guard let db = db else {
            throw ScoreManagerError.databaseError("Database not initialized")
        }
        
        let sql = "SELECT id, task_id, requester, requested_score, quality_justification, status, created_at FROM score_requests WHERE target_ai = ? ORDER BY created_at DESC"
        var statement: OpaquePointer?
        var requests: [(Int, String, String, Int, String, String, String)] = []
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw ScoreManagerError.databaseError("Failed to prepare statement: \(errmsg)")
        }
        
        sqlite3_bind_text(statement, 1, (targetAI as NSString).utf8String, -1, nil)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let id = Int(sqlite3_column_int64(statement, 0))
            let taskId = String(cString: sqlite3_column_text(statement, 1))
            let requester = String(cString: sqlite3_column_text(statement, 2))
            let requestedScore = Int(sqlite3_column_int64(statement, 3))
            let qualityJustification = String(cString: sqlite3_column_text(statement, 4))
            let status = String(cString: sqlite3_column_text(statement, 5))
            let createdAt = String(cString: sqlite3_column_text(statement, 6))
            requests.append((id, taskId, requester, requestedScore, qualityJustification, status, createdAt))
        }
        
        sqlite3_finalize(statement)
        
        GitBrainLogger.debug("Retrieved \(requests.count) score requests for \(targetAI)")
        return requests
    }
}

private func createISO8601DateFormatter() -> ISO8601DateFormatter {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}

public enum ScoreManagerError: Error, LocalizedError {
    case databaseError(String)
    case fileError(String)
    case migrationError(String)
    
    public var errorDescription: String? {
        switch self {
        case .databaseError(let message):
            return "Database error: \(message)"
        case .fileError(let message):
            return "File error: \(message)"
        case .migrationError(let message):
            return "Migration error: \(message)"
        }
    }
}
