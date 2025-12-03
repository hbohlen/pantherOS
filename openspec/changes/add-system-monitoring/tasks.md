# Implementation Tasks: System Monitoring

## 1. Core Infrastructure
- [ ] 1.1 Create `modules/monitoring/default.nix` with enable option and provider selection (Datadog/Prometheus)
- [ ] 1.2 Create `modules/monitoring/datadog.nix` for Datadog agent configuration (primary)
- [ ] 1.3 Create `modules/monitoring/prometheus.nix` with Prometheus configuration (optional)
- [ ] 1.4 Create `modules/monitoring/grafana.nix` with Grafana setup (optional)
- [ ] 1.5 Create `modules/monitoring/loki.nix` for log aggregation (optional)
- [ ] 1.6 Create `modules/monitoring/exporters.nix` for node_exporter and other exporters
- [ ] 1.7 Create `modules/monitoring/alertmanager.nix` for alert configuration (Prometheus)

## 2. Default Configuration
- [ ] 2.1 Configure Datadog agent with API key from OpNix secrets
- [ ] 2.2 Set up Datadog integrations for system metrics and services
- [ ] 2.3 Configure Datadog dashboards and monitors
- [ ] 2.4 (Optional) Configure Prometheus scrape targets for system metrics
- [ ] 2.5 (Optional) Set up default Grafana dashboards (system overview, resources, services)
- [ ] 2.6 Configure retention policies (Datadog: per subscription, Prometheus default: 15 days)
- [ ] 2.7 Set up default alert rules (high CPU, low disk, service down)
- [ ] 2.8 Configure notification channels (Datadog or alertmanager)

## 3. Service Integration
- [ ] 3.1 Configure Datadog container integration for Podman
- [ ] 3.2 Configure Datadog systemd integration for service monitoring
- [ ] 3.3 Add Btrfs filesystem metrics collection
- [ ] 3.4 Add network interface metrics
- [ ] 3.5 Add NVIDIA GPU metrics (for systems with GPUs)
- [ ] 3.6 Configure Datadog log collection from journald

## 4. Security & Access Control
- [ ] 4.1 Configure authentication for Grafana
- [ ] 4.2 Set up firewall rules for monitoring ports
- [ ] 4.3 Configure HTTPS for Grafana (optional, with Let's Encrypt)
- [ ] 4.4 Restrict Prometheus API access to localhost by default

## 5. Documentation
- [ ] 5.1 Document monitoring module options and configuration
- [ ] 5.2 Create usage guide with common queries and dashboard usage
- [ ] 5.3 Document alert rule customization
- [ ] 5.4 Add troubleshooting guide for common monitoring issues

## 6. Testing & Validation
- [ ] 6.1 Test monitoring stack on development host
- [ ] 6.2 Verify metrics collection from all exporters
- [ ] 6.3 Test dashboard rendering and data visualization
- [ ] 6.4 Verify alert triggering and notification delivery
- [ ] 6.5 Test monitoring overhead impact on system performance
