# OpenSpec Proposal 004: Enhanced Monitoring - Phase 4

**Status**: 📋 Proposed  
**Created**: 2025-11-22  
**Authors**: MiniMax Agent, Copilot Workspace Agent  
**Phase**: Research Tasks Phase 4  
**Related**: pantherOS_executable_research_plan.md, TASK-017, TASK-018

## Summary

Implementation of enhanced monitoring modules for custom metrics collection and log aggregation, providing comprehensive observability for pantherOS systems with integration into existing monitoring infrastructure.

## Motivation

### Problem Statement

pantherOS currently has:
- Basic Datadog agent integration
- No custom metrics framework
- Limited log aggregation capabilities
- No centralized logging solution
- Minimal system observability

### Impact

Without enhanced monitoring:
- Difficult to diagnose system issues
- No visibility into custom application metrics
- Scattered log files across the system
- Manual log analysis required
- Limited proactive monitoring

### Goals

1. Enable custom metrics collection and reporting
2. Implement centralized log aggregation
3. Provide dashboards and visualization
4. Support multiple monitoring backends
5. Enable proactive system monitoring

## Proposal

### Module Architecture

**Layer**: `modules/monitoring/*`  
**Namespace**: `pantherOS.monitoring.*`  
**Integration**: Compatible with all pantherOS modules

### Planned Modules

#### 1. Custom Metrics Module (TASK-017)
**File**: `code_snippets/system_config/nixos/custom-metrics.nix.md`  
**Target Lines**: 500-600

**Features**:
- Custom metric collection and export
- Integration with monitoring platforms (Datadog, Prometheus, InfluxDB)
- System resource metrics (CPU, memory, disk, network)
- Application performance metrics
- Custom metric definitions
- Dashboard templates and visualization
- Alert threshold configuration
- Metric aggregation and rollup

**Configuration Options**:
```nix
pantherOS.monitoring.metrics = {
  enable = true;
  
  backend = {
    datadog = {
      enable = true;
      apiKey = "DD_API_KEY";
    };
    prometheus = {
      enable = false;
      port = 9090;
    };
  };
  
  system = {
    enable = true;
    interval = 60; # seconds
    metrics = [
      "cpu"
      "memory"
      "disk"
      "network"
      "temperature"
    ];
  };
  
  custom = [
    {
      name = "app.requests.total";
      type = "counter";
      description = "Total application requests";
    }
    {
      name = "app.latency";
      type = "histogram";
      description = "Request latency in ms";
    }
  ];
  
  dashboards = {
    enable = true;
    templates = [ "system-overview" "application-performance" ];
  };
  
  alerts = {
    enable = true;
    thresholds = {
      cpu_high = { value = 80; duration = "5m"; };
      memory_high = { value = 90; duration = "3m"; };
      disk_full = { value = 95; duration = "1m"; };
    };
  };
};
```

**Key Features**:
- Multiple backend support (Datadog, Prometheus, InfluxDB)
- System and application metrics
- Custom metric definitions
- Dashboard creation and templating
- Alert configuration
- Metric retention policies

#### 2. Log Aggregation Module (TASK-018)
**File**: `code_snippets/system_config/nixos/log-aggregation.nix.md`  
**Target Lines**: 500-600

**Features**:
- Centralized log collection (journald, file-based, syslog)
- Log forwarding to aggregation platforms
- Log parsing and enrichment
- Log retention and rotation
- Log search and filtering
- Security event logging
- Application log integration
- Log-based alerting

**Configuration Options**:
```nix
pantherOS.monitoring.logs = {
  enable = true;
  
  collection = {
    journald = {
      enable = true;
      units = [ "systemd" "user" ];
    };
    
    files = [
      {
        path = "/var/log/nginx/*.log";
        format = "nginx";
      }
      {
        path = "/var/log/app/*.log";
        format = "json";
      }
    ];
    
    syslog = {
      enable = false;
      port = 514;
    };
  };
  
  forwarding = {
    enable = true;
    destinations = [
      {
        type = "elasticsearch";
        host = "logs.example.com";
        port = 9200;
        index = "pantherOS-logs";
      }
      {
        type = "datadog";
        apiKey = "DD_API_KEY";
        site = "datadoghq.com";
      }
    ];
  };
  
  parsing = {
    enable = true;
    patterns = [
      {
        name = "nginx_access";
        regex = ''(\d+\.\d+\.\d+\.\d+) .* "(\w+) ([^"]*) HTTP/\d\.\d" (\d+)'';
        fields = [ "ip" "method" "path" "status" ];
      }
    ];
  };
  
  retention = {
    local = "7d";
    remote = "30d";
  };
  
  alerts = {
    enable = true;
    rules = [
      {
        name = "error_rate_high";
        condition = "error_count > 100 in 5m";
        action = "notify";
      }
      {
        name = "security_event";
        condition = "level == CRITICAL";
        action = "page";
      }
    ];
  };
  
  security = {
    eventLogging = true;
    auditIntegration = true;
  };
};
```

