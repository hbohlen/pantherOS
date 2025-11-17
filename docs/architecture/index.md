# Architecture Documentation

> **Category:** Architecture  
> **Audience:** Contributors, System Architects  
> **Last Updated:** 2025-11-17

This section contains system architecture documentation, design decisions, and architectural diagrams for pantherOS.

## Table of Contents

- [Overview](#overview)
- [Architecture Decisions](#architecture-decisions)
- [Diagrams](#diagrams)

## Overview

**[Architecture Overview](overview.md)** - High-level system architecture

Start here to understand:
- Design philosophy and core principles
- Current implementation status
- Technology stack and rationale
- Repository structure
- Core components and their relationships

## Architecture Decisions

**[Architecture Decision Records (ADRs)](decisions/)** - Formal design decisions

The decisions/ directory contains:
- **[pantherOS Constitution](decisions/constitution.md)** - Core principles and governance
- Individual ADRs documenting major architectural choices (to be added)

ADRs document the context, decision, and consequences of significant architectural choices. They help contributors understand why the system is designed the way it is.

## Diagrams

> **Status:** Architecture diagrams are currently in the planning phase and located in the archive.

Architectural diagrams will be added here as the system matures:
- System architecture diagrams
- Component interaction diagrams
- Data flow diagrams
- Deployment topology diagrams

For aspirational diagrams, see:
- [Archived System Diagrams](../archive/planning/architecture/ARCHITECTURE_DIAGRAMS.md)
- [Archived Integration Diagrams](../archive/planning/architecture/ARCHITECTURE_DIAGRAMS_SYSTEMS.md)

## Related Documentation

### For Implementation Details
- [Reference Documentation](../reference/) - Current configuration and specifications
- [Infrastructure Documentation](../infra/) - NixOS tooling and concepts
- [Operations Documentation](../ops/) - Deployment and operations

### For Contributing
- [Spec-Driven Workflow](../contributing/spec-driven-workflow.md) - Development methodology
- [How-To Guides](../howto/) - Task-oriented implementation guides
- [Feature Specifications](../specs/) - Formal feature specifications

## Contributing to Architecture

When making architectural changes:

1. **Follow the Constitution** - All decisions must align with [core principles](decisions/constitution.md)
2. **Create an ADR** - Document significant architectural decisions
3. **Update Diagrams** - Keep visual documentation in sync
4. **Follow Spec-Driven Development** - Create specs before implementation
5. **Review Process** - Get architectural review for major changes

See the [Contributing Guide](../contributing/) for more information.
