---
agent: "@subagents/gap-analysis-agent"
description: "Analyzes gaps in documentation, specifications, tests, and knowledge across pantherOS repository"
syntax: "/gap-analyze project"
examples:
  - "/gap-analyze project"
  - "/gap-analyze documentation"
  - "/gap-analyze tests"
---

# Gap Analysis Command

## Overview

The `/gap-analyze` command performs comprehensive analysis of the pantherOS repository to identify missing documentation, incomplete specifications, test gaps, and knowledge deficiencies that could impact project success.

## Usage

### Syntax
```bash
/gap-analyze <scope>
```

### Parameters
- `<scope>`: Analysis scope
  - `project`: Complete project analysis (default)
  - `documentation`: Documentation gaps only
  - `specifications`: Specification gaps only
  - `tests`: Test coverage gaps only
  - `knowledge`: Knowledge base gaps only

### Examples

#### Complete Project Analysis
```bash
/gap-analyze project
```

#### Documentation-Specific Analysis
```bash
/gap-analyze documentation
```

#### Test Coverage Analysis
```bash
/gap-analyze tests
```

#### Knowledge Base Analysis
```bash
/gap-analyze knowledge
```

## Analysis Categories

### Documentation Gaps

#### Required Documentation
- **README.md**: Project overview and quick start
- **ARCHITECTURE.md**: System design and architecture
- **CONTRIBUTING.md**: Contribution guidelines
- **CHANGELOG.md**: Version history and changes
- **docs/README.md**: Documentation index
- **docs/architecture/overview.md**: Architecture overview
- **docs/guides/README.md**: Guide index
- **docs/todos/README.md**: Task tracking

#### Module Documentation
- **Module README files**: Overview for each module category
- **API Documentation**: Interface specifications
- **Usage Examples**: Practical implementation examples
- **Troubleshooting Guides**: Common issues and solutions

#### Process Documentation
- **Development Workflow**: Step-by-step development process
- **Deployment Procedures**: Safe deployment guidelines
- **Security Procedures**: Security best practices
- **Backup/Recovery**: Data protection procedures

### Specification Gaps

#### OpenSpec Analysis
- **Missing Proposals**: Features without specifications
- **Incomplete Specs**: Specifications missing key sections
- **Implementation Gaps**: Specs without corresponding implementation
- **Validation Gaps**: Missing testing specifications

#### Module Specifications
- **Interface Definitions**: Clear module interfaces
- **Option Specifications**: Complete option definitions
- **Dependency Specifications**: Module dependency documentation
- **Performance Specifications**: Performance requirements and benchmarks

### Test Coverage Gaps

#### Configuration Tests
- **Host Configuration Tests**: Build tests for each host
- **Module Tests**: Unit tests for individual modules
- **Integration Tests**: Cross-module functionality tests
- **End-to-End Tests**: Complete system tests

#### Security Tests
- **Security Audit Tests**: Security configuration validation
- **Penetration Tests**: Security vulnerability testing
- **Compliance Tests**: Regulatory compliance validation
- **Access Control Tests**: Permission and access validation

#### Performance Tests
- **Load Tests**: System performance under load
- **Stress Tests**: System limits and failure modes
- **Benchmark Tests**: Performance baseline establishment
- **Regression Tests**: Performance regression detection

### Knowledge Base Gaps

#### Domain Knowledge
- **NixOS Best Practices**: Configuration patterns and optimization
- **Hardware Optimization**: Hardware-specific tuning guides
- **Security Knowledge**: Threat models and mitigation strategies
- **Performance Knowledge**: Optimization techniques and benchmarks

#### Process Knowledge
- **Development Patterns**: Reusable development approaches
- **Troubleshooting Procedures**: Common issue resolution
- **Migration Procedures**: System upgrade and migration guides
- **Recovery Procedures**: System recovery and rollback procedures

## Gap Analysis Process

### Phase 1: Repository Scanning
1. **File Structure Analysis**: Scan repository structure and organization
2. **Content Analysis**: Analyze existing documentation and code
3. **Quality Assessment**: Evaluate quality and completeness of existing content
4. **Coverage Analysis**: Determine coverage across all areas

### Phase 2: Gap Identification
1. **Missing Items**: Identify completely missing documentation/specifications
2. **Incomplete Items**: Find partially complete content
3. **Outdated Items**: Identify outdated or obsolete content
4. **Inconsistent Items**: Find contradictory or inconsistent information

### Phase 3: Impact Assessment
1. **Criticality Analysis**: Assess impact of each gap
2. **Priority Scoring**: Prioritize gaps based on impact and effort
3. **Dependency Analysis**: Identify dependencies between gaps
4. **Risk Assessment**: Evaluate risks associated with gaps

### Phase 4: Remediation Planning
1. **Action Plan Creation**: Develop specific remediation actions
2. **Resource Planning**: Estimate effort and resources required
3. **Timeline Planning**: Create implementation schedule
4. **Success Criteria**: Define completion criteria

## Output Format

### Gap Analysis Report

