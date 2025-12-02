# OpenSpec Workflow

## Overview
**OpenSpec** is the standard workflow for proposing, specifying, and implementing changes in the **pantherOS** repository. It ensures that changes are well-designed, documented, and validated before implementation.

## Process

### 1. Proposal (`openspec-proposal`)
-   **Goal**: Define *what* needs to change and *why*, without writing implementation code.
-   **Artifacts**:
    -   `proposal.md`: High-level summary, motivation, and alternatives.
    -   `design.md`: Architectural decisions, module structure, and technical approach.
    -   `tasks.md`: Checklist of implementation steps.
    -   `specs/<capability>/spec.md`: Detailed requirements and scenarios (Gherkin-style) for each capability.
-   **Command**: `openspec validate <change-id> --strict` ensures the proposal is structurally correct.

### 2. Implementation (`openspec-apply`)
-   **Goal**: Implement the changes defined in the proposal.
-   **Process**:
    -   Follow the `tasks.md` checklist.
    -   Write code in `modules/`, `hosts/`, etc.
    -   Verify changes against the `specs/`.
    -   Update `tasks.md` as items are completed.

### 3. Archive (`openspec-archive`)
-   **Goal**: Mark the change as complete and archive the specs.
-   **Process**:
    -   Once all tasks are done and verified.
    -   Run the archive command to move the change to the archive and update the system state.

## Directory Structure
-   `openspec/`: Root directory for OpenSpec.
-   `openspec/changes/`: Active changes.
    -   `<change-id>/`: Directory for a specific change.
        -   `proposal.md`
        -   `design.md`
        -   `tasks.md`
        -   `specs/`: Directory containing spec deltas.

## Best Practices
-   **No Code in Proposal**: Do not write implementation code during the proposal phase. Focus on design and requirements.
-   **Granular Specs**: Break down large changes into smaller, capability-focused spec deltas.
-   **Validation**: Always run `openspec validate` before submitting a proposal.
