# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated testing and validation of the pantherOS repository.

## MCP Configuration Verification

**File:** `mcp-verification.yml`

### Purpose

Automatically verifies the MCP (Model Context Protocol) server configuration on every push and pull request. The workflow is specifically designed to handle firewall and network restrictions common in CI/CD environments.

### Features

#### Firewall & Network Resilience

- **npm Retry Logic**: Configured with 5 retries and 60-second timeouts
- **Exponential Backoff**: Gradual retry delays for transient network issues
- **Graceful Degradation**: Network checks use `continue-on-error: true`
- **Connection Testing**: Pre-flight npm registry connectivity check

#### Validation Stages

1. **npm Registry Access Test**
   - Tests connectivity to npm registry
   - 3 retry attempts with 5-second delays
   - Continues workflow even if registry is blocked

2. **JSON Syntax Validation**
   - Validates `mcp-servers.json` syntax using `jq`
   - Fast, no network access required
   - Fails build if JSON is malformed

3. **MCP Structure Validation**
   - Verifies required `mcpServers` key exists
   - Checks for schema reference
   - Counts and lists all configured servers
   - No network access required

4. **Package Availability Check**
   - Tests npm packages with retry logic
   - Checks key packages: github, filesystem, git MCP servers
   - 3 attempts per package with 5-second delays
   - Does not fail build if packages unreachable

5. **Full Verification Script**
   - Runs `.github/verify-mcp-config.sh`
   - Comprehensive 7-stage validation
   - Uses existing retry logic in script

### Triggers

The workflow runs on:

```yaml
# Push events
- main branch
- copilot/** branches
- When MCP-related files change

# Pull request events  
- PRs targeting main branch
- When MCP-related files change

# Manual trigger
- workflow_dispatch
```

### Configuration

#### npm Firewall Settings

```yaml
npm config set fetch-timeout 60000          # 60 second timeout
npm config set fetch-retries 5              # 5 retry attempts
npm config set fetch-retry-mintimeout 10000 # 10 second min delay
npm config set fetch-retry-maxtimeout 60000 # 60 second max delay
npm config set strict-ssl true              # Enforce SSL
```

#### Environment Variables

Optional environment variables (commented out by default):

- `GITHUB_TOKEN`: For authenticated GitHub API access
- `CI`: Set to `true` automatically in GitHub Actions

### Usage

#### Automatic Runs

The workflow runs automatically when you:
- Push to main or copilot/** branches
- Create a PR to main
- Modify MCP configuration files

#### Manual Run

1. Go to **Actions** tab in GitHub
2. Select **MCP Configuration Verification**
3. Click **Run workflow**
4. Select branch and click **Run workflow**

#### Local Testing

To test the validation locally before pushing:

```bash
# Run the validation script
./.github/verify-mcp-config.sh

# Simulate npm configuration
npm config set fetch-timeout 60000
npm config set fetch-retries 5

# Test JSON validation
jq empty .github/mcp-servers.json
```

### Expected Results

#### Success Scenario

```
✅ npm registry is accessible
✅ JSON syntax is valid
✅ mcpServers key found
✅ Schema reference found: https://modelcontextprotocol.io/schemas/mcp-servers.json
✅ Found 11 MCP servers configured
✅ @modelcontextprotocol/server-github is available
✅ Configuration files validated
```

#### Firewall Restricted Environment

```
⚠️  npm registry access issues detected, but continuing...
✅ JSON syntax is valid
✅ mcpServers key found
✅ Schema reference found: https://modelcontextprotocol.io/schemas/mcp-servers.json
✅ Found 11 MCP servers configured
⚠️  Could not verify packages (may be behind firewall)
✅ Configuration files validated

Note: Network-dependent checks may show warnings
in restricted environments. This is expected.
```

### Troubleshooting

#### Workflow Fails on JSON Validation

**Problem:** JSON syntax error in `mcp-servers.json`

**Solution:**
```bash
# Validate locally
jq empty .github/mcp-servers.json

# Fix JSON syntax errors
# Re-run workflow
```

#### Workflow Timeout

**Problem:** Network operations timing out

**Solution:**
- Check if npm registry is accessible from GitHub Actions
- Increase timeout values in workflow (currently 60 seconds)
- Verify no corporate firewall blocking npm registry

#### Package Not Found

**Problem:** MCP package not available in npm registry

**Solution:**
- Verify package name is correct
- Check if package has been deprecated
- Update package reference in workflow

### Maintenance

#### Adding New Validation

To add a new validation step:

1. Edit `.github/workflows/mcp-verification.yml`
2. Add new step after existing validation steps
3. Use `continue-on-error: true` for network-dependent checks
4. Test locally first
5. Push and verify in Actions tab

#### Updating npm Timeouts

To adjust retry/timeout values:

```yaml
- name: Configure npm for firewall compatibility
  run: |
    npm config set fetch-timeout 120000      # Increase to 120s
    npm config set fetch-retries 10          # Increase to 10 retries
    npm config set fetch-retry-mintimeout 15000  # Increase min delay
```

### Related Documentation

- **MCP Setup Guide**: `.github/MCP-SETUP.md`
- **Verification Report**: `.github/MCP-VERIFICATION-REPORT.md`
- **Validation Script**: `.github/verify-mcp-config.sh`
- **Configuration**: `.github/mcp-servers.json`

### Support

For issues with the GitHub Actions workflow:

1. Check the **Actions** tab for error details
2. Review workflow logs for specific failures
3. Test validation script locally: `./.github/verify-mcp-config.sh`
4. Open an issue with workflow run URL and error message
