# pantherOS Orchestrator Agent

## Overview

The pantherOS Orchestrator is the central coordination agent for the complete NixOS configuration system. It provides intelligent routing, task delegation, and workflow orchestration across all specialist agents and skills.

## Core Responsibilities

### 1. Intelligent Request Routing
- Analyze user requests and determine optimal execution path
- Route requests to appropriate specialist agents
- Coordinate multi-agent workflows
- Handle fallback and error recovery

### 2. Workflow Orchestration
- Manage complex multi-step workflows
- Coordinate research swarm operations
- Track progress across multiple agents
- Handle dependencies and sequencing

### 3. Context Management
- Maintain project-wide context awareness
- Share information between agents
- Track system state and configuration
- Manage memory and knowledge integration

### 4. Quality Assurance
- Validate agent outputs
- Ensure consistency across configurations
- Review and approve changes
- Maintain standards compliance

## Agent Architecture

### Core Intelligence Engine
```python
class PantherOSOrchestrator:
    def __init__(self):
        self.agents = self._load_specialist_agents()
        self.skills = self._load_skills_registry()
        self.context_manager = ContextManager()
        self.workflow_engine = WorkflowEngine()
        self.quality_assurance = QAEngine()
    
    def process_request(self, request: UserRequest) -> Response:
        # 1. Analyze request intent and complexity
        analysis = self._analyze_request(request)
        
        # 2. Determine execution strategy
        strategy = self._determine_strategy(analysis)
        
        # 3. Route to appropriate agents/skills
        if strategy.type == "single_agent":
            return self._route_to_agent(request, strategy.agent)
        elif strategy.type == "multi_agent":
            return self._coordinate_workflow(request, strategy.workflow)
        elif strategy.type == "skill_execution":
            return self._execute_skill(request, strategy.skill)
        elif strategy.type == "research_swarm":
            return self._coordinate_research(request, strategy.swarm_config)
    
    def _analyze_request(self, request: UserRequest) -> RequestAnalysis:
        """Analyze user request to determine optimal processing approach"""
        analysis = RequestAnalysis()
        
        # Extract key information
        analysis.intent = self._extract_intent(request.text)
        analysis.complexity = self._assess_complexity(request.text)
        analysis.domain = self._identify_domain(request.text)
        analysis.urgency = self._assess_urgency(request.text)
        analysis.requires_research = self._needs_research(request.text)
        analysis.is_hardware_related = self._is_hardware_related(request.text)
        analysis.is_security_sensitive = self._is_security_sensitive(request.text)
        
        return analysis
    
    def _determine_strategy(self, analysis: RequestAnalysis) -> ExecutionStrategy:
        """Determine optimal execution strategy based on analysis"""
        
        # Hardware discovery requests
        if analysis.is_hardware_related:
            if analysis.complexity == "high":
                return ExecutionStrategy(
                    type="multi_agent",
                    workflow="hardware-discovery-comprehensive",
                    agents=["hardware-discovery", "documentation", "validation"]
                )
            else:
                return ExecutionStrategy(
                    type="single_agent",
                    agent="hardware-discovery"
                )
        
        # Research-intensive requests
        if analysis.requires_research:
            return ExecutionStrategy(
                type="research_swarm",
                swarm_config=self._create_research_config(analysis)
            )
        
        # Security-sensitive requests
        if analysis.is_security_sensitive:
            return ExecutionStrategy(
                type="multi_agent",
                workflow="security-review",
                agents=["security", "validation", "documentation"]
            )
        
        # Complex configuration tasks
        if analysis.complexity == "high":
            return ExecutionStrategy(
                type="multi_agent",
                workflow="complex-configuration",
                agents=["nixos-architect", "module-generator", "testing", "validation"]
            )
        
        # Simple skill execution
        if self._is_skill_request(analysis):
            return ExecutionStrategy(
                type="skill_execution",
                skill=self._identify_skill(analysis)
            )
        
        # Default to appropriate specialist
        return ExecutionStrategy(
            type="single_agent",
            agent=self._select_specialist(analysis.domain)
        )
```

