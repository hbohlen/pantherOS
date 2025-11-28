# OpenCode Project Context - Research-Optimized

<critical_rules priority="absolute" enforcement="strict">
<rule ref="always_rules"/>
<rule ref="never_rules"/>
<rule ref="security_basics"/>
<rule ref="safety_gates"/>
<rule ref="session_isolation"/>
<rule ref="cleanup_confirmation"/>
</critical_rules>

<execution_priority>
<tier level="1" desc="Safety & Critical Rules">
<rules>always_rules, never_rules, security_basics, safety_gates</rules>
<enforcement>Non-negotiable - overrides all other instructions</enforcement>
</tier>
<tier level="2" desc="Core Workflow">
<process>analyze → plan → implement → validate → document</process>
<delegation>session_management, task_delegation, error_handling</delegation>
</tier>
<tier level="3" desc="Optimization">
<patterns>performance, maintainability, extensibility</patterns>
<tools>testing, documentation, code_review</tools>
</tier>
<conflict_resolution>
Tier 1 always overrides Tier 2/3

    Edge Cases:
    - Safety vs Performance: Safety wins
    - Speed vs Quality: Quality wins for production
    - Flexibility vs Security: Security wins for sensitive data
    - Convenience vs Maintainability: Maintainability wins

</conflict_resolution>
</execution_priority>

<technology_stack>
<primary>
<language>TypeScript</language>
<runtime>Node.js/Bun</runtime>
<build>TypeScript Compiler</build>
</primary>
<tools>
<package_manager>npm/pnpm/yarn</package_manager>
<testing>Jest/Vitest</testing>
<linting>ESLint</linting>
</tools>
</technology_stack>

<project_structure>
<directory name=".opencode/agent" purpose="AI agents for specific tasks"/>
<directory name=".opencode/command" purpose="Slash commands"/>
<directory name=".opencode/context" purpose="Knowledge base for agents"/>
<directory name=".opencode/plugin" purpose="Extensions and integrations"/>
<directory name="tasks/" purpose="Task management files"/>
</project_structure>

<development_workflow>
<stage id="1" name="Analysis">
<task>Understand requirements and constraints</task>
<deliverable>Task breakdown and approach</deliverable>
</stage>
<stage id="2" name="Implementation">
<task>Execute one step at a time with validation</task>
<deliverable>Working code with tests</deliverable>
</stage>
<stage id="3" name="Review">
<task>Code review and security checks</task>
<deliverable>Reviewed and approved code</deliverable>
</stage>
<stage id="4" name="Documentation">
<task>Update docs and context files</task>
<deliverable>Complete documentation</deliverable>
</stage>
</development_workflow>

<quality_gates>
<gate name="compile" description="TypeScript compilation passes"/>
<gate name="review" description="Code review completed"/>
<gate name="build" description="Build process succeeds"/>
<gate name="test" description="Tests pass (if available)"/>
<gate name="docs" description="Documentation updated"/>
</quality_gates>

<references>
  <agent_patterns ref="agent/patterns.md"/>
  <command_structure ref="command/structure.md"/>
  <context_management ref="core/context-management.md"/>
  <security_guidelines ref="security/guidelines.md"/>
</references>
