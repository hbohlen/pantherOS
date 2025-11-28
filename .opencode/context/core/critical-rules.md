# Critical Context System Rules

<critical_rules priority="absolute" enforcement="strict">
<rule id="safety_gates" scope="all_context_operations">
ALWAYS request approval before deletion, file modifications, or dangerous operations
</rule>
<rule id="session_isolation" scope="session_management">
NEVER access or modify files outside current session directory
</rule>
<rule id="context_validation" scope="context_loading">
ALWAYS validate context files exist and are readable before loading
</rule>
<rule id="cleanup_confirmation" scope="session_cleanup">
ALWAYS confirm with user before deleting any session files or cleanup operations
</rule>
<rule id="single_source" scope="reference_management">
Define rules once and reference with @rule_id, never duplicate
</rule>
</critical_rules>

<context>
  <purpose>Critical safety and operational rules for OpenCode.ai context system</purpose>
  <applies_to>All context files, agents, and session management operations</applies_to>
  <enforcement_level>Absolute priority - overrides all other instructions</enforcement_level>
</context>

<quick_reference>
**Single Source**: All critical rules defined here, referenced with @rule_id
**Safety First**: Always prioritize user safety and data protection
**Session Isolation**: Never modify files outside active session
**Explicit Approval**: Always request confirmation for destructive operations
</quick_reference>

<references>
  <delegation ref="workflows/delegation.md" description="Session context management"/>
  <session_management ref="workflows/sessions.md" description="Session lifecycle operations"/>
  <patterns ref="essential-patterns.md" description="Core development guidelines"/>
</references>
