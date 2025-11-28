# Session Management - Optimized

<critical_rules priority="absolute" enforcement="strict">
<rule ref="safety_gates"/>
<rule ref="session_isolation"/>
<rule ref="cleanup_confirmation"/>
<rule id="lazy_initialization" scope="session_creation">
Only create sessions when first context file needed
</rule>
<rule id="activity_tracking" scope="session_operations">
Update manifest timestamp after each operation
</rule>
</critical_rules>

<execution_priority>
<tier level="1" desc="Safety Rules">
<rules>safety_gates, session_isolation, cleanup_confirmation</rules>
</tier>
<tier level="2" desc="Core Session Ops">
<process>create → manage → track → cleanup</process>
</tier>
<tier level="3" desc="Performance">
<optimizations>lazy_init, activity_tracking, manifest_indexing</optimizations>
</tier>
</execution_priority>

<session_types>
<type name="simple" when="single_context_file" max_files="1"/>
<type name="complex" when="multi_file_task" max_files="5"/>
<type name="extended" when="multi_day_project" max_files="10"/>
</session_types>

<structure template=".tmp/sessions/{session-id}/" default_size="3">
  <required_files>
    <file name=".manifest.json" purpose="session_metadata"/>
    <file name="context.md" purpose="task_requirements"/>
  </required_files>
  <optional_directories>
    <dir name="features/" purpose="feature_context"/>
    <dir name="docs/" purpose="documentation_context"/>
    <dir name="code/" purpose="implementation_context"/>
  </optional_directories>
</structure>

<manifest_template>
<format>JSON</format>
<required_fields>session_id, created_at, context_files</required_fields>
<tracking>file_metadata, keywords, activity_timestamps</tracking>
</manifest_template>

<references>
  <detailed_schemas ref="session-schemas.md"/>
  <error_handling ref="session-error-handling.md"/>
  <performance_patterns ref="session-optimizations.md"/>
  <manifest_spec ref="session-manifest-spec.md"/>
</references>

<quick_reference>
**Lazy Init**: Create only when needed
**Session ID**: `{timestamp}-{random-4-chars}` format
**Safety**: Always confirm cleanup via @cleanup_confirmation
**Isolation**: Never access files outside current session
</quick_reference>
