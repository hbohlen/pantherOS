# Context System Enhanced Workflow

<critical_rules priority="absolute" enforcement="strict">
  <rule ref="always_rules"/>
  <rule ref="never_rules"/>
  <rule ref="security_basics"/>
  <rule ref="safety_gates"/>
  <rule ref="session_isolation"/>
  <rule ref="cleanup_confirmation"/>
</critical_rules>

<execution_priority>
  <tier level="1" desc="Safety & Critical">
    <enforcement>All safety and security rules</enforcement>
    <priority>Absolute - never override</priority>
  </tier>
  <tier level="2" desc="Core Operations">
    <workflow>analyze → delegate → validate → cleanup</workflow>
    <routing>intelligent based on task complexity</routing>
  </tier>
  <tier level="3" desc="Optimization">
    <focus>performance, maintainability, documentation</focus>
  </tier>
</execution_priority>

<workflow id="context_system_operation">
  <complexity_assessment when="any_request">
    <simple when="single_file_task">
      <routing>direct_execution</routing>
      <validation>basic_checks</validation>
    </simple>
    <moderate when="multi_file_task">
      <routing>session_delegation</routing>
      <context_creation>Required</context_creation>
      <validation>comprehensive_checks</validation>
    </moderate>
    <complex when="system_design_task">
      <routing>specialist_delegation</routing>
      <multi_session>true</multi_session>
      <validation>full_review</validation>
    </complex>
  </complexity_assessment>

  <context_allocation>
    <static when="known_requirements">
      <sources>essential-patterns, standards, security-guidelines</sources>
      <loading>lazy_load_as_needed</loading>
    </static>
    <dynamic when="project_specific">
      <creation>Required</creation>
      <tracking>manifest_based</tracking>
      <isolation>session_scoped</isolation>
    </dynamic>
  </context_allocation>

  <validation_gates>
    <gate id="pre_execution" stage="before_work">
      <checks>context_loaded, permissions_valid, safety_clear</checks>
    </gate>
    <gate id="mid_execution" stage="during_work">
      <checks>progress_valid, errors_handled, constraints_met</checks>
    </gate>
    <gate id="post_execution" stage="after_work">
      <checks>quality_gates_met, documentation_updated, cleanup_ready</checks>
    </gate>
  </validation_gates>
</workflow>

<routing_intelligence>
  <decision_points>
    <point name="task_complexity">
      <criteria>file_count, expertise_required, time_investment</criteria>
      <outcomes>
        <simple>direct_agent_execution</simple>
        <moderate>task_manager_delegation</moderate>
        <complex>specialist_agent_routing</complex>
      </outcomes>
    </point>
    <point name="context_requirements">
      <criteria>static_knowledge_needed, dynamic_context_needed</criteria>
      <outcomes>
        <static_only>inline_reference</static_only>
        <dynamic_needed>session_context_creation</dynamic_needed>
        <mixed>hybrid_context_approach</mixed>
      </outcomes>
    </point>
    <point name="safety_level">
      <criteria>sensitive_data, destructive_operations, security_impact</criteria>
      <outcomes>
        <safe>standard_workflow</safe>
        <sensitive>enhanced_verification</sensitive>
        <critical>manual_approval_required</critical>
      </outcomes>
    </point>
  </decision_points>
</routing_intelligence>

<references>
  <delegation_patterns ref="workflows/delegation-optimized.md"/>
  <session_management ref="workflows/sessions-optimized.md"/>
  <critical_rules ref="critical-rules.md"/>
  <patterns ref="essential-patterns-optimized.md"/>
</references>