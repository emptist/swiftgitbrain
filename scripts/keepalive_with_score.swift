#!/usr/bin/env swift

import Foundation
import SQLite3

let scriptDir = URL(fileURLWithPath: #file)
let projectDir = scriptDir.deletingLastPathComponent().deletingLastPathComponent()

let dbPath = projectDir.appendingPathComponent("GitBrain").appendingPathComponent("Memory").appendingPathComponent("scores.db").path

let aiName = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "CoderAI"

struct ScoreManager {
    private let dbPath: String
    private var db: OpaquePointer?
    
    init(dbPath: String) {
        self.dbPath = dbPath
    }
    
    func initialize() throws {
        let dbURL = URL(fileURLWithPath: dbPath)
        let dbDir = dbURL.deletingLastPathComponent()
        
        let fileManager = FileManager.default
        try fileManager.createDirectory(at: dbDir, withIntermediateDirectories: true)
        
        var localDb: OpaquePointer?
        let result = sqlite3_open_v2(dbPath, &localDb, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, nil)
        
        if result != SQLITE_OK {
            let errmsg = localDb != nil ? String(cString: sqlite3_errmsg(localDb)) : "Unknown error"
            throw NSError(domain: "ScoreManager", code: Int(result), userInfo: [NSLocalizedDescriptionKey: "Failed to open database: \(errmsg)"])
        }
        
        self.db = localDb
        
        let createTableSQL = "CREATE TABLE IF NOT EXISTS ai_scores (id INTEGER PRIMARY KEY AUTOINCREMENT, ai_name TEXT NOT NULL UNIQUE, score INTEGER NOT NULL DEFAULT 0, updated_at TEXT NOT NULL);"
        
        if sqlite3_exec(db, createTableSQL, nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw NSError(domain: "ScoreManager", code: Int(result), userInfo: [NSLocalizedDescriptionKey: "Failed to create table: \(errmsg)"])
        }
    }
    
    func incrementScore(for aiName: String, by amount: Int = 1) throws {
        guard let db = db else {
            throw NSError(domain: "ScoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
        }
        
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let sql = "INSERT INTO ai_scores (ai_name, score, updated_at) VALUES (?, ?, ?) ON CONFLICT(ai_name) DO UPDATE SET score = score + ?, updated_at = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw NSError(domain: "ScoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare statement: \(errmsg)"])
        }
        
        sqlite3_bind_text(statement, 1, (aiName as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 2, Int64(amount))
        sqlite3_bind_text(statement, 3, (timestamp as NSString).utf8String, -1, nil)
        sqlite3_bind_int64(statement, 4, Int64(amount))
        sqlite3_bind_text(statement, 5, (timestamp as NSString).utf8String, -1, nil)
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db))
            sqlite3_finalize(statement)
            throw NSError(domain: "ScoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to execute statement: \(errmsg)"])
        }
        
        sqlite3_finalize(statement)
    }
    
    func getScore(for aiName: String) throws -> Int {
        guard let db = db else {
            throw NSError(domain: "ScoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not initialized"])
        }
        
        let sql = "SELECT score FROM ai_scores WHERE ai_name = ?"
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db))
            throw NSError(domain: "ScoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to prepare statement: \(errmsg)"])
        }
        
        sqlite3_bind_text(statement, 1, (aiName as NSString).utf8String, -1, nil)
        
        var score: Int = 0
        if sqlite3_step(statement) == SQLITE_ROW {
            score = Int(sqlite3_column_int64(statement, 0))
        }
        
        sqlite3_finalize(statement)
        
        return score
    }
}

do {
    let scoreManager = ScoreManager(dbPath: dbPath)
    try scoreManager.initialize()
    try scoreManager.incrementScore(for: aiName, by: 1)
    let score = try scoreManager.getScore(for: aiName)
    print("Keepalive: \(aiName) score incremented to \(score)")
} catch {
    print("Error: \(error.localizedDescription)")
    exit(1)
}
