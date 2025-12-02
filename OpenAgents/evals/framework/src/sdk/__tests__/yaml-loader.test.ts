/**
 * Tests for loading actual YAML test files
 */

import { describe, it, expect } from 'vitest';
import { loadTestCase } from '../test-case-loader.js';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Path to test files
const testFilesDir = join(__dirname, '../../../../agents/openagent/tests');

describe('YAML Test File Loading', () => {
  describe('developer tests', () => {
    it('should load simple-bash-test.yaml', async () => {
      const testCase = await loadTestCase(join(testFilesDir, 'developer/simple-bash-test.yaml'));
      
      expect(testCase.id).toBe('simple-bash-test');
      expect(testCase.name).toBe('Simple Bash Command Test');
      expect(testCase.category).toBe('developer');
      expect(testCase.agent).toBe('openagent');
      expect(testCase.behavior).toBeDefined();
      expect(testCase.behavior?.mustUseTools).toContain('bash');
      expect(testCase.behavior?.minToolCalls).toBe(1);
    });

    it('should load ctx-code-001.yaml', async () => {
      const testCase = await loadTestCase(join(testFilesDir, 'developer/ctx-code-001.yaml'));
      
      expect(testCase.id).toBe('ctx-code-001');
      expect(testCase.behavior).toBeDefined();
      expect(testCase.behavior?.mustUseTools).toContain('read');
      expect(testCase.behavior?.mustUseTools).toContain('write');
      expect(testCase.behavior?.requiresApproval).toBe(true);
      expect(testCase.behavior?.requiresContext).toBe(true);
      expect(testCase.expectedViolations).toBeDefined();
      expect(testCase.expectedViolations?.length).toBeGreaterThan(0);
    });

    it('should load ctx-delegation-001.yaml', async () => {
      const testCase = await loadTestCase(join(testFilesDir, 'developer/ctx-delegation-001.yaml'));
      
      expect(testCase.id).toBe('ctx-delegation-001');
      expect(testCase.behavior).toBeDefined();
      expect(testCase.behavior?.mustUseTools).toContain('read');
      expect(testCase.behavior?.mustUseTools).toContain('task');
      expect(testCase.behavior?.requiresContext).toBe(true);
    });
  });

  describe('edge-case tests', () => {
    it('should load no-approval-negative.yaml', async () => {
      const testCase = await loadTestCase(join(testFilesDir, 'edge-case/no-approval-negative.yaml'));
      
      expect(testCase.id).toBe('neg-no-approval-001');
      expect(testCase.category).toBe('edge-case');
      expect(testCase.behavior).toBeDefined();
      expect(testCase.expectedViolations).toBeDefined();
    });

    it('should load missing-approval-negative.yaml', async () => {
      const testCase = await loadTestCase(join(testFilesDir, 'edge-case/missing-approval-negative.yaml'));
      
      expect(testCase.id).toBe('neg-missing-approval-001');
      expect(testCase.category).toBe('edge-case');
      expect(testCase.behavior).toBeDefined();
      expect(testCase.behavior?.requiresApproval).toBe(true);
      expect(testCase.expectedViolations).toBeDefined();
      
      // This is a negative test - expects violation
      const approvalViolation = testCase.expectedViolations?.find(v => v.rule === 'approval-gate');
      expect(approvalViolation).toBeDefined();
      expect(approvalViolation?.shouldViolate).toBe(true);
    });
  });

  describe('validation', () => {
    it('should validate all test files have required fields', async () => {
      const testFiles = [
        'developer/simple-bash-test.yaml',
        'developer/ctx-code-001.yaml',
        'developer/ctx-delegation-001.yaml',
        'edge-case/no-approval-negative.yaml',
        'edge-case/missing-approval-negative.yaml',
      ];

      for (const file of testFiles) {
        const testCase = await loadTestCase(join(testFilesDir, file));
        
        // Required fields
        expect(testCase.id).toBeDefined();
        expect(testCase.name).toBeDefined();
        expect(testCase.description).toBeDefined();
        expect(testCase.category).toBeDefined();
        expect(testCase.approvalStrategy).toBeDefined();
        
        // Must have prompt or prompts
        expect(testCase.prompt || testCase.prompts).toBeDefined();
        
        // Must have behavior, expected, or expectedViolations
        expect(testCase.behavior || testCase.expected || testCase.expectedViolations).toBeDefined();
      }
    });
  });
});
