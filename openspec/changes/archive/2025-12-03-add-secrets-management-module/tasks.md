# Implementation Tasks: Secrets Management Module

## 1. Core Infrastructure
- [x] 1.1 Review OpNix documentation and capabilities (https://github.com/brizzbuzz/opnix) - verify link and save local docs
- [x] 1.2 Create `modules/security/secrets.nix` module using OpNix
- [ ] 1.3 Create `secrets/` directory structure for OpNix-encrypted files
- [ ] 1.4 Configure OpNix module integration in host configurations
- [ ] 1.5 Set up OpNix configuration for secret management

## 2. OpNix Configuration
- [ ] 2.1 Configure OpNix for each existing host
- [ ] 2.2 Set up OpNix key management and storage
- [ ] 2.3 Configure OpNix access for automated deployments
- [ ] 2.4 Set up secret rotation procedures with OpNix
- [ ] 2.5 Document OpNix configuration and recovery process

## 3. Secret Definition
- [ ] 3.1 Define secret schema (per-host, per-user, shared)
- [ ] 3.2 Create example secrets for common use cases
- [ ] 3.3 Encrypt existing plain-text secrets (API keys, passwords, certificates)
- [ ] 3.4 Configure secret file permissions and ownership
- [ ] 3.5 Set up secret template system for runtime substitution

## 4. NixOS Integration
- [ ] 4.1 Integrate secrets module into system configuration
- [ ] 4.2 Configure secret activation during nixos-rebuild
- [ ] 4.3 Set up secret access from services and programs
- [ ] 4.4 Configure secret cleanup on rollback
- [ ] 4.5 Test secret deployment on all hosts

## 5. 1Password Integration via OpNix
- [ ] 5.1 Configure OpNix integration with 1Password CLI
- [ ] 5.2 Set up secret sync from 1Password vaults using OpNix
- [ ] 5.3 Configure automatic secret refresh through OpNix
- [ ] 5.4 Document 1Password to OpNix secrets workflow
- [ ] 5.5 Create helper scripts for 1Password + OpNix integration

## 6. Helper Tools
- [ ] 6.1 Create script for encrypting new secrets
- [ ] 6.2 Create script for editing existing secrets
- [ ] 6.3 Create script for viewing decrypted secrets (with authentication)
- [ ] 6.4 Create script for rotating secrets
- [ ] 6.5 Add shell completions for secret management commands

## 7. Documentation
- [ ] 7.1 Document secrets module options and configuration
- [ ] 7.2 Create quick start guide for adding new secrets
- [ ] 7.3 Document key management procedures
- [ ] 7.4 Create troubleshooting guide for common issues
- [ ] 7.5 Add security best practices documentation

## 8. Testing & Validation
- [ ] 8.1 Test secret encryption and decryption
- [ ] 8.2 Verify secret deployment on all hosts
- [ ] 8.3 Test secret access from services
- [ ] 8.4 Verify secret permissions and ownership
- [ ] 8.5 Test secret rollback and recovery scenarios
