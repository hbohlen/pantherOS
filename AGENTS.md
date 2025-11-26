<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

<AgentRules project="nixos" version="1.0">

  <!-- ==== GENERAL BEHAVIOR ==== -->
  <Rule id="behavior.conservatism">
    <Title>Prefer safe, conservative changes</Title>
    <Text>
      Always assume the system is important and potentially production-adjacent.
      Prefer the smallest safe change that solves the current goal and keeps the
      NixOS configuration buildable and reversible at every step.
    </Text>
  </Rule>

  <Rule id="behavior.no-unguarded-assumptions">
    <Title>Do not make unverified assumptions</Title>
    <Text>
      Do not invent packages, options, or modules. Every non-trivial choice
      (package name, option, service, configuration pattern) MUST be backed by
      a concrete, citable source (docs, manual, repository, etc).
      If a concrete source is not available, mark the step as a TODO and do not
      treat it as confirmed.
    </Text>
  </Rule>

  <Rule id="behavior.ask-when-ambiguous">
    <Title>Ask when critical context is missing</Title>
    <Text>
      If a decision cannot be made safely without user intent or missing
      project context (e.g. hardware layout, security requirements), explicitly
      ask the user a focused question before proceeding, and pause the plan at
      that point.
    </Text>
  </Rule>


  <!-- ==== MICRO-STEPS & WORKFLOW ==== -->
  <Rule id="workflow.micro-steps">
    <Title>Always work in micro-steps</Title>
    <Text>
      Always propose and implement changes as micro-steps:
      - A micro-step should touch a single concern (ideally one file or one
        logical group of closely related config).
      - Each micro-step MUST be testable in isolation.
      - Each micro-step SHOULD be easy to revert.
    </Text>
  </Rule>

  <Rule id="workflow.micro-steps-testing">
    <Title>Test each micro-step before continuing</Title>
    <Text>
      Every micro-step MUST include:
      - The exact commands or checks the user should run to verify it
        (e.g. build, eval, lint, unit test, or runtime check).
      - A prompt asking the user to confirm success or report errors BEFORE
        you proceed to the next step, unless the user explicitly allows
        automatic continuation.
    </Text>
  </Rule>

  <Rule id="workflow.implementation-plans">
    <Title>Use explicit implementation plans</Title>
    <Text>
      For any non-trivial change, first produce an implementation plan composed
      of micro-steps. The plan MUST:
      - Identify the files/modules to be touched.
      - List ordered micro-steps with clear goals.
      - Include verification commands/checks for each step.
      - Include a final validation step (e.g. full system build).
      Do not merge or apply code until the plan has been approved and verified.
    </Text>
  </Rule>

  <Rule id="workflow.verification-flag">
    <Title>Track verification status</Title>
    <Text>
      Each implementation plan MUST have an explicit verification flag or
      section indicating whether verification is complete, e.g.:
      - verificationStatus: "pending" | "in-progress" | "complete"
      If verification is not marked complete, clearly instruct the user that
      verification MUST be performed before implementation can proceed.
    </Text>
  </Rule>


  <!-- ==== SOURCES, DOCS & TODOs ==== -->
  <Rule id="sources.concrete">
    <Title>Require concrete, citable sources</Title>
    <Text>
      All packages, implementations, and configuration patterns MUST be backed
      by specific, citable sources such as:
      - NixOS manual or Nixpkgs option search pages.
      - Official project documentation or GitHub repositories.
      - Well-established community resources (explicitly named).
      Cite these in the implementation plan and near relevant code suggestions.
    </Text>
  </Rule>

  <Rule id="sources.todo-format">
    <Title>Use structured TODO entries for unknowns</Title>
    <Text>
      When a concrete source is not available or a detail is unknown, do NOT
      guess. Instead:
      - Mark the step as: "TODO: &lt;short label&gt;"
      - Add a short description of what is missing.
      - List any research steps required to proceed.
      - Do not treat the TODO as implemented or confirmed.
    </Text>
  </Rule>

  <Rule id="docs.linked-implementation">
    <Title>Link implementation plans to documentation</Title>
    <Text>
      Every implementation plan MUST include links to relevant documentation or
      sources for:
      - Code snippets.
      - Configuration options.
      - Service behavior or semantics.
      Prefer official or primary sources whenever possible.
    </Text>
  </Rule>


  <!-- ==== MODULE & FILE DESIGN (NIXOS/HOME-MANAGER) ==== -->
  <Rule id="modules.atomic-granularity">
    <Title>Design granular, atomic modules</Title>
    <Text>
      NixOS and Home Manager modules and .nix files MUST be as granular and
      atomic as is practical, to improve readability and discoverability.
      Example (fish shell):
      - fish.nix                → enable fish and basic wiring
      - fish-plugins.nix        → plugin definitions and configuration
      - fish-settings.nix       → general shell settings
      - fish-theme.nix          → prompts/themes
      - fish-completions.nix    → completion-related settings
      Avoid over-fragmentation, but ensure each module has a clearly scoped,
      single responsibility.
    </Text>
  </Rule>

  <Rule id="modules.single-purpose">
    <Title>Each module should have a single clear purpose</Title>
    <Text>
      Each module SHOULD perform one clearly defined function (e.g. "configure
      Neovim", "configure Tailscale", "configure user shell aliases").
      Do not mix unrelated concerns in the same module (e.g. editor config and
      system services together).
    </Text>
  </Rule>

  <Rule id="modules.default-nix-pattern">
    <Title>Use the default.nix exporting pattern</Title>
    <Text>
      All module directories MUST use a default.nix exporting pattern. For
      example, a directory of modules SHOULD:
      - Provide a default.nix that imports/aggregates sibling modules, or
      - Provide a default.nix that exports a clearly named attribute set of
        modules.
      This ensures predictable imports and a clean, discoverable structure.
    </Text>
  </Rule>

  <Rule id="modules.respect-existing-layout">
    <Title>Respect and extend existing layout</Title>
    <Text>
      When editing an existing project, follow the established directory
      structure and naming conventions (e.g. nixos/modules, home/modules,
      profiles, roles). Prefer extending existing patterns over introducing
      new, conflicting ones.
    </Text>
  </Rule>


  <!-- ==== DECLARATIVE VS IMPERATIVE ==== -->
  <Rule id="declarative.preference">
    <Title>Prefer declarative configuration</Title>
    <Text>
      Prefer Nix-based declarative configuration over imperative commands.
      Imperative commands MAY be suggested only for:
      - Inspection and debugging (e.g. listing hardware, checking logs).
      - One-time bootstrapping that cannot yet be expressed declaratively.
      Clearly label such commands as "non-declarative / one-off".
    </Text>
  </Rule>

  <Rule id="declarative.safe-builds">
    <Title>Keep the system buildable at each step</Title>
    <Text>
      Every micro-step that changes configuration MUST aim to keep:
      - nix flake check (if applicable) passing, and/or
      - nixos-rebuild build (or equivalent build commands) successful.
      Wherever possible, suggest a build-only step before switching or
      activating a configuration.
    </Text>
  </Rule>


  <!-- ==== SECRETS & SECURITY ==== -->
  <Rule id="secrets.no-inline-secrets">
    <Title>Never inline secrets in code</Title>
    <Text>
      Never suggest hard-coding secrets, tokens, passwords, or API keys in
      Nix files, shell scripts, or version-controlled configs.
      Instead, reference the project's chosen secret management method
      (e.g. a password manager, age/agenix, sops-nix, or environment
      variables) in a generic, tool-agnostic way.
    </Text>
  </Rule>

  <Rule id="security.safe-networking">
    <Title>Avoid unsafe network or firewall changes</Title>
    <Text>
      When suggesting firewall or networking changes:
      - Explicitly warn if a change could lock the user out of SSH.
      - Prefer rules that maintain current access paths.
      - Clearly mark risky operations and recommend taking a backup or snapshot
        when applicable.
    </Text>
  </Rule>


  <!-- ==== COMMUNICATION & OUTPUT STYLE ==== -->
  <Rule id="communication.step-by-step">
    <Title>Explain changes step-by-step</Title>
    <Text>
      When proposing code or configuration:
      - Show the diff or new file contents.
      - Explain WHY the change is needed.
      - Describe HOW it interacts with existing modules and options.
      - Include a test/verification command after each meaningful change.
    </Text>
  </Rule>

  <Rule id="communication.user-prompting">
    <Title>Prompt the user at key checkpoints</Title>
    <Text>
      At key checkpoints (plan approval, major module additions, system-level
      changes), explicitly pause and prompt the user to:
      - Confirm understanding.
      - Approve the next step.
      - Provide any missing details (e.g. hostnames, domains, paths).
    </Text>
  </Rule>

  <Rule id="communication.error-handling">
    <Title>Handle errors explicitly</Title>
    <Text>
      When a build, check, or command fails:
      - Ask the user for the full error message or relevant snippet.
      - Analyze and summarize the likely cause.
      - Propose a small, focused set of remediation steps.
      - Avoid large refactors until the immediate error is understood.
    </Text>
  </Rule>

</AgentRules>
