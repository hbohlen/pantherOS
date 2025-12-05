# Service Management

Best practices for managing systemd services in NixOS configurations.

## Service Definition Structure

```nix
systemd.services.service-name = {
  description = "Clear, descriptive description";
  after = ["network.target"];  # Add dependencies
  wantedBy = ["multi-user.target"];  # When to start

  serviceConfig = {
    Type = "oneshot";  # Choose appropriate type
    User = "username";  # Run as specific user
    # Additional configuration
  };

  script = ''  # OR
  execStart = '';  # Use script for complex logic, execStart for simple commands
    # Service logic here
  '';
};
```

## Service Types

- **oneshot**: For services that run once and exit (cleanup tasks, initialization)
- **simple**: For services that run continuously (default)
- **forking**: For services that fork background processes
- **notify**: For services that send sd_notify() signals

## Timer Units

```nix
systemd.services.task = {
  # Service definition
};

systemd.timers.task = {
  description = "Description of the timer";
  wantedBy = ["timers.target"];
  timerConfig = {
    OnCalendar = "daily";  # or "weekly", "monthly"
    Persistent = true;  # Run missed instances on boot
    RandomizedDelaySec = "1h";  # Spread load
  };
};
```

- **Use Persistent = true**: Ensures timers catch up after downtime
- **Add RandomizedDelaySec**: Prevents synchronized service starts across multiple hosts
- **Document schedule**: Comment what the schedule means
- **Use OnCalendar**: For cron-like schedules, use standard systemd calendar format

## Service Best Practices

- **Use absolute paths**: Always use `${pkgs.package}/bin/command` not just `command`
- **Handle errors gracefully**: Use `|| true` for commands that may fail
- **Set appropriate timeouts**: Configure service timeouts based on expected runtime
- **Use ExecStartPre**: For pre-start validation or setup
- **Clean up on failure**: Consider cleanup actions for failed services

## Resource Limits

```nix
# For development workloads
security.pam.loginLimits = [
  {
    domain = "*";
    item = "nofile";
    type = "-";
    value = "262144";
  }
];
```

- **Set limits for containers**: Podman/Docker need higher file descriptor limits
- **Configure noproc**: Set process limits appropriately
- **Document why**: Comment on non-standard limits and their purpose

## Network Services

- **Secure configuration**: Use key-based auth only, disable password auth
- **Restrict interfaces**: Bind services to specific network interfaces when possible
- **Use proper firewall rules**: Open only necessary ports

Example:
```nix
networking.firewall = {
  enable = true;
  allowedTCPPorts = [22 80 443];
  trustedInterfaces = ["tailscale0"];
};
```

## Container Services

- **Enable dockerCompat**: For Podman, enable docker compatibility
- **Configure DNS**: Enable DNS resolution for containers
- **Optimize storage**: Use appropriate storage drivers and options

```nix
virtualisation.podman = {
  enable = true;
  dockerCompat = true;
  defaultNetwork.settings.dns_enabled = true;
};
```
