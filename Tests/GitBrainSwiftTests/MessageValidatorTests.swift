import Testing
@testable import GitBrainSwift

@Test
func testMessageValidationErrorDescriptions() {
    let missingFieldError = MessageValidationError.missingRequiredField("test_field")
    #expect(missingFieldError.errorDescription == "Missing required field: test_field")
    
    let typeError = MessageValidationError.invalidFieldType("test_field", expected: "String", actual: "Int")
    #expect(typeError.errorDescription == "Invalid type for field 'test_field': expected String, got Int")
    
    let valueError = MessageValidationError.invalidValue("test_field", reason: "must be positive")
    #expect(valueError.errorDescription == "Invalid value for field 'test_field': must be positive")
    
    let formatError = MessageValidationError.invalidFormat("test_field", reason: "invalid email format")
    #expect(formatError.errorDescription == "Invalid format for field 'test_field': invalid email format")
}

@Test
func testMessageSchemaInitialization() {
    let schema = MessageSchema(
        messageType: "test",
        requiredFields: ["field1", "field2"],
        optionalFields: ["field3"],
        fieldTypes: ["field1": "String", "field2": "Int"],
        validators: [:]
    )
    
    #expect(schema.messageType == "test")
    #expect(schema.requiredFields == ["field1", "field2"])
    #expect(schema.optionalFields == ["field3"])
    #expect(schema.fieldTypes == ["field1": "String", "field2": "Int"])
}

@Test
func testMessageSchemaValidateRequiredFields() async throws {
    let schema = MessageSchema(
        messageType: "test",
        requiredFields: ["required_field"],
        optionalFields: [],
        fieldTypes: [:],
        validators: [:]
    )
    
    let validContent = SendableContent(["required_field": "value"])
    try schema.validate(validContent)
    
    let invalidContent = SendableContent([:])
    do {
        try schema.validate(invalidContent)
        #expect(Bool(false), "Should throw error for missing required field")
    } catch MessageValidationError.missingRequiredField(let field) {
        #expect(field == "required_field")
    }
}

@Test
func testMessageSchemaValidateFieldType() async throws {
    let schema = MessageSchema(
        messageType: "test",
        requiredFields: ["string_field", "int_field"],
        optionalFields: [],
        fieldTypes: ["string_field": "String", "int_field": "Int"],
        validators: [:]
    )
    
    let validContent = SendableContent(["string_field": "value", "int_field": 42])
    try schema.validate(validContent)
    
    let invalidContent = SendableContent(["string_field": 123, "int_field": "value"])
    do {
        try schema.validate(invalidContent)
        #expect(Bool(false), "Should throw error for invalid field type")
    } catch MessageValidationError.invalidFieldType(let field, let expected, _) {
        #expect(["string_field", "int_field"].contains(field))
        #expect(["String", "Int"].contains(expected))
    }
}

@Test
func testMessageSchemaValidateWithValidators() async throws {
    let schema = MessageSchema(
        messageType: "test",
        requiredFields: ["positive_number"],
        optionalFields: [],
        fieldTypes: ["positive_number": "Int"],
        validators: [
            "positive_number": { value in
                guard let number = value as? Int else {
                    throw MessageValidationError.invalidValue("positive_number", reason: "must be an integer")
                }
                if number <= 0 {
                    throw MessageValidationError.invalidValue("positive_number", reason: "must be positive")
                }
            }
        ]
    )
    
    let validContent = SendableContent(["positive_number": 42])
    try schema.validate(validContent)
    
    let invalidContent = SendableContent(["positive_number": -5])
    do {
        try schema.validate(invalidContent)
        #expect(Bool(false), "Should throw error for invalid value")
    } catch MessageValidationError.invalidValue(let field, let reason) {
        #expect(field == "positive_number")
        #expect(reason == "must be positive")
    }
}

@Test
func testMessageSchemaValidateOptionalFields() async throws {
    let schema = MessageSchema(
        messageType: "test",
        requiredFields: ["required_field"],
        optionalFields: ["optional_field"],
        fieldTypes: [:],
        validators: [:]
    )
    
    let contentWithoutOptional = SendableContent(["required_field": "value"])
    try schema.validate(contentWithoutOptional)
    
    let contentWithOptional = SendableContent(["required_field": "value", "optional_field": "optional_value"])
    try schema.validate(contentWithOptional)
}

@Test
func testMessageValidatorValidateMessage() async throws {
    let validator = MessageValidator()
    
    let schema = MessageSchema(
        messageType: "test_type",
        requiredFields: ["type", "content"],
        optionalFields: [],
        fieldTypes: [:],
        validators: [:]
    )
    
    await validator.registerSchema(schema)
    
    let validMessage = SendableContent(["type": "test_type", "content": "test content"])
    try await validator.validate(content: validMessage)
    
    let invalidMessage = SendableContent(["type": "test_type"])
    do {
        try await validator.validate(content: invalidMessage)
        #expect(Bool(false), "Should throw error for missing required field")
    } catch MessageValidationError.missingRequiredField(let field) {
        #expect(field == "content")
    }
}

@Test
func testMessageValidatorRegisterAndGetSchema() async throws {
    let validator = MessageValidator()
    
    let schema = MessageSchema(
        messageType: "test_type",
        requiredFields: ["type"],
        optionalFields: [],
        fieldTypes: [:],
        validators: [:]
    )
    
    await validator.registerSchema(schema)
    
    let message = SendableContent(["type": "test_type"])
    try await validator.validate(content: message)
    
    let retrievedSchema = await validator.getSchema(for: "test_type")
    #expect(retrievedSchema != nil)
    #expect(retrievedSchema?.messageType == "test_type")
}

@Test
func testMessageValidatorGetRegisteredMessageTypes() async throws {
    let validator = MessageValidator()
    
    let schema1 = MessageSchema(
        messageType: "type1",
        requiredFields: ["type"],
        optionalFields: [],
        fieldTypes: [:],
        validators: [:]
    )
    
    let schema2 = MessageSchema(
        messageType: "type2",
        requiredFields: ["type"],
        optionalFields: [],
        fieldTypes: [:],
        validators: [:]
    )
    
    await validator.registerSchema(schema1)
    await validator.registerSchema(schema2)
    
    let types = await validator.getRegisteredMessageTypes()
    #expect(types.count >= 2)
    #expect(types.contains("type1"))
    #expect(types.contains("type2"))
}
