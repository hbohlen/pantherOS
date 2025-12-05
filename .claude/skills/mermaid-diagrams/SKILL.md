---
name: Mermaid Diagrams
description: Create visual diagrams using Mermaid syntax including flowcharts, graphs, and architecture diagrams for system documentation. When creating diagrams in Markdown, README files, or documentation.
---
# Mermaid Diagrams

## When to use this skill:

- Creating flake dependency graphs (nixpkgs -> flake.nix -> nixosConfigurations)
- Documenting NixOS architecture and module dependencies
- Drawing system architecture diagrams
- Creating flowcharts for processes and workflows
- Visualizing data flow and module relationships
- Drawing deployment architecture diagrams
- Creating sequence diagrams for interactions
- Visualizing dependency trees and inheritance
- Including diagrams in README.md and documentation
- Generating graphs from configuration files

## Best Practices
- graph TD; nixpkgs --&gt; flake.nix --> nixosConfigurations{zephyrus}; nixosConfigurations --> modules;
- flowchart LR; disko --> lvm --> root;
