# System Monitoring Specification

## ADDED Requirements

### Requirement: Metrics Collection
The system SHALL collect comprehensive system metrics including CPU, memory, disk, network, and process statistics using Datadog agent (primary) or Prometheus with exporters (optional).

#### Scenario: System metrics are collected with Datadog
- **WHEN** the monitoring module is enabled with Datadog
- **THEN** Datadog agent collects system metrics continuously
- **AND** metrics include CPU usage, memory usage, disk I/O, and network traffic
- **AND** metrics are retained according to Datadog Pro subscription

#### Scenario: System metrics are collected with Prometheus (optional)
- **WHEN** the monitoring module is enabled with Prometheus
- **THEN** Prometheus collects metrics from node_exporter every 15 seconds
- **AND** metrics include CPU usage, memory usage, disk I/O, and network traffic
- **AND** metrics are retained for at least 15 days

#### Scenario: Service metrics are collected
- **WHEN** monitored services are running
- **THEN** monitoring system collects service-specific metrics (Podman, systemd)
- **AND** service health status is tracked via Datadog or Prometheus
- **AND** service restart counts are recorded

### Requirement: Metrics Visualization
The system SHALL provide dashboards for visualizing collected metrics using Datadog UI (primary) or Grafana (optional) with default dashboards for common use cases.

#### Scenario: Default dashboards are available in Datadog
- **WHEN** Datadog is configured
- **THEN** pre-configured dashboards are available in Datadog UI for system overview, resource usage, and services
- **AND** dashboards display real-time and historical data
- **AND** custom dashboards can be created in Datadog

#### Scenario: Default dashboards are available in Grafana (optional)
- **WHEN** Grafana is accessed
- **THEN** pre-configured dashboards are available for system overview, resource usage, and services
- **AND** dashboards display real-time and historical data
- **AND** users can create custom dashboards

#### Scenario: Dashboard updates in real-time
- **WHEN** viewing a dashboard
- **THEN** metrics update automatically every 5 seconds
- **AND** time ranges can be adjusted (last hour, day, week, month)
- **AND** specific metrics can be drilled down for details

### Requirement: Alert Management
The system SHALL support configurable alerts for critical system conditions with notification capabilities.

#### Scenario: High CPU usage triggers alert
- **WHEN** CPU usage exceeds 90% for 5 minutes
- **THEN** an alert is triggered
- **AND** notification is sent via configured channels
- **AND** alert shows in Grafana UI

#### Scenario: Low disk space triggers alert
- **WHEN** available disk space falls below 10%
- **THEN** a critical alert is triggered
- **AND** notification includes affected mount point
- **AND** historical usage trends are linked

#### Scenario: Service failure triggers alert
- **WHEN** a monitored systemd service fails
- **THEN** an alert is triggered immediately
- **AND** notification includes service name and failure reason
- **AND** restart attempts are tracked

### Requirement: Monitoring Configuration
The system SHALL provide NixOS module options for enabling and configuring the monitoring stack with sensible defaults.

#### Scenario: Enable monitoring with Datadog on a host
- **WHEN** `services.monitoring.enable = true` and `services.monitoring.provider = "datadog"` is set
- **THEN** Datadog agent is installed and started
- **AND** Datadog API key is configured (from OpNix secrets once available)
- **AND** default integrations are configured
- **AND** agent starts automatically on boot

#### Scenario: Enable monitoring with Prometheus/Grafana on a host (optional)
- **WHEN** `services.monitoring.enable = true` and `services.monitoring.provider = "prometheus"` is set
- **THEN** Prometheus, Grafana, and exporters are installed and started
- **AND** default configuration is applied
- **AND** services start automatically on boot

#### Scenario: Customize retention period
- **WHEN** `programs.monitoring.retentionDays` is configured
- **THEN** Prometheus retains metrics for the specified duration
- **AND** old data is automatically pruned
- **AND** disk usage is controlled

#### Scenario: Configure alert notifications
- **WHEN** `programs.monitoring.alerting.channels` is configured
- **THEN** alerts are sent to specified channels (email, webhook, etc.)
- **AND** notification templates can be customized
- **AND** alert routing rules can be defined

### Requirement: Security and Access Control
The system SHALL secure monitoring endpoints and require authentication for access to metrics and dashboards.

#### Scenario: Grafana requires authentication
- **WHEN** accessing Grafana UI
- **THEN** user must authenticate with username and password
- **AND** default admin credentials are generated securely
- **AND** user accounts can be managed

#### Scenario: Prometheus API is localhost-only
- **WHEN** Prometheus is running
- **THEN** API endpoints listen only on localhost by default
- **AND** external access requires explicit configuration
- **AND** firewall rules protect monitoring ports

### Requirement: Performance Impact
The system SHALL minimize monitoring overhead to ensure minimal impact on host performance with configurable resource limits.

#### Scenario: Monitoring uses acceptable resources
- **WHEN** monitoring is enabled
- **THEN** total CPU usage for monitoring services is within configured limits (default: 5% under normal load)
- **AND** memory usage is within configured limits (default: 500MB)
- **AND** disk I/O impact is minimal (default: < 1% of total I/O)
- **AND** resource limits can be adjusted per host profile
