# Hetzner Cloud VPS Specific Configuration

This document covers Hetzner Cloud-specific considerations for your NixOS deployment.

## Server Types and Recommendations

### Available Server Types
- **CPX Series**: AMD EPYC processors, good for general purpose workloads
  - CPX11: 2 vCPU, 2 GB RAM, €2.89/month
  - CPX21: 3 vCPU, 4 GB RAM, €5.78/month
  - CPX31: 4 vCPU, 8 GB RAM, €11.56/month

- **CCX Series**: AMD EPYC processors, optimized for compute-intensive tasks
- **CAX Series**: ARM-based AMD processors, cost-effective option
- **CX Series**: Intel Xeon processors

### Recommended Setup
For NixOS deployment, we recommend:
- Minimum CX21 or CPX21 for development
- CPX31 or higher for production workloads
- Consider your build requirements when choosing RAM and CPU

## Network Configuration

### Primary Network
- Hetzner Cloud provides DHCP by default
- IPv4 and IPv6 are both supported
- Private networks available for multi-server setups

### Firewall Settings
- Configure Cloud Firewall in the Hetzner Console
- Default SSH access on port 22
- Additional ports as needed for your applications

### Floating IPs
- Use floating IPs for high availability setups
- Can be reassigned between servers programmatically

## Storage Options

### Volume Recommendations
- Your configuration uses Btrfs with optimizations:
  - `noatime` reduces unnecessary writes
  - `compress=zstd` saves space
  - `space_cache=v2` improves mount times

### Backup Solutions
- Hetzner provides automated backups (paid feature)
- Consider implementing your own backup solution
- Use snapshots for critical data protection

## Deployment Process

### Initial Setup
1. Create server instance with temporary OS (Ubuntu/Debian)
2. Add your SSH keys to the instance
3. Note the server IP address
4. Use nixos-anywhere for the initial deployment

### Rescue Mode
- Accessible through Hetzner Console
- Useful for troubleshooting and recovery
- Available in multiple OS options

## Security Considerations

### Hetzner Console Access
- Root password can be reset via console
- SSH key management through the web interface
- Two-factor authentication recommended

### Network Security
- Use Hetzner Cloud Firewall for port restrictions
- Consider WAF for web applications
- Regular security updates through NixOS channels

## Monitoring and Management

### Hetzner Monitoring
- Built-in server monitoring
- Resource utilization graphs
- Alerting capabilities

### Custom Monitoring
- Your NixOS configuration can include monitoring tools
- Consider Prometheus/Grafana for detailed metrics
- Log aggregation solutions

## Cost Optimization

### Pricing Considerations
- Hourly billing for flexible usage
- Monthly billing for consistent workloads
- Volume discounts for multiple servers

### Resource Management
- Scale resources based on actual usage
- Use Hetzner's API for automated scaling
- Consider spot instances for non-critical workloads

## Troubleshooting Common Issues

### Boot Issues
- Ensure UEFI settings match your configuration
- Check that the correct disk device is specified (`/dev/sda`)
- Verify bootloader configuration

### Network Connectivity
- Check Hetzner Cloud Firewall settings
- Verify security groups and network ACLs
- Confirm DHCP is properly configured

### Performance Issues
- Monitor I/O performance for storage-intensive applications
- Check if you're hitting resource limits
- Consider upgrading server type if needed

## Advanced Features

### Load Balancers
- Hetzner Cloud Load Balancers for high availability
- Health checks and automatic failover
- SSL termination capabilities

### Private Networks
- Internal networking between your servers
- Isolated from public internet
- Higher security for internal communication

### API Integration
- Full API access for automation
- Terraform provider available
- Infrastructure as Code possibilities

## Migration Considerations

### From Other Providers
- Plan migration during low-traffic periods
- Test configurations before migration
- Ensure DNS records are updated properly

### Scaling Up
- Horizontal scaling with additional instances
- Vertical scaling by changing server types
- Database replication for stateful applications

## Best Practices

1. **Regular Backups**: Implement both Hetzner and custom backup solutions
2. **Monitoring**: Set up comprehensive monitoring and alerting
3. **Security**: Keep SSH keys updated and review access regularly
4. **Cost Management**: Monitor usage and optimize resources
5. **Documentation**: Keep deployment procedures documented
6. **Testing**: Test configurations in similar environments before production
7. **Automation**: Use Hetzner API for infrastructure management

## Integration with NixOS Configuration

Your current configuration is already optimized for Hetzner Cloud:
- UEFI boot support for modern cloud infrastructure
- Console access via `ttyS0` for out-of-band management
- Btrfs with cloud-optimized settings
- Security-hardened SSH configuration

This setup provides a solid foundation for deploying and managing your services on Hetzner Cloud.