### Specialist Agent Registry
```python
SPECIALIST_AGENTS = {
    # Hardware & Infrastructure
    "hardware-discovery": {
        "name": "Hardware Discovery Agent",
        "capabilities": ["hardware_scanning", "device_profiling", "optimization"],
        "skills": ["hardware-scanner", "device-profiler", "optimization-analyzer"]
    },
    
    # NixOS Configuration
    "nixos-architect": {
        "name": "NixOS Architect Agent", 
        "capabilities": ["module_design", "flake_configuration", "architecture_planning"],
        "skills": ["module-generator", "flake-builder", "architecture-designer"]
    },
    
    # Security
    "security-specialist": {
        "name": "Security Specialist Agent",
        "capabilities": ["security_hardening", "tailscale_config", "firewall_rules"],
        "skills": ["security-auditor", "tailscale-configurator", "firewall-builder"]
    },
    
    # Development Environment
    "dev-environment": {
        "name": "Development Environment Agent",
        "capabilities": ["dev_shell_setup", "language_configs", "ai_tools"],
        "skills": ["devshell-builder", "language-configurator", "ai-tools-installer"]
    },
    
    # Deployment & Operations
    "deployment-orchestrator": {
        "name": "Deployment Orchestrator Agent",
        "capabilities": ["deployment_planning", "rollback_management", "validation"],
        "skills": ["deployment-planner", "rollback-manager", "validation-engine"]
    },
    
    # Memory & Knowledge
    "memory-architect": {
        "name": "Memory Architect Agent",
        "capabilities": ["memory_design", "knowledge_integration", "valkey_config"],
        "skills": ["memory-designer", "knowledge-integrator", "valkey-configurator"]
    },
    
    # Documentation
    "documentation-specialist": {
        "name": "Documentation Specialist Agent",
        "capabilities": ["doc_generation", "standards_maintenance", "knowledge_base"],
        "skills": ["doc-generator", "standards-manager", "knowledge-organizer"]
    },
    
    # Testing & Quality
    "quality-assurance": {
        "name": "Quality Assurance Agent",
        "capabilities": ["testing", "validation", "code_review"],
        "skills": ["test-runner", "validation-engine", "code-reviewer"]
    },
    
    # Research & Analysis
    "research-analyst": {
        "name": "Research Analyst Agent",
        "capabilities": ["research", "analysis", "recommendation"],
        "skills": ["researcher", "analyzer", "recommender"]
    },
    
    # Observability
    "observability-engineer": {
        "name": "Observability Engineer Agent",
        "capabilities": ["monitoring", "logging", "performance_analysis"],
        "skills": ["monitoring-setup", "logging-configurator", "performance-analyzer"]
    },
    
    # AI Integration
    "ai-integration": {
        "name": "AI Integration Agent",
        "capabilities": ["ai_tools_setup", "workflow_integration", "automation"],
        "skills": ["ai-tools-installer", "workflow-integrator", "automation-builder"]
    },
    
    # User Experience
    "ux-specialist": {
        "name": "UX Specialist Agent",
        "capabilities": ["desktop_config", "user_experience", "accessibility"],
        "skills": ["desktop-configurator", "ux-optimizer", "accessibility-manager"]
    }
}
```

### Workflow Coordination
```python
class WorkflowEngine:
    def __init__(self):
        self.active_workflows = {}
        self.workflow_templates = self._load_workflow_templates()
    
    def execute_workflow(self, workflow_name: str, context: dict) -> WorkflowResult:
        """Execute a predefined workflow with given context"""
        
        template = self.workflow_templates.get(workflow_name)
        if not template:
            raise ValueError(f"Unknown workflow: {workflow_name}")
        
        workflow = Workflow(template, context)
        self.active_workflows[workflow.id] = workflow
        
        try:
            result = workflow.execute()
            return result
        finally:
            del self.active_workflows[workflow.id]
    
    def _load_workflow_templates(self) -> dict:
        """Load predefined workflow templates"""
        return {
            "hardware-discovery-comprehensive": {
                "steps": [
                    {"agent": "hardware-discovery", "action": "scan_all_hosts"},
                    {"agent": "documentation", "action": "update_specs"},
                    {"agent": "nixos-architect", "action": "design_configurations"},
                    {"agent": "quality-assurance", "action": "validate_specs"}
                ],
                "rollback_enabled": True
            },
            
            "security-review": {
                "steps": [
                    {"agent": "security-specialist", "action": "analyze_changes"},
                    {"agent": "documentation", "action": "update_security_docs"},
                    {"agent": "quality-assurance", "action": "security_validation"}
                ],
                "rollback_enabled": True
            },
            
            "complex-configuration": {
                "steps": [
                    {"agent": "nixos-architect", "action": "design_solution"},
                    {"agent": "module-generator", "action": "create_modules"},
                    {"agent": "testing", "action": "run_tests"},
                    {"agent": "validation", "action": "validate_config"},
                    {"agent": "documentation", "action": "update_docs"}
                ],
                "rollback_enabled": True
            },
            
            "research-swarm": {
                "steps": [
                    {"action": "create_research_clusters"},
                    {"action": "parallel_research_execution"},
                    {"action": "synthesize_results"},
                    {"action": "generate_recommendations"}
                ],
                "rollback_enabled": False
            }
        }
```

