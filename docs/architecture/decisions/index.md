# Architecture Decision Records

> **Category:** Architecture  
> **Audience:** Contributors, System Architects  
> **Last Updated:** 2025-11-17

This section contains Architecture Decision Records (ADRs) and core principles that guide the design and implementation of pantherOS.

## Table of Contents

- [Project Constitution](#project-constitution)
- [Architecture Decisions](#architecture-decisions)
- [Using ADRs](#using-adrs)

## Project Constitution

**[pantherOS Constitution](constitution.md)** - Core principles and governance

The constitution defines the fundamental principles that guide all decisions in pantherOS:
- Declarative Configuration
- Modular Architecture
- Reproducibility
- Security by Default
- Documentation Standards
- Spec-Driven Development

Read this first to understand the project's philosophy and constraints.

## Architecture Decisions

> **Note:** Additional ADRs will be added as architectural decisions are formalized. Suggested ADRs include:
> - ADR-001: Flakes over Channels
> - ADR-002: Minimal Server Configuration
> - ADR-003: Disko for Declarative Disk Management
> - ADR-004: nixos-anywhere for Remote Deployment

## Using ADRs

When making significant architectural decisions:

1. **Create an ADR** - Document the decision, context, and rationale
2. **Number sequentially** - Use format `adr-NNN-title.md`
3. **Include sections**:
   - **Status**: Proposed, Accepted, Deprecated, Superseded
   - **Context**: What is the issue we're facing?
   - **Decision**: What is the change we're proposing?
   - **Consequences**: What becomes easier or harder?
4. **Reference in code** - Link to ADRs in implementation comments
5. **Update as needed** - Mark as superseded when decisions change

## See Also

- [Architecture Overview](../overview.md) - High-level system architecture (when created)
- [pantherOS Constitution](constitution.md) - Project principles
- [Spec-Driven Workflow](../../contributing/spec-driven-workflow.md) - Development methodology
