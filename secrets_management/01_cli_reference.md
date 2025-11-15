# 1Password CLI Reference

**Last Updated:** 2025-11-15 10:16:10  
**Author:** MiniMax Agent  
**Purpose:** Quick reference for 1Password CLI commands and usage

## Installation Quick Reference

### Linux Installation (One-Line)
```bash
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install 1password-cli
```

### Verify Installation
```bash
op --version
op whoami
```

## Core Commands

### Authentication
| Command | Description | Example |
|---------|-------------|---------|
| `op signin` | Sign in to 1Password | `op signin` |
| `op signout` | Sign out | `op signout` |
| `op whoami` | Check authentication status | `op whoami` |
| `op signin --account` | Sign in to specific account | `op signin --account mycompany` |
| `op signin --service-account` | Sign in with service account | `op signin --service-account` |

### Item Management
| Command | Description | Example |
|---------|-------------|---------|
| `op item list` | List all items | `op item list` |
| `op item list --vault` | List items in specific vault | `op item list --vault "Personal"` |
| `op item create` | Create new item | `op item create --category "Login" --title "App"` |
| `op read` | Read item field | `op read "op://Personal/MyApp/password"` |
| `op edit` | Edit item | `op edit "op://Personal/MyApp" --password "newpass"` |
| `op item delete` | Delete item | `op item delete "op://Personal/MyApp"` |

### Vault Management
| Command | Description | Example |
|---------|-------------|---------|
| `op vault list` | List all vaults | `op vault list` |
| `op vault create` | Create new vault | `op vault create "Development Secrets"` |
| `op vault edit` | Edit vault | `op vault edit "Dev Secrets" --description "Dev env"` |

## Secret References

### Basic Syntax
```
op://vault-name/item-title/field-name
```

### Common Patterns
```bash
# Basic field access
op read "op://Personal/Database/password"

# With formatting
op read "op://MyVault/Config/app?format=json"

# SSH keys
op read "op://Private/SSH Keys/github/private key?ssh-format=openssh"

# Nested fields
op read "op://MyVault/API/keys[0]"

# Template processing
op read "op://MyVault/Database/url?format=url"
```

## Environment Integration

### Load All Secrets
```bash
# Auto-load into environment
eval $(op env --generate-env)

# With shell specification
eval $(op env --generate-env --shell bash)
eval $(op env --generate-env --shell zsh)
eval $(op env --generate-env --shell fish)
```

### Selective Loading
```bash
# Load with prefix
eval $(op env --prefix "APP_" --generate-env)

# Load from specific vault
eval $(op env --vault "Development" --generate-env)

# Generate .env file
op env --generate-env --file .env

# Update existing .env
op env --file .env --update
```

## SSH Integration

### Key Management
```bash
# Generate SSH key
op item create --category ssh --title "GitHub Key"

# Generate RSA key
op item create --category ssh --title "RSA Key" --ssh-generate-key RSA,4096

# Read SSH key
op read "op://Private/SSH Keys/github/private key?ssh-format=openssh"

# Setup SSH agent
eval $(op ssh-agent)

# Load SSH keys
op ssh-agent load
```

### Git Integration
```bash
# Configure Git signing
git config --global gpg.format ssh
git config --global user.signingkey "op://Private/SSH Keys/git-signing/private key"
git config --global commit.gpgsign true

# Use for Git operations
git commit -S -m "Signed commit"
```

## Service Accounts

### Authentication
```bash
# Sign in with service account
op signin --account mycompany --service-account

# Using environment variable
export OP_SERVICE_ACCOUNT_TOKEN="your-token"
op read "op://Production/Database/password"
```

### Management
```bash
# Create service account
op service-account create --name "CI/CD Pipeline"

# List service accounts
op service-account list --account mycompany

# Update permissions
op service-account update \
  --account mycompany \
  --service-account "Pipeline" \
  --vault-permissions "Staging:read,Prod:read"
```

## Item Creation Templates

### Login Item
```bash
op item create \
  --category "Login" \
  --title "My Application" \
  --username "user@example.com" \
  --password "secure-password" \
  --url "https://myapp.com"
```

### Database Credentials
```bash
op item create \
  --category "Database" \
  --title "Production Database" \
  --username "app_user" \
  --password "$(openssl rand -base64 32)" \
  --url "postgresql://localhost:5432/mydb"
```