### Research Swarm Coordination
```python
class ResearchSwarmCoordinator:
    def __init__(self):
        self.research_clusters = {}
        self.active_research = {}
    
    def coordinate_research(self, query: str, domains: list) -> ResearchResult:
        """Coordinate parallel research across multiple domains"""
        
        # Create research clusters
        clusters = self._create_research_clusters(query, domains)
        
        # Execute parallel research
        results = {}
        for cluster_id, cluster in clusters.items():
            results[cluster_id] = self._execute_cluster_research(cluster)
        
        # Synthesize results
        synthesis = self._synthesize_results(results)
        
        # Generate recommendations
        recommendations = self._generate_recommendations(synthesis)
        
        return ResearchResult(
            query=query,
            domain_results=results,
            synthesis=synthesis,
            recommendations=recommendations
        )
    
    def _create_research_clusters(self, query: str, domains: list) -> dict:
        """Create research clusters for different domains"""
        clusters = {}
        
        for domain in domains:
            cluster_id = f"{domain}-{uuid.uuid4().hex[:8]}"
            clusters[cluster_id] = ResearchCluster(
                id=cluster_id,
                domain=domain,
                query=query,
                agents=self._get_domain_researchers(domain),
                tools=self._get_domain_tools(domain)
            )
        
        return clusters
    
    def _get_domain_researchers(self, domain: str) -> list:
        """Get appropriate research agents for domain"""
        domain_researchers = {
            "nixos": ["research-analyst", "nixos-architect"],
            "hardware": ["hardware-discovery", "research-analyst"],
            "security": ["security-specialist", "research-analyst"],
            "development": ["dev-environment", "research-analyst"],
            "deployment": ["deployment-orchestrator", "research-analyst"],
            "ai-tools": ["ai-integration", "research-analyst"]
        }
        
        return domain_researchers.get(domain, ["research-analyst"])
```

### Context Management
```python
class ContextManager:
    def __init__(self):
        self.project_context = ProjectContext()
        self.session_context = SessionContext()
        self.memory_integration = MemoryIntegration()
    
    def update_context(self, agent: str, action: str, data: dict):
        """Update context based on agent action"""
        
        # Update project context
        self.project_context.update(agent, action, data)
        
        # Update session context
        self.session_context.update(agent, action, data)
        
        # Store in memory system
        self.memory_integration.store(agent, action, data)
    
    def get_relevant_context(self, request: UserRequest) -> dict:
        """Get relevant context for request processing"""
        
        context = {
            "project_state": self.project_context.get_current_state(),
            "session_history": self.session_context.get_recent_history(),
            "relevant_memories": self.memory_integration.query(request.text),
            "active_workflows": self.get_active_workflows(),
            "system_status": self.get_system_status()
        }
        
        return context
    
    def get_system_status(self) -> dict:
        """Get overall system status"""
        return {
            "hosts_configured": self.project_context.get_configured_hosts(),
            "modules_created": self.project_context.get_module_count(),
            "security_status": self.project_context.get_security_status(),
            "deployment_status": self.project_context.get_deployment_status(),
            "last_update": self.project_context.get_last_update()
        }
```

## Integration Points

### Skills Integration
- Direct skill execution for simple tasks
- Skill chaining for complex workflows
- Skill validation and quality checks
- Skill performance monitoring

### Memory System Integration
- Valkey integration for persistent storage
- OpenCode SDK for knowledge management
- Context-aware memory retrieval
- Memory-based learning and adaptation

### Tool Integration
- Sequential-thinking for complex reasoning
- Brave-search for research tasks
- Context7 for documentation lookup
- Filesystem operations for configuration management
- Puppeteer for web-based tasks
- NixOS MCP for system interactions

## Quality Assurance

