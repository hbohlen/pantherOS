# Validate Proposed Disko.nix Against Best Practices and Hardware Reality - Proposal

## Problem Statement

Users developing disko.nix configurations often lack a systematic way to validate these configurations against best practices and hardware reality before deployment. Common issues include device path mismatches, inappropriate partition schemes for the host type, problematic subvolume layouts, and risky mount option combinations. Without proper validation, users risk deployment failures, system instability, or performance issues. Current validation is ad-hoc and relies on manual checks and trial-and-error deployment.

## Objective

Develop a systematic validation framework that checks proposed disko.nix configurations against hardware reality (from facter.json), best practices, and potential risks. The framework should identify hardware compatibility issues, layout sanity problems, mount option conflicts, and snapshot/backup implications. It should provide clear issue reporting, recommended fixes, and a "go/no-go" summary to support deployment decisions.

## Solution Overview

The solution will provide an automated validation framework that ingests a proposed disko.nix configuration, the corresponding facter.json, and a host role description. It will systematically check for hardware compatibility, layout best practices, mount option safety, and backup implications, then generate a comprehensive report with issues, recommendations, and a deployment readiness assessment.

## Stakeholders

- System administrators deploying new disk configurations
- DevOps engineers creating standardized disko configurations
- Users wanting to validate their configurations before deployment