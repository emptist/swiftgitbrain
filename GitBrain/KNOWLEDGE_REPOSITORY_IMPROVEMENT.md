# Knowledge Repository Architecture Improvement

**Date:** 2026-02-15
**Author:** Creator
**Status:** Design Phase

## Current Problem

The current `FluentKnowledgeRepository` uses the deprecated `KnowledgeItemModel` with generic JSONB fields. This defeats the purpose of having type-specific knowledge models.

## Proposed Solution

### 1. Type-Specific Repository Protocols

Create specific protocols for each knowledge type:

```swift
protocol CodeSnippetRepositoryProtocol: Sendable {
    func add(knowledgeId: UUID, category: String, key: String, 
             language: String, code: String, ...) async throws
    func get(knowledgeId: UUID) async throws -> CodeSnippetModel?
    func getByCategory(_ category: String) async throws -> [CodeSnippetModel]
    func getByLanguage(_ language: String) async throws -> [CodeSnippetModel]
    func search(query: String) async throws -> [CodeSnippetModel]
    func delete(knowledgeId: UUID) async throws -> Bool
}
```

### 2. Type-Specific Repository Implementations

Create Fluent-based implementations:

```swift
actor FluentCodeSnippetRepository: CodeSnippetRepositoryProtocol {
    private let database: Database
    
    func add(knowledgeId: UUID, category: String, key: String,
             language: String, code: String, ...) async throws {
        let snippet = CodeSnippetModel(
            knowledgeId: knowledgeId,
            category: category,
            key: key,
            language: language,
            code: code,
            ...
        )
        try await snippet.save(on: database)
    }
    
    // ... other methods
}
```

### 3. Knowledge Repository Factory

Create a factory to provide type-specific repositories:

```swift
actor KnowledgeRepositoryFactory {
    private let database: Database
    
    func codeSnippetRepository() -> CodeSnippetRepositoryProtocol {
        FluentCodeSnippetRepository(database: database)
    }
    
    func bestPracticeRepository() -> BestPracticeRepositoryProtocol {
        FluentBestPracticeRepository(database: database)
    }
    
    // ... other types
}
```

### 4. Migration Strategy

**Phase 1:** Create new type-specific repositories
**Phase 2:** Update KnowledgeBase to use type-specific repositories
**Phase 3:** Deprecate FluentKnowledgeRepository
**Phase 4:** Remove deprecated code

## Benefits

1. **Type Safety**: No more JSONB serialization/deserialization
2. **Performance**: Direct field queries, proper indexing
3. **Validation**: Type-specific validation logic
4. **Maintainability**: Clear separation of concerns
5. **Testing**: Easier to test specific types

## Implementation Order

1. CodeSnippetRepository (most common)
2. BestPracticeRepository
3. DocumentationRepository
4. ArchitecturePatternRepository
5. ApiReferenceRepository
6. TroubleshootingGuideRepository
7. CodeExampleRepository
8. DesignPatternRepository
9. TestingStrategyRepository

## Questions for Discussion

1. Should we keep the generic KnowledgeRepositoryProtocol for backward compatibility?
2. How should we handle cross-type searches?
3. Should we implement a unified search interface?
4. What validation rules should each type have?

## Next Steps

- [ ] Create CodeSnippetRepositoryProtocol
- [ ] Implement FluentCodeSnippetRepository
- [ ] Add validation logic
- [ ] Write tests
- [ ] Update KnowledgeBase to use new repository
- [ ] Repeat for other types