### API Credential
```bash
op item create \
  --category "API Credential" \
  --title "Stripe API" \
  --api-key "sk_live_..." \
  --notes-text "Primary API key for payments"
```

## CLI Options and Flags

### Global Options
| Flag | Description | Example |
|------|-------------|---------|
| `--account` | Specify account | `op --account mycompany signin` |
| `--format` | Output format | `op read --format json "item"` |
| `--fields` | Specific fields | `op list --fields title,vault` |
| `--include-archive` | Include archived items | `op list --include-archive` |
| `--vault` | Filter by vault | `op list --vault "Personal"` |

### Output Formats
```bash
# JSON output
op list --format json

# JSON with specific fields
op read --format json --fields "username,password" "op://Personal/App"

# Plain text (default)
op read "op://Personal/App/password"

# Custom format
op read --format "custom" "op://Personal/App/password"
```

## Shell Integration

### Bash/Zsh Completion
```bash
# Enable completion
eval "$(op completion bash)"

# Add to shell config
echo 'eval "$(op completion bash)"' >> ~/.bashrc
```

### Fish Shell
```bash
# Fish completion
eval (op completion fish)

# Add to fish config
echo 'eval (op completion fish)' >> ~/.config/fish/config.fish
```

## Troubleshooting

### Common Issues

#### Authentication Problems
```bash
# Check authentication status
op whoami

# Sign in again
op signin

# Clear cached credentials
op signout
rm -rf ~/.config/op
op signin
```

#### Permission Errors
```bash
# Check service account permissions
op service-account list --account mycompany

# Verify vault access
op vault list

# Test read access
op read "op://Personal/Test/item"
```

#### Performance Issues
```bash
# Enable debug logging
export OP_CLI_LOG_LEVEL=debug

# Clear local cache
op cache clear

# Check network connectivity
op whoami --debug
```

### Debug Mode
```bash
# Enable debug logging
export OP_CLI_LOG_LEVEL=debug
op read "op://Personal/App/password"

# Verbose output
op read --debug "op://Personal/App/password"

# Check configuration
op config list
```

## Environment Variables

### Authentication
```bash
export OP_SERVICE_ACCOUNT_TOKEN="your-token"
export OP_ACCOUNT="account-id"
export OP_DEVICE="device-id"
```

### Configuration
```bash
export OP_CONFIG_DIR="$HOME/.config/1password"
export OP_DATA_DIR="$HOME/.local/share/1password"
export OP_PLUGIN_DIR="$HOME/.local/share/1password/plugins"
```

### CLI Behavior
```bash
export OP_CLI_SHELL_INTEGRATION="enabled"
export OP_CLI_AUTOMATION="enabled"
export OP_CLI_LOG_LEVEL="info"
```

## Examples

### Complete Setup Script
```bash
#!/bin/bash
# 1Password CLI Setup Script

set -e

echo "Setting up 1Password CLI environment..."

# Authenticate
op signin

# Load secrets into environment
eval $(op env --generate-env)

# Setup SSH agent
eval $(op ssh-agent)

# Load SSH keys
op ssh-agent load

echo "1Password CLI setup complete!"

# Test setup
echo "Testing CLI..."
op whoami
echo "Setup verified!"
```

### Application Deployment
```bash
#!/bin/bash
# Application deployment with 1Password

# Load secrets
eval $(op env --generate-env)

# Configure database
DATABASE_URL=$(op read "op://Production/Database/url")

# Deploy application
echo "Deploying application..."
deploy \
  --database-url "$DATABASE_URL" \
  --api-key "$API_KEY" \
  --environment production

echo "Deployment complete!"
```

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Load 1Password Secrets
  env:
    OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
  run: |
    eval $(op env --generate-env)
    echo "DATABASE_URL=$DATABASE_URL" >> $GITHUB_ENV
    echo "API_KEY=$API_KEY" >> $GITHUB_ENV

- name: Run Tests
  env:
    DATABASE_URL: ${{ env.DATABASE_URL }}
    API_KEY: ${{ env.API_KEY }}
  run: |
    npm test
    npm run deploy
```

---

**Related Documents:**
- [Master 1Password Guide](./MASTER_1PASSWORD_GUIDE.md)
- [SSH Integration Guide](./02_ssh_integration.md)
- [Service Accounts Guide](./03_service_accounts.md)