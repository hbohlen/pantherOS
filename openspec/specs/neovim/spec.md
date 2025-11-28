## ADDED Requirements

### Requirement: Nixvim Neovim Configuration

The system SHALL provide a fully configured Neovim editor using nixvim with plugins optimized for beginner ADHD users.

#### Scenario: nixvim launches successfully

- **WHEN** user runs nvim command
- **THEN** Neovim opens with nixvim configuration loaded

#### Scenario: hardtime plugin enforces good habits

- **WHEN** user repeatedly presses hjkl keys
- **THEN** hardtime blocks the input and shows hints for better motions

#### Scenario: precognition shows motion hints

- **WHEN** user enters normal mode
- **THEN** precognition displays virtual text showing available motions

#### Scenario: which-key shows key bindings

- **WHEN** user starts typing a leader key sequence
- **THEN** which-key popup appears showing available commands

#### Scenario: flash enhances search functionality

- **WHEN** user presses 's' in normal mode
- **THEN** flash shows labeled targets for jumping

#### Scenario: gitsigns shows git changes

- **WHEN** user opens a file with git changes
- **THEN** gitsigns displays signs in the gutter for added/modified/deleted lines

#### Scenario: todo-comments highlights TODO items

- **WHEN** user has TODO/FIXME comments in code
- **THEN** todo-comments highlights them with special colors

#### Scenario: trouble provides better diagnostics

- **WHEN** user runs :Trouble diagnostics
- **THEN** trouble opens a panel showing all LSP diagnostics in the project</content>
  <parameter name="filePath">openspec/changes/add-nixvim-setup/specs/neovim/spec.md