```markdown
# Gap Analysis Report

## Executive Summary
- **Total Gaps Identified**: X
- **Critical Gaps**: X
- **High Priority Gaps**: X
- **Estimated Remediation Effort**: X hours

## Gap Breakdown

### Critical Gaps (P0)
#### [GAP-001] Missing Security Implementation
- **Category**: Security/Specification
- **Impact**: Blocker for production deployment
- **Description**: Security specifications exist but implementation is incomplete
- **Evidence**: 
  - Security module templates exist but no implementation
  - No firewall rules configured
  - Missing 1Password integration
- **Recommendation**: Implement security module with highest priority
- **Estimated Effort**: 16 hours

### High Priority Gaps (P1)
#### [GAP-002] No Test Coverage
- **Category**: Testing
- **Impact**: High risk of configuration failures
- **Description**: No test files exist for any host configurations
- **Evidence**:
  - No test directories found
  - No configuration validation
  - No deployment testing
- **Recommendation**: Create comprehensive test suite
- **Estimated Effort**: 24 hours

### Medium Priority Gaps (P2)
#### [GAP-003] Incomplete Module Documentation
- **Category**: Documentation
- **Impact**: Difficult to maintain and extend
- **Description**: Module files exist without corresponding documentation
- **Evidence**:
  - 15 module files found
  - Only 3 have documentation
  - Missing usage examples
- **Recommendation**: Document all modules with examples
- **Estimated Effort**: 12 hours

## Remediation Plan

### Immediate Actions (Week 1)
1. **Implement Security Module** - 16 hours
2. **Create Test Suite** - 24 hours
3. **Document Critical Modules** - 8 hours

### Short-term Actions (Month 1)
1. **Complete Module Documentation** - 12 hours
2. **Create Performance Benchmarks** - 8 hours
3. **Implement CI/CD Pipeline** - 16 hours

### Long-term Actions (Quarter 1)
1. **Create Contribution Guidelines** - 4 hours
2. **Implement Monitoring System** - 20 hours
3. **Create Troubleshooting Guides** - 12 hours

## Success Metrics
- All critical gaps resolved
- Documentation completeness > 90%
- Test coverage > 80%
- Knowledge base completeness > 85%
```

### Gap Matrix

```markdown
# Gap Matrix

| Category | Critical | High | Medium | Low | Total |
|----------|----------|--------|--------|------|--------|
| Documentation | 2 | 5 | 8 | 3 | 18 |
| Specifications | 3 | 4 | 6 | 2 | 15 |
| Testing | 4 | 6 | 5 | 1 | 16 |
| Knowledge | 1 | 3 | 7 | 4 | 15 |
| **Total** | **10** | **18** | **26** | **10** | **64** |
```

### Action Plan Template

```markdown
# Gap Remediation Action Plan

## Priority 1: Critical Gaps
### [GAP-ID] Gap Title
- **Owner**: [Assigned person/agent]
- **Effort**: [Estimated hours]
- **Timeline**: [Completion date]
- **Dependencies**: [Prerequisites]
- **Success Criteria**: [Completion definition]

## Priority 2: High Priority Gaps
[Similar structure for high priority gaps]

## Priority 3: Medium Priority Gaps
[Similar structure for medium priority gaps]

## Tracking
- **Weekly Progress**: [Progress tracking method]
- **Quality Gates**: [Quality checkpoints]
- **Completion Criteria**: [Overall success metrics]
```

## Quality Criteria

### Analysis Quality
- **Comprehensive Coverage**: All project areas analyzed
- **Accurate Identification**: Correct gap identification
- **Proper Prioritization**: Appropriate priority assignment
- **Actionable Recommendations**: Specific, implementable suggestions

### Reporting Quality
- **Clear Documentation**: Well-structured, easy to understand
- **Evidence-Based**: Gaps supported by evidence
- **Prioritized Action**: Clear action priorities
- **Measurable Success**: Defined success criteria

## Integration Points

### With Other Commands
- **/swarm-research**: Research to fill knowledge gaps
- **/spec-builder**: Create specifications for identified gaps
- **/skills-list**: Identify skill requirements for gap resolution

### With Agents
- **Documentation Agent**: Create missing documentation
- **Testing Agent**: Implement missing test coverage
- **Security Agent**: Address security gaps
- **Module Generator**: Fill specification gaps

### With Workflows
- **Gap Resolution Workflow**: Structured gap remediation process
- **Documentation Workflow**: Documentation creation and maintenance
- **Testing Workflow**: Test implementation and validation

## Best Practices

### Analysis Approach
1. **Systematic Scanning**: Methodical repository analysis
2. **Evidence-Based**: Support gap identification with evidence
3. **Impact Assessment**: Evaluate impact of each gap
4. **Prioritization**: Focus on high-impact gaps first

### Remediation Planning
1. **Phased Approach**: Address gaps in priority order
2. **Resource Planning**: Allocate appropriate resources
3. **Dependency Management**: Consider gap dependencies
4. **Quality Gates**: Ensure quality of remediation

### Continuous Improvement
1. **Regular Analysis**: Periodic gap analysis
2. **Trend Monitoring**: Track gap trends over time
3. **Prevention**: Prevent future gaps through processes
4. **Knowledge Sharing**: Share gap insights across team

## Troubleshooting

### Common Issues

#### False Positives
**Problem**: Gaps identified that don't actually exist
**Solution**: Verify gap existence, refine analysis criteria

#### Priority Misalignment
**Problem**: Gap priorities don't match actual impact
**Solution**: Reassess impact, adjust priority scoring

#### Incomplete Analysis
**Problem**: Some areas missed in analysis
**Solution**: Expand analysis scope, verify completeness

#### Action Plan Overload
**Problem**: Too many gaps to address simultaneously
**Solution**: Prioritize more aggressively, phase implementation

### Resolution Strategies

#### Quality Assurance
1. **Peer Review**: Validate gap analysis with team
2. **Evidence Verification**: Double-check supporting evidence
3. **Impact Validation**: Confirm impact assessment
4. **Priority Review**: Validate priority assignments

#### Implementation Planning
1. **Resource Allocation**: Ensure adequate resources for high-priority gaps
2. **Timeline Realism**: Set achievable implementation timelines
3. **Dependency Management**: Plan for gap dependencies
4. **Success Metrics**: Define clear completion criteria

---

The `/gap-analyze` command provides comprehensive gap analysis capabilities to identify and prioritize missing documentation, specifications, tests, and knowledge across the pantherOS project.