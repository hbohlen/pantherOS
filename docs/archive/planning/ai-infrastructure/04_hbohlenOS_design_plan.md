# hbohlenOS Design Specification Plan

**Created:** 2025-11-13  
**Updated:** 2025-11-15  
**Author:** MiniMax Agent  
**Objective:** ADHD-Focused Personal Knowledge Management Application

## Overview

**hbohlenOS** is a hybrid Personal Knowledge Management (PKM) application designed specifically for ADHD users. It combines document editing, visual canvases, and AI-powered assistance to reduce friction, support executive function, and help users organize overwhelming projects.

## Core Principles

- **ADHD-First Design**: Every feature addresses specific ADHD challenges
- **Minimal Friction**: State persistence, fluid mode switching, context-aware assistance
- **Visual-First Knowledge**: Graph views, nested canvases, visual relationship mapping
- **AI-Enhanced**: Opencode.ai integration for personalized suggestions and gap analysis
- **Privacy-Focused**: Local storage, local AI, full data ownership

## Architecture Overview

### System Components
- **Rust Backend**: Data storage, search, graph operations, AgentDB integration, Opencode.ai communication
- **React/TypeScript Frontend**: UI management, canvas rendering, user interactions
- **Dual Graph System**:
  1. Content Graph: Documents, blocks, and their relationships
  2. Memory Graph (AgentDB): User patterns, preferences, and personalized learning
- **File System Sync**: Markdown files for portability, real-time sync to graph database
- **Opencode.ai Integration**: Local AI assistant for canvas creation, analysis, suggestions

### Interaction Modes
1. **Document Mode**: Traditional note-taking with rich text, links to canvases
2. **Canvas Mode**: Visual workspace with nodes, connections, and layered views
3. **Conversation Mode**: Chat interface where AI creates visual representations in real-time

## Implementation Phases

### Phase 1: Core Infrastructure
- Rust backend with AgentDB integration
- Basic file system sync
- React app with document editor
- State persistence

### Phase 2: Graph & Canvas
- Dual graph implementation (content + memory)
- Canvas rendering with Sigma.js
- Document/canvas hybrid mode
- Basic linking and navigation

### Phase 3: AI Integration
- Opencode.ai integration
- Context building for AI
- Stuck Canvas feature
- Gap analysis

### Phase 4: ADHD Features
- Pattern learning in AgentDB
- Personalized suggestions
- Executive function tools
- Project breakdown automation

### Phase 5: Polish & Optimization
- Performance tuning
- UI/UX refinements
- Advanced graph layouts
- Additional AI capabilities

## Success Metrics

- **Reduced Context Switching**: Users can resume exactly where they left off
- **Faster Project Breakdowns**: AI assists in creating task hierarchies
- **Reduced Stuck Time**: Stuck Canvas feature helps users move forward
- **Better Knowledge Retention**: Visual connections improve recall
- **Increased Completion Rates**: ADHD-specific support increases task completion

---

**Related Documents:**
- [Master Project Plans](../00_MASTER_PROJECT_PLANS.md)