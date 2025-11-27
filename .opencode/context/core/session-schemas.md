# Session Management Detailed Schemas

<schema_type name="manifest_structure">
  <format>JSON</format>
  <fields>
    <field name="session_id" type="string" required="true" pattern="{timestamp}-{random-4-chars}"/>
    <field name="created_at" type="ISO8601" required="true"/>
    <field name="last_activity" type="ISO8601" required="true"/>
    <field name="context_files" type="object" required="false"/>
    <field name="context_index" type="object" required="false"/>
    <field name="session_metadata" type="object" required="false"/>
  </fields>
</schema_type>

<schema_type name="context_file">
  <format>Markdown with frontmatter</format>
  <required_sections>
    <section name="request" description="User's original request"/>
    <section name="requirements" description="Technical requirements"/>
    <section name="decisions" description="Architecture/approach decisions"/>
    <section name="files" description="Files to modify/create"/>
    <section name="instructions" description="Agent instructions"/>
  </required_sections>
  <optional_sections>
    <section name="constraints" description="Limitations and preferences"/>
    <section name="progress" description="Task tracking"/>
    <section name="notes" description="Additional context"/>
  </optional_sections>
</schema_type>

<schema_type name="session_activity">
  <format>Event-driven logging</format>
  <events>
    <event name="session_created" timestamp="auto"/>
    <event name="context_added" trigger="file_creation"/>
    <event name="activity_updated" trigger="any_operation"/>
    <event name="cleanup_initiated" trigger="user_approval"/>
    <event name="cleanup_completed" trigger="directory_deletion"/>
  </events>
</schema_type>