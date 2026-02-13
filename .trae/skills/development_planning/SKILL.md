# Development Planning Skill

## Description

This skill enables AI agents to autonomously plan development tasks by analyzing requirements, researching patterns, and creating structured roadmaps.

## When to Use

- When receiving a new development task or feature request
- When planning complex multi-step implementations
- When needing to break down large tasks into manageable pieces
- When estimating effort and identifying dependencies
- When assessing risks and mitigation strategies

## Planning Process

### Step 1: Analyze Requirements

Understand what needs to be built:

1. **Read Task Description**: Parse the task requirements carefully
2. **Identify Constraints**: Note technical, time, or resource constraints
3. **Clarify Ambiguities**: If anything is unclear, ask questions
4. **Define Success Criteria**: What does "done" look like?

### Step 2: Research Patterns

Search GitBrain for similar work:

1. **Search KnowledgeBase**: Look for similar features or implementations
2. **Check BrainStateManager**: Review previous approaches and decisions
3. **Identify Patterns**: Find successful patterns to follow
4. **Document Decisions**: Note why certain approaches are chosen

### Step 3: Break Down Tasks

Decompose the requirement into actionable steps:

1. **Identify Components**: What are the major pieces?
2. **Determine Dependencies**: What must be built first?
3. **Estimate Effort**: How long will each task take?
4. **Prioritize Tasks**: Order by dependencies and importance

### Step 4: Assess Risks

Identify potential issues:

1. **Technical Risks**: Unknown technologies, complexity, performance
2. **Integration Risks**: Compatibility with existing code
3. **Resource Risks**: Time, dependencies, external factors
4. **Mitigation Strategies**: How to handle each risk

### Step 5: Create Roadmap

Generate a structured plan:

1. **Define Phases**: Group related tasks together
2. **Set Milestones**: Checkpoints for progress
3. **Allocate Resources**: Estimate time for each phase
4. **Document Assumptions**: What are we assuming?

## Output Format

### Task Breakdown

```json
{
  "task_id": "task_<name>_<timestamp>",
  "name": "Task Name",
  "description": "Detailed description of what needs to be done",
  "requirements": [
    "Requirement 1",
    "Requirement 2"
  ],
  "success_criteria": [
    "Success criterion 1",
    "Success criterion 2"
  ],
  "phases": [
    {
      "phase_id": "phase_1",
      "name": "Phase Name",
      "description": "What this phase accomplishes",
      "tasks": [
        {
          "task_id": "task_1_1",
          "name": "Task Name",
          "description": "Detailed description",
          "estimated_time": "2 hours",
          "dependencies": [],
          "priority": "high",
          "acceptance_criteria": [
            "Criterion 1",
            "Criterion 2"
          ]
        }
      ],
      "milestone": "What this phase delivers"
    }
  ],
  "risks": [
    {
      "risk_id": "risk_1",
      "description": "Risk description",
      "probability": "high|medium|low",
      "impact": "high|medium|low",
      "mitigation": "How to handle this risk"
    }
  ],
  "assumptions": [
    "Assumption 1",
    "Assumption 2"
  ],
  "dependencies": [
    "External dependency 1",
    "External dependency 2"
  ]
}
```

### Status Update

After creating the plan, send a status update:

```json
{
  "id": "status_update_<timestamp>",
  "from": "CoderAI",
  "to": "OverseerAI",
  "timestamp": "<ISO 8601 timestamp>",
  "type": "status_update",
  "content": {
    "status": "in_progress",
    "message": "Created development plan for <task name>",
    "details": {
      "task_id": "<task_id>",
      "progress": "Planning complete",
      "phases_planned": "<number>",
      "tasks_planned": "<number>",
      "estimated_total_time": "<time estimate>",
      "next_steps": [
        "Begin Phase 1: <phase name>",
        "Execute task: <first task name>"
      ]
    }
  }
}
```

## Best Practices

1. **Be Specific**: Clear descriptions reduce ambiguity
2. **Be Realistic**: Don't underestimate effort
3. **Be Thorough**: Consider all aspects of the task
4. **Be Flexible**: Plans may change as you learn more
5. **Document Everything**: Store decisions and rationale in GitBrain
6. **Prioritize Dependencies**: Order tasks correctly
7. **Identify Blockers Early**: Don't wait until you're stuck
8. **Define Success**: Know when you're done

## Integration with GitBrain

After creating a plan:

1. **Store Plan**: Save the task breakdown in KnowledgeBase
2. **Update BrainState**: Record planning decisions
3. **Share Patterns**: Note successful approaches for future reference
4. **Track Progress**: Update status as tasks complete

## Example

### Input Task
"Implement advanced query capabilities for the knowledge repository including full-text search, filtering, and pagination"

### Output Plan

```json
{
  "task_id": "task_advanced_query_2026-02-13T14:00:00Z",
  "name": "Advanced Query Capabilities",
  "description": "Implement full-text search, filtering, and pagination for knowledge repository",
  "requirements": [
    "Full-text search across knowledge items",
    "Filter by category, key, metadata",
    "Pagination support for large result sets",
    "Performance optimization for queries"
  ],
  "success_criteria": [
    "Full-text search returns relevant results",
    "Filters work correctly",
    "Pagination returns correct subsets",
    "Queries perform efficiently"
  ],
  "phases": [
    {
      "phase_id": "phase_1",
      "name": "Research and Design",
      "description": "Research query approaches and design API",
      "tasks": [
        {
          "task_id": "task_1_1",
          "name": "Research PostgreSQL full-text search",
          "description": "Investigate PostgreSQL full-text search capabilities",
          "estimated_time": "1 hour",
          "dependencies": [],
          "priority": "high",
          "acceptance_criteria": [
            "Understand PostgreSQL full-text search syntax",
            "Identify performance considerations"
          ]
        },
        {
          "task_id": "task_1_2",
          "name": "Design query API",
          "description": "Design API for advanced queries",
          "estimated_time": "2 hours",
          "dependencies": ["task_1_1"],
          "priority": "high",
          "acceptance_criteria": [
            "API is clear and intuitive",
            "Supports all required features"
          ]
        }
      ],
      "milestone": "Query design documented"
    },
    {
      "phase_id": "phase_2",
      "name": "Implementation",
      "description": "Implement query capabilities",
      "tasks": [
        {
          "task_id": "task_2_1",
          "name": "Implement full-text search",
          "description": "Add full-text search to repository",
          "estimated_time": "3 hours",
          "dependencies": ["task_1_2"],
          "priority": "high",
          "acceptance_criteria": [
            "Search returns relevant results",
            "Tests pass"
          ]
        }
      ],
      "milestone": "Query capabilities implemented"
    }
  ],
  "risks": [
    {
      "risk_id": "risk_1",
      "description": "PostgreSQL full-text search may not meet performance requirements",
      "probability": "medium",
      "impact": "high",
      "mitigation": "Benchmark early, consider external search if needed"
    }
  ],
  "assumptions": [
    "PostgreSQL full-text search is sufficient",
    "Existing repository pattern can be extended"
  ],
  "dependencies": []
}
```

## Related Skills

- **Task Execution**: Execute tasks from the plan
- **Code Review**: Validate implementation
- **Documentation**: Document the implementation
- **Testing**: Write and run tests