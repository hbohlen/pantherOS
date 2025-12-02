# Spec: Attic Cache

## Overview

This spec defines the requirements for a self-hosted Attic binary cache server backed by Backblaze B2 S3 storage.

---

## ADDED Requirements

### Requirement: Attic Server Deployment

The system SHALL provide a running Attic server on the Hetzner VPS.

#### Scenario: Server installation

**Given** the Hetzner VPS NixOS configuration  
**When** `services.atticd.enable = true` is set  
**Then** the Attic server is installed and running  
**And** listens on the configured port (8080)

#### Scenario: Server accessibility

**Given** the Attic server is running  
**When** a client connects to the cache URL  
**Then** the server responds with cache information  
**And** HTTPS is enforced via NGINX reverse proxy

---

### Requirement: S3 Storage Backend

The Attic server SHALL use Backblaze B2 as the storage backend for NAR files.

#### Scenario: S3 configuration

**Given** Backblaze B2 credentials are configured via OpNix  
**When** the Attic server starts  
**Then** it successfully connects to the S3 bucket  
**And** can read and write NAR files

#### Scenario: NAR storage

**Given** a store path is pushed to Attic  
**When** the upload completes  
**Then** the NAR is stored in the S3 bucket  
**And** metadata is stored in PostgreSQL

#### Scenario: NAR retrieval

**Given** a NAR exists in the S3 bucket  
**When** a client requests the store path  
**Then** the NAR is retrieved from S3  
**And** served to the client with appropriate compression

---

### Requirement: Database Management

The Attic server SHALL use PostgreSQL for metadata storage.

#### Scenario: Database initialization

**Given** PostgreSQL is configured on the VPS  
**When** the Attic server first starts  
**Then** it creates necessary database tables  
**And** migrations are applied automatically

#### Scenario: Metadata storage

**Given** a store path is pushed to Attic  
**When** the upload completes  
**Then** metadata is stored in PostgreSQL  
**And** includes NAR hash, size, and references

---

### Requirement: Cache Management

The system SHALL support multiple caches with different access policies.

#### Scenario: Create public cache

**Given** the Attic server is running  
**When** `attic cache create public-cache` is executed  
**Then** a new cache is created  
**And** can be configured as public for anonymous read access

#### Scenario: Create private CI cache

**Given** the Attic server is running  
**When** `attic cache create ci-cache` is executed  
**Then** a new cache is created  
**And** requires authentication for read and write access

#### Scenario: Cache isolation

**Given** multiple caches exist  
**When** a store path is pushed to `ci-cache`  
**Then** it is only visible in `ci-cache`  
**And** does not appear in other caches unless explicitly shared

---

### Requirement: Authentication and Authorization

The Attic server SHALL use JWT tokens for stateless authentication.

#### Scenario: Generate CI token

**Given** the Attic server is configured  
**When** `atticadm make-token --sub gitlab-ci --pull ci-cache --push ci-cache` is executed  
**Then** a JWT token is generated  
**And** the token grants push and pull access to `ci-cache` only

#### Scenario: Token validation

**Given** a client has a valid JWT token  
**When** the client authenticates to the server  
**Then** the token is validated  
**And** permissions are enforced based on token claims

#### Scenario: Unauthorized access denied

**Given** a client has no token or an invalid token  
**When** the client attempts to push to a private cache  
**Then** the request is denied with 401 Unauthorized

---

### Requirement: Content-Defined Chunking

The Attic server SHALL use content-defined chunking for deduplication.

#### Scenario: Chunking configuration

**Given** the Attic server configuration  
**When** chunking parameters are set (min: 16KB, avg: 64KB, max: 256KB)  
**Then** NARs larger than 64KB are chunked  
**And** smaller NARs are stored whole

#### Scenario: Deduplication

**Given** two store paths share common chunks  
**When** both are pushed to Attic  
**Then** shared chunks are stored only once  
**And** storage space is saved through deduplication

---

### Requirement: Garbage Collection

The system SHALL automatically garbage collect unused store paths.

#### Scenario: Retention policy configuration

**Given** a cache exists  
**When** `attic cache configure ci-cache --retention-period 30d` is executed  
**Then** the retention period is set to 30 days  
**And** NARs not accessed for 30 days become eligible for deletion

#### Scenario: Automated garbage collection

**Given** a systemd timer is configured for daily GC  
**When** the timer triggers  
**Then** the garbage collector runs  
**And** deletes NARs exceeding the retention period

#### Scenario: Three-level GC

**Given** garbage collection runs  
**When** a NAR is deleted from a cache  
**Then** the cache-to-NAR mapping is removed (Level 1)  
**And** orphan NARs not referenced by any cache are deleted (Level 2)  
**And** orphan chunks not referenced by any NAR are deleted (Level 3)

---

### Requirement: HTTPS and Security

The Attic server SHALL be accessible only via HTTPS with valid TLS certificates.

#### Scenario: NGINX reverse proxy

**Given** NGINX is configured as a reverse proxy  
**When** a client connects to the cache URL  
**Then** the connection is encrypted with TLS  
**And** Let's Encrypt certificates are automatically renewed

#### Scenario: HTTP redirect

**Given** a client attempts HTTP connection  
**When** the request reaches NGINX  
**Then** it is redirected to HTTPS  
**And** no unencrypted traffic is allowed

---

### Requirement: Monitoring and Logging

The system SHALL provide logs and metrics for operational visibility.

#### Scenario: Server logs

**Given** the Attic server is running  
**When** operations occur (push, pull, GC)  
**Then** logs are written to journald  
**And** can be queried with `journalctl -u atticd`

#### Scenario: Cache statistics

**Given** a cache has been in use  
**When** `attic cache info ci-cache` is executed  
**Then** statistics are displayed (size, NAR count, hit rate)  
**And** storage usage is reported

---

### Requirement: Backup and Recovery

The system SHALL support backup and recovery of Attic data.

#### Scenario: PostgreSQL backup

**Given** `services.postgresqlBackup` is enabled  
**When** the daily backup runs  
**Then** the PostgreSQL database is backed up  
**And** backups are retained for 30 days

#### Scenario: S3 data durability

**Given** Backblaze B2 versioning is enabled  
**When** a NAR is deleted  
**Then** the previous version is retained for 30 days  
**And** can be restored if needed

#### Scenario: Configuration recovery

**Given** the NixOS configuration is in Git  
**When** the Attic server needs to be rebuilt  
**Then** the configuration can be redeployed from Git  
**And** the server is restored to working state
