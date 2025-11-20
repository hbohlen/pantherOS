---
description: Generate an OpenSpec proposal with required sections and validation steps
---

# /openspec-proposal

Create a complete OpenSpec proposal for the requested change.

## Instructions
- Confirm the scope, risks, and affected components before drafting.
- Populate mandatory sections: Summary, Goals, Non-Goals, Risks, Success Metrics, Dependencies, Implementation Plan, Validation Plan, Rollback/Recovery, Timeline.
- Tie work to the pantherOS phases and existing docs when relevant.
- Call out security, reliability, and migration impacts explicitly.
- Produce a concise changelog entry and list of follow-up tasks.

## Output
- Return the proposal in markdown, keeping headers intact.
- Include a checklist of validation steps and owners.
- Suggest related commands (e.g., /openspec-apply, /openspec-archive) for the next phases.
