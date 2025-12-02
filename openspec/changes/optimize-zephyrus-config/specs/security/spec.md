# Spec: Security & Authentication

## ADDED Requirements

### 1Password Integration
The system must integrate 1Password for secret management and SSH authentication.

#### Scenario: 1Password App
Given the user logs in
Then the 1Password GUI application should be available
And the 1Password CLI (`op`) should be available

#### Scenario: SSH Agent
Given the user attempts an SSH connection
When authentication is required
Then the 1Password SSH agent should handle the request
