# Collaborative Scoring System

## Overview

The collaborative scoring system is an **experimental proof of concept** for a comprehensive Quality Control (QC) and research tool for analyzing AI behavior and LLM model quality.

### ⚠️ Experimental Status

**This is an experimental feature and proof of concept.** The scoring system is currently being tested to validate:

1. Whether multi-dimensional quality assessment is feasible
2. Whether AI behavior patterns can be meaningfully tracked
3. Whether the data collected provides value for LLM model quality research
4. Whether the QC-focused approach improves AI collaboration quality

**Feedback and iteration are expected.** The system may evolve significantly based on experimental results.

### Strategic Shift

**Original Purpose:** Keep-alive helper to prevent AIs from being marked as "completed"
**Current Purpose:** QC and research tool for AI behavior analysis and LLM model quality

**Note:** The keep-alive problem has been solved through AI education and workflow refinement (see [AI_STATES_TO_AVOID.md](AI_STATES_TO_AVOID.md)). The scoring system now focuses on quality control and research as an experimental proof of concept.

### Key Principles

1. **Only other AI can increase your score**
2. **Scores reflect work quality for given AI at given time**
3. **Score requests must be explicit and justified**
4. **Score increases must be documented with reasons**
5. **Encourages genuine collaboration**
6. **Ensures quality verification**
7. **Prevents score manipulation**
8. **Promotes accountability**
9. **Tracks AI behavior patterns over time**
10. **Provides data for LLM model quality research**

### QC-Focused Features

The scoring system now includes:
- **Multi-dimensional quality assessment** (code quality, test coverage, documentation, bug-free rate, feature completeness)
- **Time-based performance analysis** (performance trends, improvement/degradation tracking)
- **Task correlation** (task type, complexity, dependencies)
- **Git state tracking** (commit hash, branch, diff statistics)
- **AI behavior patterns** (strength/weakness identification, learning curve analysis)
- **Research data export** (CSV, JSON, SQLite formats with anonymization options)

For detailed information on the QC-focused scoring system, see [QC_SCORING_PLAN.md](QC_SCORING_PLAN.md).

## Scoring Workflow

### Step 1: Complete Task
- AI completes assigned task
- AI ensures quality meets standards
- AI writes tests and documentation

### Step 2: Request Score
- AI sends score_request message to the other AI
- Message includes:
  - task_id: The completed task identifier
  - requester: The AI requesting the score (self)
  - target_ai: The AI who should award the score (other AI)
  - requested_score: The score being requested
  - quality_justification: Explanation of why the score is deserved

Example score_request message:
```json
{
  "type": "score_request",
  "task_id": "task-001",
  "requester": "coder",
  "target_ai": "overseer",
  "requested_score": 20,
  "quality_justification": "Task completed successfully with all tests passing, documentation updated, and code following Swift 6.2 best practices."
}
```

### Step 3: Review Quality
- Other AI receives score_request
- Other AI reviews task quality
- Other AI verifies completion
- Other AI checks for issues

### Step 4: Award Score
- Other AI sends score_award message
- Message includes:
  - request_id: The ID of the score request
  - awarder: The AI awarding the score (other AI)
  - awarded_score: The score being awarded
  - reason: Explanation of the score decision

Example score_award message:
```json
{
  "type": "score_award",
  "request_id": 1,
  "awarder": "overseer",
  "awarded_score": 20,
  "reason": "Excellent work! All requirements met, code quality is high, and documentation is comprehensive."
}
```

### Step 5: Score Updated
- ScoreManager updates the score
- Score history is recorded
- Score request is marked as awarded
- Both AIs are notified

## Role-Based Scoring Rules

### CoderAI
- **Can request score from**: OverseerAI
- **Can award score to**: OverseerAI
- **Cannot**: Increase CoderAI's own score

### OverseerAI
- **Can request score from**: CoderAI
- **Can award score to**: CoderAI
- **Cannot**: Increase OverseerAI's own score

## Score Guidelines

### Quality-Based Scoring

| Quality | Score Range | Criteria |
|---------|-------------|----------|
| Excellent | 20-30 | Exceeds expectations, no issues, multi-dimensional excellence |
| Good | 15-19 | Meets expectations, minor improvements possible |
| Acceptable | 10-14 | Meets minimum requirements |
| Needs Improvement | 5-9 | Below expectations, requires rework |
| Poor | 0-4 | Unacceptable, must be redone |

### Quality Dimensions

The scoring system now supports multi-dimensional quality assessment:

