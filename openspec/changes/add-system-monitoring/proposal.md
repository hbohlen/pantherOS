# Change: Add System Monitoring Infrastructure

## Why

The system currently lacks comprehensive monitoring and observability. While individual monitoring tools exist (htop, btop, nvtop), there's no centralized monitoring solution that provides:
- System metrics collection and visualization
- Service health monitoring
- Resource usage tracking over time
- Alerting capabilities
- Historical data for debugging and optimization

This makes it difficult to identify performance bottlenecks, track system health, and proactively address issues.

## What Changes

- Add Prometheus for metrics collection
- Add Grafana for visualization and dashboards
- Add node_exporter for system metrics
- Add alertmanager for notification management
- Create default dashboards for common metrics (CPU, memory, disk, network)
- Configure integration with existing services (Podman, Mutagen, etc.)
- Add systemd service monitoring
- Create monitoring module structure that can be enabled per-host

## Impact

### Affected Specs
- New capability: `system-monitoring` (metrics collection, visualization, alerting)
- Modified capability: `configuration` (add monitoring options to system configuration)

### Affected Code
- New module: `modules/monitoring/` with submodules for Prometheus, Grafana, exporters
- Host configurations: Optional monitoring enablement in `hosts/*/default.nix`
- New package category: monitoring tools in `modules/packages/monitoring/default.nix`

### Benefits
- Proactive issue detection through metrics and alerts
- Historical data for performance analysis
- Better understanding of resource utilization
- Foundation for capacity planning
- Debugging support through detailed metrics

### Considerations
- Resource overhead: Prometheus and Grafana use additional CPU/memory
- Storage requirements: Time-series data needs disk space
- Configuration complexity: Dashboards and alert rules require maintenance
- Security: Need to secure monitoring endpoints
