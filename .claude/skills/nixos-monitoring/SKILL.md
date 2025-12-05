---
name: NixOS Monitoring
description: Set up monitoring infrastructure with Prometheus metrics collection and Grafana visualization dashboards. When configuring Prometheus, Grafana, or system monitoring exporters.
---
# NixOS Monitoring

## When to use this skill:

- Setting up Prometheus server for metrics collection
- Configuring Prometheus exporters (node, blackbox, nginx)
- Installing and configuring Grafana dashboards
- Setting up alertmanager for notifications
- Monitoring system resources (CPU, memory, disk, network)
- Creating custom metrics and exporters
- Configuring Grafana data sources
- Setting up Grafana authentication and organizations
- Monitoring application performance and logs
- Creating alerting rules and notification channels

## Best Practices
- services.prometheus.enable = true; services.prometheus.exporters.node.enable = true; exporters.grafana.enable = true;
- services.grafana.enable = true; services.grafana.settings.server.rootUrl = &quot;%req:Host%&quot;;
