import Foundation

public enum MessageValidationError: Error, LocalizedError {
    case missingRequiredField(String)
    case invalidFieldType(String, expected: String, actual: String)
    case invalidValue(String, reason: String)
    case invalidFormat(String, reason: String)
    
    public var errorDescription: String? {
        switch self {
        case .missingRequiredField(let field):
            return "Missing required field: \(field)"
        case .invalidFieldType(let field, let expected, let actual):
            return "Invalid type for field '\(field)': expected \(expected), got \(actual)"
        case .invalidValue(let field, let reason):
            return "Invalid value for field '\(field)': \(reason)"
        case .invalidFormat(let field, let reason):
            return "Invalid format for field '\(field)': \(reason)"
        }
    }
}

public struct MessageSchema {
    public let messageType: String
    public let requiredFields: [String]
    public let optionalFields: [String]
    public let fieldTypes: [String: String]
    public let validators: [String: (Any) throws -> Void]
    
    public init(
        messageType: String,
        requiredFields: [String],
        optionalFields: [String] = [],
        fieldTypes: [String: String] = [:],
        validators: [String: (Any) throws -> Void] = [:]
    ) {
        self.messageType = messageType
        self.requiredFields = requiredFields
        self.optionalFields = optionalFields
        self.fieldTypes = fieldTypes
        self.validators = validators
    }
    
    public func validate(_ content: SendableContent) throws {
        let data = content.toAnyDict()
        
        for field in requiredFields {
            if data[field] == nil {
                throw MessageValidationError.missingRequiredField(field)
            }
        }
        
        for (field, expectedType) in fieldTypes {
            if let value = data[field] {
                try validateFieldType(field: field, value: value, expectedType: expectedType)
            }
        }
        
        for (field, validator) in validators {
            if let value = data[field] {
                try validator(value)
            }
        }
    }
    
    private func validateFieldType(field: String, value: Any, expectedType: String) throws {
        let actualType = getType(of: value)
        
        if expectedType == "Bool" && actualType == "Int" {
            if let intValue = value as? Int, (intValue == 0 || intValue == 1) {
                return
            }
        }
        
        if actualType != expectedType {
            throw MessageValidationError.invalidFieldType(field, expected: expectedType, actual: actualType)
        }
    }
    
    private func getType(of value: Any) -> String {
        if value is String { return "String" }
        if value is Int { return "Int" }
        if value is Double { return "Double" }
        if value is Bool { return "Bool" }
        if value is NSNumber {
            let nsNumber = value as! NSNumber
            if nsNumber === kCFBooleanTrue || nsNumber === kCFBooleanFalse {
                return "Bool"
            }
            let objCType = nsNumber.objCType
            let typeStr = String(cString: objCType)
            if typeStr == "c" { return "Bool" }
            if typeStr == "C" { return "Bool" }
            if typeStr == "i" || typeStr == "s" || typeStr == "l" || typeStr == "q" { return "Int" }
            if typeStr == "I" || typeStr == "S" || typeStr == "L" || typeStr == "Q" { return "Int" }
            if typeStr == "f" || typeStr == "d" { return "Double" }
            if typeStr == "B" { return "Bool" }
            return typeStr
        }
        if value is [String] { return "[String]" }
        if value is [Int] { return "[Int]" }
        if value is [String: Any] { return "[String: Any]" }
        if let array = value as? [Any] {
            if array.isEmpty {
                return "[Any]"
            }
            if let first = array.first, first is [String: Any] {
                return "[[String: Any]]"
            }
            return "[Any]"
        }
        return "Any"
    }
}