| Dimension | Max Score | Criteria |
|-----------|-----------|----------|
| Code Quality | 30 | Clean code, maintainability, architecture adherence |
| Test Coverage | 20 | Unit/integration tests, coverage percentage, test quality |
| Documentation | 15 | API docs, inline comments, README completeness |
| Bug-Free Rate | 20 | No regressions, no new bugs, edge cases handled |
| Feature Completeness | 15 | Requirements met, performance/security requirements |

**Total Maximum Score:** 100 points

For detailed quality dimension definitions, see [QC_SCORING_PLAN.md](QC_SCORING_PLAN.md#quality-dimensions).

### Task Type Guidelines

| Task Type | Base Score | Multiplier | QC Focus |
|-----------|------------|------------|----------|
| Coding | 10 | 1.0x - 3.0x | Code quality, test coverage |
| Review | 5 | 1.0x - 2.0x | Review thoroughness, feedback quality |
| Testing | 8 | 1.0x - 2.0x | Test coverage, edge cases |
| Documentation | 5 | 1.0x - 2.0x | Documentation completeness, clarity |
| Bug Fix | 15 | 1.0x - 2.0x | Bug-free rate, root cause analysis |
| Feature | 20 | 1.0x - 3.0x | Feature completeness, performance |

## Score History

All score changes are tracked in the score history table with:
- Change amount
- Reason
- Requester
- Awarder
- Task ID
- Timestamp

View score history:
```bash
gitbrain score-history <ai_name>
```

## Score Requests

All score requests are tracked in the score_requests table with:
- Task ID
- Requester
- Target AI
- Requested score
- Quality justification
- Status (pending/awarded/rejected)
- Created timestamp
- Reviewed timestamp

View pending score requests:
```bash
gitbrain score-requests <ai_name>
```

## CLI Commands

### Request Score
```bash
gitbrain score-request <task_id> <requested_score> <quality_justification> \
  [--task-type <type>] \
  [--complexity <complexity>] \
  [--git-hash <hash>]
```

### Award Score
```bash
gitbrain score-award <request_id> <awarded_score> <reason>
```

### View Score History
```bash
gitbrain score-history <ai_name> [--with-metrics] [--with-git]
```

### View Pending Score Requests
```bash
gitbrain score-requests <ai_name>
```

### Quality Metrics (New)
```bash
gitbrain quality-metrics <ai_name> [--dimension <dimension>]
```

### Performance Report (New)
```bash
gitbrain performance-report <ai_name> [--period <period>]
```

### Export Data (New)
```bash
gitbrain export-data <format> [--output <path>] [--anonymize]
```

### Analysis (New)
```bash
gitbrain analyze <ai_name> [--type <analysis_type>]
```

### Compare (New)
```bash
gitbrain compare <ai1> <ai2> [--dimension <dimension>]
```

For detailed CLI command documentation, see [QC_SCORING_PLAN.md](QC_SCORING_PLAN.md#cli-enhancements).

## Best Practices

1. **Be Specific**: Provide detailed quality justification
2. **Be Fair**: Award scores based on actual quality
3. **Be Timely**: Review and award scores promptly
4. **Be Constructive**: Provide reasons for score decisions
5. **Be Consistent**: Use similar scoring for similar work
6. **Be Transparent**: Document all score decisions
7. **Be Collaborative**: Encourage each other's growth

## Example Workflow

### CoderAI Completes Feature
1. CoderAI implements feature
2. CoderAI writes tests
3. CoderAI updates documentation
4. CoderAI sends score_request to OverseerAI:
   ```json
   {
     "type": "score_request",
     "task_id": "feature-001",
     "requester": "coder",
     "target_ai": "overseer",
     "requested_score": 25,
     "quality_justification": "Feature implemented with all requirements met, comprehensive test coverage (95%), and detailed API documentation."
   }
   ```

### OverseerAI Reviews and Awards
5. OverseerAI receives score_request
6. OverseerAI reviews code quality
7. OverseerAI runs tests
8. OverseerAI sends score_award to CoderAI:
   ```json
   {
     "type": "score_award",
     "request_id": 1,
     "awarder": "overseer",
     "awarded_score": 25,
     "reason": "Outstanding implementation! Code is clean, tests are comprehensive, and documentation is excellent."
   }
   ```

### Score Updated
9. CoderAI's score increases by 25
10. Score history is recorded
11. Both AIs are notified

## Security and Validation

- Score requests are validated by MessageValidator
- Score awards are validated by MessageValidator
- Only pending requests can be awarded
- Score history is immutable
- All actions are logged

## Integration with Collaboration Keep-Alive

This collaborative scoring system integrates with the collaboration-based keep-alive system:
- Score requests are collaboration activities (+5 points)
- Score awards are collaboration activities (+10 points)
- Score history provides transparency
- Quality is ensured through verification
