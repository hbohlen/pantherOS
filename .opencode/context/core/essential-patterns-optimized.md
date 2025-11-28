# Essential Patterns - Research-Optimized

<critical_rules priority="absolute" enforcement="strict">
<rule id="always_rules" scope="core_patterns">
ALWAYS handle errors gracefully, validate input, use pure functions, document APIs
</rule>
<rule id="never_rules" scope="core_patterns">
NEVER expose sensitive info, hardcode credentials, skip validation, mutate state
</rule>
<rule id="security_basics" scope="all_operations">
ALWAYS sanitize input, use env vars for secrets, validate output
</rule>
<rule ref="safety_gates"/>
<rule ref="session_isolation"/>
</critical_rules>

<execution_priority>
<tier level="1" desc="Safety & Security">
<rules>always_rules, never_rules, security_basics</rules>
</tier>
<tier level="2" desc="Core Patterns">
<focus>pure_functions, error_handling, validation, modular_design</focus>
</tier>
<tier level="3" desc="Quality">
<practices>testing, documentation, maintainability</practices>
</tier>
</execution_priority>

<core_philosophy>
<principle name="modular" description="Everything is a component - small, focused, reusable"/>
<principle name="functional" description="Pure functions, immutability, composition over inheritance"/>
<principle name="maintainable" description="Self-documenting, testable, predictable"/>
</core_philosophy>

<pattern_categories>
<category name="essential" priority="1">
<patterns>pure_functions, error_handling, input_validation, security_basics, consistent_logging</patterns>
</category>
<category name="structural" priority="2">
<patterns>modular_design, functional_approach, component_structure</patterns>
</category>
<category name="quality" priority="3">
<patterns>testing_patterns, documentation_patterns, anti_patterns</patterns>
</category>
</pattern_categories>

<references>
  <detailed_patterns ref="patterns/comprehensive-patterns.md"/>
  <anti_patterns ref="patterns/anti-patterns.md"/>
  <testing_guide ref="patterns/testing-guide.md"/>
  <security_guide ref="patterns/security-guide.md"/>
</references>

<quick_checklist>
<category name="essential">
<check description="Pure functions (no side effects)" weight="high"/>
<check description="Input validation" weight="high"/>
<check description="Error handling" weight="high"/>
<check description="No hardcoded secrets" weight="high"/>
</category>
<category name="quality">
<check description="Tests written and passing" weight="medium"/>
<check description="Documentation updated" weight="medium"/>
<check description="Code is modular" weight="medium"/>
<check description="No security vulnerabilities" weight="high"/>
</category>
</quick_checklist>
