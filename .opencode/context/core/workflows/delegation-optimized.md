# Delegation Optimization Patterns

<critical_rules priority="absolute" enforcement="strict">
<rule ref="safety_gates"/>
<rule ref="session_isolation"/>
<rule ref="cleanup_confirmation"/>
</critical_rules>

<execution_priority>
<tier level="1" desc="Safety & Critical">
<reference>safety_gates, session_isolation, cleanup_confirmation</reference>
</tier>
<tier level="2" desc="Core Operations">
<process>delegate_task → create_context → cleanup</process>
</tier>
<tier level="3" desc="Optimizations">
<patterns>lazy_init, error_handling, manifest_tracking</patterns>
</tier>
</execution_priority>

<workflow id="task_delegation" template="standard">
  <stage name="CreateContext" when="complex_task">
    <location template=".tmp/sessions/{timestamp}-{slug}/context.md"
             max_nesting="3"
             required="true"/>
    <process>
      1. Generate unique session ID: `{timestamp}-{random-4-chars}`
      2. Create context file using standard template
      3. Populate all required sections
      4. Reference static context files (don't duplicate)
    </process>
  </stage>

  <stage name="DelegateTask" when="context_ready">
    <command>
      Task: {brief description}
      Context: {session_dir}/context.md
      Reference: @critical_rules for safety protocols
    </command>
    <delegation_rules>
      <route agent="@target" when="specialized_task"/>
      <route agent="@general" when="standard_task"/>
    </delegation_rules>
  </stage>

  <stage name="CleanupSession" when="task_complete">
    <action>
      Ask user confirmation via @cleanup_confirmation
      Delete session directory only if approved
      Update manifest to track cleanup status
    </action>
  </stage>
</workflow>

<templates>
  <context_file template="delegation" required_fields="request, requirements, decisions, files"/>
  <manifest template="session_tracking" required_fields="session_id, context_files"/>
</templates>

<delegation_rules when_to_delegate>
<condition category="complexity" value="multi_file"/>
<condition category="expertise" value="specialized"/>
<condition category="perspective" value="fresh_eyes"/>
</delegation_rules>

<references>
  <critical_rules ref="critical-rules.md"/>
  <session_management ref="sessions-optimized.md"/>
  <error_handling ref="patterns/error-handling.md"/>
</references>