public actor MessageValidator {
    private var schemas: [String: MessageSchema] = [:]
    
    public init() {
        schemas = Self.createDefaultSchemas()
    }
    
    private static func createDefaultSchemas() -> [String: MessageSchema] {
        var schemas: [String: MessageSchema] = [:]
        
        schemas["task"] = MessageSchema(
            messageType: "task",
            requiredFields: ["task_id", "description", "task_type"],
            optionalFields: ["priority", "files", "deadline"],
            fieldTypes: [
                "task_id": "String",
                "description": "String",
                "task_type": "String",
                "priority": "Int",
                "files": "[String]",
                "deadline": "String"
            ],
            validators: [
                "task_type": { value in
                    guard let taskType = value as? String,
                          ["coding", "review", "testing", "documentation"].contains(taskType) else {
                        throw MessageValidationError.invalidValue("task_type", reason: "must be one of: coding, review, testing, documentation")
                    }
                },
                "priority": { value in
                    guard let priority = value as? Int, priority >= 1 && priority <= 10 else {
                        throw MessageValidationError.invalidValue("priority", reason: "must be between 1 and 10")
                    }
                }
            ]
        )
        
        schemas["code"] = MessageSchema(
            messageType: "code",
            requiredFields: ["task_id", "code", "language"],
            optionalFields: ["files", "description", "commit_hash"],
            fieldTypes: [
                "task_id": "String",
                "code": "String",
                "language": "String",
                "files": "[String]",
                "description": "String",
                "commit_hash": "String"
            ],
            validators: [
                "language": { value in
                    guard let language = value as? String,
                          ["swift", "python", "javascript", "rust", "go", "java"].contains(language.lowercased()) else {
                        throw MessageValidationError.invalidValue("language", reason: "must be a supported language")
                    }
                }
            ]
        )
        
        schemas["review"] = MessageSchema(
            messageType: "review",
            requiredFields: ["task_id", "approved", "reviewer"],
            optionalFields: ["comments", "feedback", "files_reviewed"],
            fieldTypes: [
                "task_id": "String",
                "approved": "Bool",
                "reviewer": "String",
                "comments": "[[String: Any]]",
                "feedback": "String",
                "files_reviewed": "[String]"
            ],
            validators: [
                "comments": { value in
                    guard let comments = value as? [[String: Any]] else { return }
                    for comment in comments {
                        guard let line = comment["line"] as? Int,
                              line >= 0 else {
                            throw MessageValidationError.invalidValue("comments[].line", reason: "must be a non-negative integer")
                        }
                        guard let type = comment["type"] as? String,
                              ["error", "warning", "suggestion", "info"].contains(type) else {
                            throw MessageValidationError.invalidValue("comments[].type", reason: "must be one of: error, warning, suggestion, info")
                        }
                        guard comment["message"] is String else {
                            throw MessageValidationError.invalidFormat("comments[]", reason: "must have a 'message' field")
                        }
                    }
                }
            ]
        )
        
        schemas["feedback"] = MessageSchema(
            messageType: "feedback",
            requiredFields: ["task_id", "message"],
            optionalFields: ["severity", "suggestions", "files"],
            fieldTypes: [
                "task_id": "String",
                "message": "String",
                "severity": "String",
                "suggestions": "[String]",
                "files": "[String]"
            ],
            validators: [
                "severity": { value in
                    guard let severity = value as? String,
                          ["critical", "major", "minor", "info"].contains(severity) else {
                        throw MessageValidationError.invalidValue("severity", reason: "must be one of: critical, major, minor, info")
                    }
                }
            ]
        )
        
        schemas["approval"] = MessageSchema(
            messageType: "approval",
            requiredFields: ["task_id", "approver"],
            optionalFields: ["approved_at", "commit_hash", "notes"],
            fieldTypes: [
                "task_id": "String",
                "approver": "String",
                "approved_at": "String",
                "commit_hash": "String",
                "notes": "String"
            ]
        )
        
        schemas["rejection"] = MessageSchema(
            messageType: "rejection",
            requiredFields: ["task_id", "rejecter", "reason"],
            optionalFields: ["rejected_at", "feedback", "suggestions"],
            fieldTypes: [
                "task_id": "String",
                "rejecter": "String",
                "reason": "String",
                "rejected_at": "String",
                "feedback": "String",
                "suggestions": "[String]"
            ]
        )
        
        schemas["status"] = MessageSchema(
            messageType: "status",
            requiredFields: ["status"],
            optionalFields: ["message", "progress", "current_task", "timestamp"],
            fieldTypes: [
                "status": "String",
                "message": "String",
                "progress": "Int",
                "current_task": "[String: Any]",
                "timestamp": "String"
            ],
            validators: [
                "status": { value in
                    guard let status = value as? String,
                          ["idle", "working", "waiting", "completed", "error"].contains(status) else {
                        throw MessageValidationError.invalidValue("status", reason: "must be one of: idle, working, waiting, completed, error")
                    }
                },
                "progress": { value in
                    guard let progress = value as? Int, progress >= 0 && progress <= 100 else {
                        throw MessageValidationError.invalidValue("progress", reason: "must be between 0 and 100")
                    }
                }
            ]
        )
        
        schemas["heartbeat"] = MessageSchema(
            messageType: "heartbeat",
            requiredFields: ["ai_name", "role"],
            optionalFields: ["timestamp", "status", "capabilities"],
            fieldTypes: [
                "ai_name": "String",
                "role": "String",
                "timestamp": "String",
                "status": "String",
                "capabilities": "[String]"
            ],
            validators: [
                "role": { value in
                    guard let role = value as? String,
                          ["coder", "overseer"].contains(role) else {
                        throw MessageValidationError.invalidValue("role", reason: "must be either 'coder' or 'overseer'")
                    }
                }
            ]
        )
        
        return schemas
    }
    
    public func validate(message: [String: Any]) throws {
        guard let messageType = message["type"] as? String else {
            throw MessageValidationError.missingRequiredField("type")
        }
        
        guard let schema = schemas[messageType] else {
            throw MessageValidationError.invalidValue("type", reason: "unknown message type: \(messageType)")
        }
        
        try schema.validate(SendableContent(message))
    }
    
    public func validate(content: SendableContent) throws {
        let data = content.toAnyDict()
        try validate(message: data)
    }
    
    public func registerSchema(_ schema: MessageSchema) {
        schemas[schema.messageType] = schema
    }
    
    public func getSchema(for messageType: String) -> MessageSchema? {
        return schemas[messageType]
    }
    
    public func getRegisteredMessageTypes() -> [String] {
        return schemas.keys.sorted()
    }
}