**Key Features**:
- Multiple log sources (journald, files, syslog)
- Log forwarding to multiple destinations
- Log parsing and structuring
- Retention policies
- Log-based alerting
- Security event integration

## Implementation Plan

### Phase 4.1: Custom Metrics (Week 1)
- TASK-017: Custom Metrics Module
  - Day 1-2: Core metrics collection
  - Day 3-4: Backend integrations (Datadog, Prometheus)
  - Day 5: Dashboard templates
  - Day 6-7: Alert configuration and testing

### Phase 4.2: Log Aggregation (Week 2)
- TASK-018: Log Aggregation Module
  - Day 1-2: Log collection from multiple sources
  - Day 3-4: Log forwarding and parsing
  - Day 5: Retention and alerting
  - Day 6-7: Security integration and testing

## Success Criteria

### Functional Requirements
- [ ] Metrics collection from system and applications
- [ ] Log aggregation from multiple sources
- [ ] Dashboard visualization working
- [ ] Alerts triggering correctly
- [ ] Integration with existing monitoring

### Quality Metrics
- [ ] Metrics module: 500-600 lines
- [ ] Logs module: 500-600 lines
- [ ] Configuration options: 25-35 per module
- [ ] Usage examples: 8-12 per module
- [ ] Integration examples: 4-6 per module

### Performance
- [ ] Metrics collection overhead < 5% CPU
- [ ] Log forwarding latency < 1 second
- [ ] Dashboard query response < 2 seconds
- [ ] Alert evaluation latency < 30 seconds

### Reliability
- [ ] Metrics collection uptime > 99.9%
- [ ] Log forwarding success rate > 99.5%
- [ ] No log data loss under normal conditions

## Dependencies

### Prerequisites
- Phase 1-3: All previous modules
- Monitoring backend (Datadog, Prometheus, or Elasticsearch)
- Network connectivity to monitoring services

### Module Dependencies
- Metrics → System resources (Phase 1 hardware modules)
- Logs → Security audit (Phase 1 security module)
- Both → Networking configuration

### External Dependencies
- Datadog Agent (optional)
- Prometheus exporter libraries (optional)
- Log forwarding agents (Vector, Fluentd, or Filebeat)
- Elasticsearch/Kibana (optional)

## Integration Examples

### Complete Observability Stack
```nix
{
  # Phase 1-3: Foundation
  pantherOS = {
    hardware.thermal.monitoring.enable = true;
    development.git.enable = true;
  };
  
  # Phase 4: Monitoring
  pantherOS.monitoring = {
    metrics = {
      enable = true;
      backend.datadog.enable = true;
      system.enable = true;
      dashboards.enable = true;
      alerts.enable = true;
    };
    
    logs = {
      enable = true;
      collection.journald.enable = true;
      forwarding = {
        enable = true;
        destinations = [
          { type = "datadog"; apiKey = "DD_API_KEY"; }
        ];
      };
      alerts.enable = true;
    };
  };
}
```

### Self-Hosted Monitoring
```nix
{
  pantherOS.monitoring = {
    metrics = {
      enable = true;
      backend.prometheus = {
        enable = true;
        port = 9090;
      };
      dashboards.enable = true;
    };
    
    logs = {
      enable = true;
      forwarding.destinations = [
        {
          type = "elasticsearch";
          host = "localhost";
          port = 9200;
        }
      ];
    };
  };
}
```

## Alternatives Considered

### 1. Third-Party Monitoring Only
**Rejected**: Requires external dependencies, not self-contained

### 2. Basic Logging Without Aggregation
**Rejected**: Doesn't meet observability requirements

### 3. Prometheus-Only Metrics
**Rejected**: Limits backend flexibility

## Future Work

### Short-term
- Distributed tracing integration
- Application Performance Monitoring (APM)
- Network traffic monitoring

### Medium-term
- Machine learning anomaly detection
- Predictive alerting
- Capacity planning tools

### Long-term
- Full observability platform
- Incident management integration
- Self-healing automation

## Timeline

**Start Date**: 2025-12-21  
**Target Completion**: 2026-01-03 (2 weeks)

### Milestones
- Week 1: Custom Metrics module complete
- Week 2: Log Aggregation module complete
- Final validation: 2-3 days

## References

- Datadog Documentation
- Prometheus Best Practices
- Log Aggregation Patterns
- pantherOS Gap Analysis

## Approval Status

**Proposed**: 2025-11-22  
**Approved**: Pending (requires Phase 3 completion)  
**Implementation Start**: After Phase 3 validation

---

**Previous**: [003-advanced-integration-phase-3.md](./003-advanced-integration-phase-3.md)  
**End of Research Tasks**: This completes the 18-task research plan