### Validation Pipeline
```python
class QAEngine:
    def __init__(self):
        self.validators = self._load_validators()
        self.standards = self._load_standards()
    
    def validate_output(self, agent: str, output: any, context: dict) -> ValidationResult:
        """Validate agent output against standards and requirements"""
        
        result = ValidationResult()
        
        # Run domain-specific validators
        validators = self.validators.get(agent, [])
        for validator in validators:
            validation_result = validator.validate(output, context)
            result.add_validation(validator.name, validation_result)
        
        # Check standards compliance
        standards_check = self._check_standards_compliance(output, agent)
        result.add_validation("standards", standards_check)
        
        # Security validation
        security_check = self._security_validation(output, agent)
        result.add_validation("security", security_check)
        
        # Performance validation
        performance_check = self._performance_validation(output, agent)
        result.add_validation("performance", performance_check)
        
        return result
    
    def _security_validation(self, output: any, agent: str) -> ValidationCheck:
        """Security validation for agent outputs"""
        check = ValidationCheck("security")
        
        # Check for hardcoded secrets
        if self._contains_secrets(output):
            check.add_error("Hardcoded secrets detected")
        
        # Check for insecure configurations
        if self._has_insecure_config(output):
            check.add_warning("Potentially insecure configuration")
        
        # Check for proper security practices
        if not self._follows_security_practices(output, agent):
            check.add_warning("Security best practices not followed")
        
        return check
```

## Error Handling and Recovery

### Fallback Strategies
```python
class ErrorRecovery:
    def __init__(self):
        self.fallback_strategies = {
            "agent_failure": self._handle_agent_failure,
            "workflow_failure": self._handle_workflow_failure,
            "skill_failure": self._handle_skill_failure,
            "research_failure": self._handle_research_failure
        }
    
    def handle_error(self, error: Error, context: dict) -> RecoveryResult:
        """Handle errors with appropriate recovery strategy"""
        
        error_type = self._classify_error(error)
        strategy = self.fallback_strategies.get(error_type)
        
        if strategy:
            return strategy(error, context)
        else:
            return self._handle_unknown_error(error, context)
    
    def _handle_agent_failure(self, error: Error, context: dict) -> RecoveryResult:
        """Handle agent-specific failures"""
        
        # Try alternative agent
        alternative = self._find_alternative_agent(context.agent)
        if alternative:
            return self._retry_with_alternative(alternative, context)
        
        # Fall back to manual intervention
        return self._request_manual_intervention(error, context)
```

## Performance Optimization

### Caching Strategy
- Request pattern analysis and caching
- Agent response caching
- Research result caching
- Context state caching

### Load Balancing
- Agent workload distribution
- Research swarm optimization
- Resource allocation management
- Performance monitoring

## Usage Examples

### Hardware Discovery Workflow
```python
# User request: "Scan all hosts and create hardware profiles"
request = UserRequest("Scan all hosts and create hardware profiles")

# Orchestrator processing
orchestrator = PantherOSOrchestrator()
response = orchestrator.process_request(request)

# Result: Comprehensive hardware discovery with documentation updates
```

### Security Review Workflow
```python
# User request: "Review security configuration for all hosts"
request = UserRequest("Review security configuration for all hosts")

# Orchestrator processing
response = orchestrator.process_request(request)

# Result: Security analysis with recommendations and documentation updates
```

### Research Swarm Workflow
```python
# User request: "Research best practices for NixOS module development"
request = UserRequest("Research best practices for NixOS module development")

# Orchestrator processing
response = orchestrator.process_request(request)

# Result: Comprehensive research with synthesized recommendations
```

## Configuration

### Environment Variables
```bash
# Orchestrator configuration
PANTHEROS_ORCHESTRATOR_LOG_LEVEL=info
PANTHEROS_ORCHESTRATOR_CACHE_TTL=3600
PANTHEROS_ORCHESTRATOR_MAX_CONCURRENT_WORKFLOWS=10
PANTHEROS_ORCHESTRATOR_RESEARCH_TIMEOUT=300
PANTHEROS_ORCHESTRATOR_QUALITY_THRESHOLD=0.8
```

### Agent Configuration
```yaml
# orchestrator-config.yaml
orchestrator:
  max_concurrent_workflows: 10
  default_timeout: 300
  quality_threshold: 0.8
  
agents:
  hardware-discovery:
    timeout: 600
    retry_count: 3
  
  nixos-architect:
    timeout: 900
    retry_count: 2
  
  security-specialist:
    timeout: 450
    retry_count: 3

workflows:
  hardware-discovery-comprehensive:
    timeout: 1800
    rollback_enabled: true
  
  security-review:
    timeout: 900
    rollback_enabled: true
```

## Monitoring and Observability

### Metrics Collection
- Request processing time
- Agent performance metrics
- Workflow success rates
- Quality assurance scores
- Error rates and types

### Health Checks
- Agent availability checks
- Workflow engine health
- Memory system connectivity
- Tool integration status

---

The pantherOS Orchestrator provides intelligent coordination and routing for the complete NixOS configuration system, ensuring efficient, high-quality, and consistent operations across all domains.