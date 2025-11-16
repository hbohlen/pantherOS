# 1Password Developer Documentation - Master Guide

**Last Updated:** 2025-11-15 10:16:10  
**Author:** MiniMax Agent  
**Purpose:** Complete 1Password developer tools and integration reference

## Executive Summary

1Password Developer provides a comprehensive suite of tools and APIs for integrating 1Password's secure secret management into developer workflows, applications, and CI/CD pipelines. This guide consolidates all developer documentation for streamlined access and implementation.

## Table of Contents

1. [1Password CLI](#cli)
2. [SSH & Git Integration](#ssh-git)
3. [Service Accounts](#service-accounts) 
4. [Software Development Kits](#sdks)
5. [Secrets Management](#secrets-management)
6. [GitHub Integration](#github-integration)
7. [Environment Variables](#environment-variables)
8. [Template & Reference Syntax](#templates)
9. [Automation & Connect Server](#automation)
10. [Security Best Practices](#security)

## <a name="cli"></a>1Password CLI

### Installation

#### System Requirements
- **Mac**: All versions with 1Password app
- **Windows**: Windows 10+ with 1Password app
- **Linux**: APT, YUM, Alpine, NixOS, or manual installation

#### Linux Installation Methods

##### APT (Debian/Ubuntu)
```bash
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install 1password-cli
```

##### YUM (RHEL/CentOS/Fedora)
```bash
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://rpm.1password.com/stable/$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc" > /etc/yum.repos.d/1password-stable.repo'
sudo yum install 1password-cli
```

##### Manual Installation
```bash
# Download and install manually
ARCH="amd64"  # Choose: 386/amd64/arm/arm64
wget "https://cache.agilebits.com/dist/1P/op2/pkg/v2.32.0/op_linux_${ARCH}_v2.32.0.zip" -O op.zip
unzip -d op op.zip
sudo mv op/op /usr/local/bin/
rm -r op.zip op
sudo groupadd -f onepassword-cli
sudo chgrp onepassword-cli /usr/local/bin/op
sudo chmod g+s /usr/local/bin/op
```

#### Setup and Authentication

##### Initial Setup
```bash
# Verify installation
op --version

# Sign in to your 1Password account
op signin

# Or sign in to a specific account
op signin my.1password.com user@example.com
```

##### Biometric Authentication
```bash
# Enable Touch ID/Windows Hello for CLI operations
op biometric-unlock enable

# Test biometric unlock
op biometric-unlock test
```

### Core CLI Commands

#### Authentication Management
```bash
# Sign in
op signin

# Sign out
op signout

# Check authentication status
op whoami

# Sign in with service account
op signin --account mycompany --service-account
```

#### Item Management
```bash
# Create a new item
op item create --category "Login" --title "My App" --username "user@example.com" --password "secret123"

# Create SSH key item
op item create --category ssh --title "My SSH Key"

# Read item content
op read "op://Personal/My App/username"

# Update item
op edit "op://Personal/My App" --password "newsecret"

# Delete item
op item delete "op://Personal/My App"
```

#### Vault Management
```bash
# List vaults
op vault list

# Create vault
op vault create "Development Secrets"

# Get vault contents
op item list --vault "Development Secrets"
```

#### Secret References
```bash
# Basic secret reference
op read "op://Personal/My App/password"

# With field specification
op read "op://Personal/My App/username"

# With formatting options
op read "op://Personal/Database/password?format=json"

# SSH key in OpenSSH format
op read "op://Private/SSH Keys/my-key/private key?ssh-format=openssh"
```

## <a name="ssh-git"></a>SSH & Git Integration

### SSH Key Management

#### Generate SSH Keys
```bash
# Generate Ed25519 key (default)
op item create --category ssh --title "My SSH Key"

# Generate RSA key with custom size
op item create --category ssh --title "RSA SSH Key" --ssh-generate-key RSA,2048

# Generate specific key types
op item create --category ssh --title "ECDSA Key" --ssh-generate-key ECDSA
```

#### Retrieve and Use SSH Keys
```bash
# Get private key in OpenSSH format
op read "op://Private/SSH Keys/my-key/private key?ssh-format=openssh"

# Get public key
op read "op://Private/SSH Keys/my-key/public key"

# Use with SSH agent
eval $(op ssh-agent)
```

#### SSH Configuration
```bash
# Add to ~/.ssh/config
Host github.com
    IdentityAgent "1Password SSH Agent"
    IdentityFile "op://Private/SSH Keys/github/private key"

Host gitlab.com
    IdentityAgent "1Password SSH Agent"
    IdentityFile "op://Private/SSH Keys/gitlab/private key"
```

### Git Integration

#### Git Commit Signing
```bash
# Configure Git to use 1Password for signing
git config --global gpg.format ssh
git config --global user.signingkey "op://Private/SSH Keys/git-signing/private key"

# Sign commits automatically
git config --global commit.gpgsign true

# Sign tags
git tag -s v1.0.0 -m "Release v1.0.0"
```

#### SSH Agent Setup
```bash
# Start 1Password SSH agent
eval $(op ssh-agent)

# Add SSH keys automatically
op ssh-agent load

# Verify loaded keys
ssh-add -l
```

### Advanced SSH Features

#### SSH Bookmarks (Beta)
```bash
# Create SSH bookmark
op ssh bookmark create --title "GitHub Work" --username "worker@company.com"

# Use bookmark
ssh $(op ssh bookmark get "GitHub Work")
```

#### SSH Agent Forwarding
```bash
# Enable agent forwarding in SSH config
Host bastion.company.com
    ForwardAgent yes
    RemoteCommand eval $(op ssh-agent)

# Use forwarded agent from remote
ssh user@bastion.company.com
ssh-add -l  # Should show 1Password keys
```

## <a name="service-accounts"></a>Service Accounts

### Overview

Service accounts provide non-interactive access to 1Password vaults, ideal for:
- CI/CD pipelines
- Server deployments
- Automated workflows
- Application authentication

### Creating Service Accounts

#### Via CLI
```bash
# Create service account
op service-account create --name "CI/CD Pipeline" --description "Automated deployments"

# Create with specific permissions
op service-account create \
  --name "Production Deploy" \
  --vault-permissions "Production:read,read-item-secrets,write-item-secrets" \
  --can-manage-service-accounts false
```

#### Via Web Interface
1. Go to 1Password Admin Console
2. Navigate to Service Accounts
3. Click "Create Service Account"
4. Configure permissions and access
5. Generate API token

### Service Account Usage

#### Authentication
```bash
# Sign in with service account
op signin --account mycompany --service-account

# Or use environment variable
export OP_SERVICE_ACCOUNT_TOKEN="your-service-account-token"
op read "op://Production/Database/password"
```

#### Permissions Management
```bash
# List service account permissions
op service-account list --account mycompany

# Update service account permissions
op service-account update \
  --account mycompany \
  --service-account "CI/CD Pipeline" \
  --vault-permissions "Staging:read,Production:read"
```

### Best Practices

#### Security Guidelines
- Use service accounts only when interactive login is not possible
- Grant minimal necessary permissions
- Rotate service account tokens regularly
- Monitor service account usage
- Use separate accounts for different environments

#### Example CI/CD Configuration
```yaml
# GitHub Actions
- name: Deploy to Production
  env:
    OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
  run: |
    op read "op://Production/Database/password" | \
    DATABASE_PASSWORD=$(op read "op://Production/Database/password")
    deploy --password "$DATABASE_PASSWORD"
```

## <a name="sdks"></a>Software Development Kits

### Available SDKs

- **JavaScript/TypeScript**: `@1password/sdk`
- **Python**: `onepassword-sdk`
- **Go**: `github.com/1password/sdk-go`
- **Rust**: `onepassword-sdk`
- **Java**: Available via REST API
- **PHP**: Available via REST API

### JavaScript/TypeScript SDK

#### Installation
```bash
npm install @1password/sdk
# or
yarn add @1password/sdk
```

#### Basic Usage
```typescript
import { Client } from "@1password/sdk";

const client = new Client({
  auth: {
    serviceAccountToken: process.env.OP_SERVICE_ACCOUNT_TOKEN,
  },
});

async function getSecret() {
  const secret = await client.secrets.resolve(
    "op://MyVault/Database/password"
  );
  
  console.log(secret);
}

// Sign in interactively for development
const client = await Client.signInWithSecretKey();
```

#### Advanced Usage
```typescript
import { Client } from "@1password/sdk";

// Batch operations
async function loadEnvironment() {
  const [
    databaseUrl,
    apiKey,
    redisPassword
  ] = await Promise.all([
    client.secrets.resolve("op://MyVault/Database/url"),
    client.secrets.resolve("op://MyVault/API/secret-key"),
    client.secrets.resolve("op://MyVault/Redis/password")
  ]);
  
  return {
    DATABASE_URL: databaseUrl,
    API_KEY: apiKey,
    REDIS_PASSWORD: redisPassword
  };
}

// Create items
async function createCredentials(serviceName: string) {
  const item = await client.items.create({
    title: `${serviceName} Credentials`,
    category: "Login",
    fields: [
      {
        id: "username",
        type: "text",
        value: "service-account",
      },
      {
        id: "password",
        type: "concealed",
        value: generatePassword(),
      },
    ],
  });
  
  return item;
}
```

### Python SDK

#### Installation
```bash
pip install onepassword-sdk
```

#### Basic Usage
```python
from onepassword import Client

# Service account authentication
client = Client(
    auth={"service_account_token": "your-token"}
)

# Read secret
secret = client.secrets.resolve("op://MyVault/Database/password")
print(secret)

# Create item
item = client.items.create({
    "title": "API Credentials",
    "category": "Login",
    "fields": [
        {"id": "username", "type": "text", "value": "api-user"},
        {"id": "password", "type": "concealed", "value": "secret123"}
    ]
})
```

### Go SDK

#### Installation
```bash
go get github.com/1password/sdk-go
```

#### Basic Usage
```go
package main

import (
    "context"
    "fmt"
    "os"
    
    "github.com/1password/sdk-go"
)

func main() {
    client, err := sdk.NewClient(sdk.ClientOptions{
        Auth: sdk.Auth{
            ServiceAccountToken: os.Getenv("OP_SERVICE_ACCOUNT_TOKEN"),
        },
    })
    if err != nil {
        panic(err)
    }
    
    secret, err := client.S.Resolve(context.Background(), "op://MyVault/Database/password")
    if err != nil {
        panic(err)
    }
    
    fmt.Println(secret)
}
```

## <a name="secrets-management"></a>Secrets Management

### Environment Variables

#### Loading into Environment
```bash
# Load all secrets from a vault
eval $(op env --generate-env --shell bash)

# Load specific secrets
export DATABASE_URL=$(op read "op://MyVault/Database/url")
export API_KEY=$(op read "op://MyVault/API/key")

# Load with prefix
eval $(op env --prefix "APP_" --generate-env)
```

#### .env File Management
```bash
# Generate .env file
op env --generate-env --file .env

# Template-based .env
op env --template .env.template --generate-env --file .env

# Update existing .env file
op env --file .env --update
```

### Shell Integration

#### Bash/Zsh Integration
```bash
# Add to ~/.bashrc or ~/.zshrc
export OP_PLUGIN_DIR="$HOME/.local/share/1password/plugins"
eval "$(op completion bash)"

# Load secrets automatically
if command -v op &> /dev/null; then
    eval $(op env --generate-env --shell bash)
fi
```

#### Fish Shell Integration
```bash
# Fish shell setup
eval (op completion fish)
eval (op env --generate-env --shell fish)

# Load secrets in fish
if command -v op &> /dev/null
    eval (op env --generate-env --shell fish)
end
```

### Application Integration

#### Node.js
```typescript
import { loadEnv } from "@1password/sdk";

async function loadApplicationSecrets() {
  const env = await loadEnv({
    source: "op://MyVault/Environment/default",
    format: "dotenv"
  });
  
  Object.entries(env).forEach(([key, value]) => {
    process.env[key] = value;
  });
}
```

#### Python
```python
import os
from onepassword import load_env

# Load secrets into environment
load_env("op://MyVault/Environment/production")

# Or load specific file
load_env("op://MyVault/Environment/app", format="dotenv")
```

## <a name="github-integration"></a>GitHub Integration

### GitHub Actions

#### Basic Setup
```yaml
name: Deploy Application

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3
        
      - name: Install 1Password CLI
        run: |
          curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
          echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
          sudo apt update && sudo apt install 1password-cli
          
      - name: Sign in to 1Password
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
        run: op signin --account mycompany --service-account
          
      - name: Deploy application
        env:
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          API_KEY: ${{ secrets.API_KEY }}
        run: |
          echo "Deploying with database URL: $DATABASE_URL"
          deploy-script.sh
```

#### Using GitHub CLI with 1Password
```bash
# Authenticate GitHub CLI with 1Password
gh auth login --with-token | op run -- gh auth login --with-token

# Store GitHub token in 1Password
op item create --category "API Credential" --title "GitHub CLI Token"

# Use token for operations
gh api user --jq '.login' | op run -- gh api user --jq '.login'
```

### Git Operations

#### Git Credential Management
```bash
# Store Git credentials in 1Password
op item create --category "Login" --title "GitHub Credentials" \
  --username "user@example.com" \
  --password $(gh auth status --show-token | grep "Token:" | cut -d' ' -f2)

# Configure Git to use 1Password
git config credential.helper '!op credential fill'
```

## <a name="environment-variables"></a>Environment Variables

### 1Password CLI Environment Variables

#### Authentication
```bash
export OP_SERVICE_ACCOUNT_TOKEN="your-service-account-token"
export OP_ACCOUNT="mycompany"  # For multi-account setups
export OP_DEVICE="device-id"   # For device trust
```

#### Configuration
```bash
export OP_CONFIG_DIR="$HOME/.config/1password"
export OP_DATA_DIR="$HOME/.local/share/1password"
export OP_PLUGIN_DIR="$HOME/.local/share/1password/plugins"
```

#### CLI Behavior
```bash
export OP_CLI_SHELL_INTEGRATION="enabled"  # Auto-load secrets
export OP_CLI_AUTOMATION="enabled"        # Disable interactive prompts
export OP_CLI_LOG_LEVEL="debug"           # Enable debug logging
```

### Application Environment Integration

#### Auto-loading Secrets
```bash
# Add to application startup script
#!/bin/bash
# Load all secrets automatically
eval $(op env --generate-env --shell bash)

# Start application
exec "$@"
```

#### Docker Integration
```dockerfile
FROM ubuntu:22.04

# Install 1Password CLI
RUN apt-get update && apt-get install -y curl
RUN curl -sS https://downloads.1password.com/linux/keys/1password.asc | apt-key add -
RUN echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main" > /etc/apt/sources.list.d/1password.list
RUN apt-get update && apt-get install -y 1password-cli

# Load secrets at runtime
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

## <a name="templates"></a>Template & Reference Syntax

### Secret Reference Syntax

#### Basic Syntax
```
op://vault-name/item-name/field-name
```

#### Advanced Syntax
```bash
# Specific vault
op://Personal/Database/username

# With formatting
op://MyVault/SSH Keys/github/private key?ssh-format=openssh

# With filters
op://MyVault/Database/connection-string?format=json&filter=prod

# Nested fields
op://MyVault/Configuration/secrets/api-keys[0]
```

### JSON Template Syntax

#### Creating Items with Templates
```json
{
  "template": {
    "category": "Login",
    "title": "Application Credentials",
    "fields": [
      {
        "id": "username",
        "type": "text",
        "label": "Username",
        "required": true
      },
      {
        "id": "password",
        "type": "concealed",
        "label": "Password",
        "required": true,
        "generate": true
      },
      {
        "id": "api_key",
        "type": "concealed",
        "label": "API Key",
        "required": false
      }
    ]
  }
}
```

#### Template Processing
```bash
# Create item from template
op item create --template template.json --title "App Credentials"

# Process with variable substitution
envsubst < template.json | op item create --stdin
```

### Reference Expansion

#### Automatic Expansion
```bash
# Basic reference
op read "op://MyVault/Database/url"
# Returns: postgresql://user:pass@localhost:5432/db

# Environment variable expansion
export DB_URL=$(op read "op://MyVault/Database/url")

# JSON field extraction
op read "op://MyVault/Config/app?format=json" | jq -r '.database_url'
```

#### Template Variables
```bash
# Use variables in templates
export APP_ENV="production"
export DB_NAME="app_prod"

op item create \
  --title "${APP_ENV} Database" \
  --template <(echo '{"title": "'"${APP_ENV}"' Database", "url": "'"${DB_NAME}"'"}')
```

## <a name="automation"></a>Automation & Connect Server

### Connect Server

#### Overview
1Password Connect Server provides HTTP API access to secrets for applications that cannot use CLI directly.

#### Installation
```bash
# Docker
docker run -d \
  --name 1password-connect \
  -p 8080:8080 \
  -v op-connect-data:/home/opuser/.op/data \
  -e OP_SERVICE_ACCOUNT_TOKEN="$OP_SERVICE_ACCOUNT_TOKEN" \
  1password/connect:latest

# Kubernetes
helm repo add 1password https://1password.github.io/helm-charts
helm install my-connect 1password/connect
```

#### API Usage
```bash
# Get secret via REST API
curl -H "Authorization: Bearer $OP_SERVICE_ACCOUNT_TOKEN" \
     "http://localhost:8080/v1/vaults/MyVault/items/Database/fields/password"

# Update secret
curl -X PATCH \
     -H "Authorization: Bearer $OP_SERVICE_ACCOUNT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"value": "new-secret"}' \
     "http://localhost:8080/v1/vaults/MyVault/items/Database/fields/password"
```

### Webhooks

#### Secret Update Notifications
```bash
# Set up webhook endpoint
curl -X POST "http://localhost:8080/v1/webhooks" \
  -H "Authorization: Bearer $OP_SERVICE_ACCOUNT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://myapp.com/webhooks/1password",
    "secret": "webhook-secret-token"
  }'
```

## <a name="security"></a>Security Best Practices

### Authentication Security

#### Token Management
- Use service accounts for automated access
- Rotate tokens regularly
- Store tokens in secure locations
- Monitor token usage

#### Biometric Authentication
```bash
# Enable biometric unlock
op biometric-unlock enable

# Test biometric authentication
op biometric-unlock test

# Disable if compromised
op biometric-unlock disable
```

### Secret Handling

#### Best Practices
1. Never log or echo secrets
2. Use secure temporary files for secret handling
3. Clean up environment variables after use
4. Implement proper secret rotation
5. Use least privilege access

#### Secure Script Pattern
```bash
#!/bin/bash
# Secure secret handling pattern

# Create secure temporary file
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Load secret securely
op read "op://MyVault/Database/password" > "$TEMP_FILE"

# Use secret
DATABASE_PASSWORD=$(cat "$TEMP_FILE")

# Clean up immediately
rm -f "$TEMP_FILE"

# Execute with secret (without exposing it)
export DATABASE_PASSWORD
execute_database_operation
unset DATABASE_PASSWORD
```

### Vault Organization

#### Recommended Structure
```
├── Personal/
│   ├── Development/
│   │   ├── Database Credentials
│   │   ├── API Keys
│   │   └── SSH Keys
│   └── Production/
│       └── Critical Systems/
├── Team/
│   ├── Shared Secrets/
│   └── CI/CD/
└── Company/
    ├── Infrastructure/
    ├── Applications/
    └── Security/
```

#### Access Control
- Group secrets by environment
- Use appropriate vault access controls
- Implement secret rotation policies
- Monitor access logs regularly

---

## Quick Reference

### Common Commands
```bash
# Authentication
op signin
op whoami
op signout

# Item Management
op item list
op item create --category "Login" --title "App"
op read "op://Vault/Item/field"
op edit "op://Vault/Item" --field "new-value"

# Environment
op env --generate-env
op env --prefix "APP_" --generate-env

# SSH
op ssh-agent
op item create --category ssh --title "Key"
```

### Environment Variables
```bash
# Required for CI/CD
export OP_SERVICE_ACCOUNT_TOKEN="token"
export OP_ACCOUNT="account-id"

# Optional configuration
export OP_DEVICE="device-id"
export OP_CONFIG_DIR="~/.config/1password"
export OP_CLI_AUTOMATION="enabled"
```

### Integration Examples
```bash
# Load secrets for application
eval $(op env --generate-env)

# Git operations with 1Password
gh auth login --with-token | op run -- gh auth login --with-token

# SSH agent setup
eval $(op ssh-agent)
```

---

**Navigation:**
- [1Password CLI Reference](01_cli_reference.md)
- [SSH Integration Guide](02_ssh_integration.md)
- [Service Accounts Guide](03_service_accounts.md)
- [SDK Documentation](04_sdk_tutorials.md)
- [Secrets Management](05_secrets_management.md)
- [GitHub Integration](06_github_integration.md)