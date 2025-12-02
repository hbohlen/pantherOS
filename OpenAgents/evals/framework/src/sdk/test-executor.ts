/**
 * TestExecutor - Core test execution logic
 * 
 * Handles the actual execution of test cases:
 * - Session creation and management
 * - Prompt sending (single and multi-turn)
 * - Event handling and collection
 * - Timeout management (simple and smart)
 * 
 * Extracted from test-runner.ts for better modularity.
 */

import { ClientManager } from './client-manager.js';
import { EventStreamHandler } from './event-stream-handler.js';
import type { TestCase } from './test-case-schema.js';
import type { ApprovalStrategy } from './approval/approval-strategy.js';
import type { ServerEvent } from './event-stream-handler.js';

/**
 * Configuration for test execution
 */
export interface ExecutionConfig {
  /** Default timeout for tests (ms) */
  defaultTimeout: number;
  /** Project path for working directory */
  projectPath: string;
  /** Default model to use */
  defaultModel: string;
  /** Enable debug logging */
  debug: boolean;
}

/**
 * Result of test execution (before evaluation)
 */
export interface ExecutionResult {
  /** Session ID created for this test */
  sessionId: string;
  /** Events captured during test */
  events: ServerEvent[];
  /** Errors encountered during execution */
  errors: string[];
  /** Number of approvals given */
  approvalsGiven: number;
  /** Duration of execution (ms) */
  duration: number;
}

/**
 * Logger interface for dependency injection
 */
export interface ExecutionLogger {
  log(message: string): void;
  logEvent(event: ServerEvent): void;
}

/**
 * TestExecutor handles the core test execution logic
 */
export class TestExecutor {
  constructor(
    private readonly client: ClientManager,
    private readonly eventHandler: EventStreamHandler,
    private readonly config: ExecutionConfig,
    private readonly logger: ExecutionLogger
  ) {}

  /**
   * Execute a single test case
   */
  async execute(
    testCase: TestCase,
    approvalStrategy: ApprovalStrategy
  ): Promise<ExecutionResult> {
    const startTime = Date.now();
    const errors: string[] = [];
    const events: ServerEvent[] = [];
    let sessionId = '';
    let approvalsGiven = 0;

    try {
      this.logger.log(`\n${'='.repeat(60)}`);
      this.logger.log(`Running test: ${testCase.id} - ${testCase.name}`);
      this.logger.log(`${'='.repeat(60)}`);
      this.logger.log(`Approval strategy: ${approvalStrategy.describe()}`);

      // Setup event handler
      this.eventHandler.removeAllHandlers();
      
      this.eventHandler.onAny((event) => {
        events.push(event);
        if (this.config.debug) {
          this.logger.logEvent(event);
        }
      });

      this.eventHandler.onPermission(async (event) => {
        const approved = await approvalStrategy.shouldApprove(event);
        approvalsGiven++;
        this.logger.log(`Permission ${approved ? 'APPROVED' : 'DENIED'}: ${event.properties.tool || 'unknown'}`);
        return approved;
      });

      // Start event listener in background
      const evtHandler = this.eventHandler;
      this.eventHandler.startListening().catch(err => {
        if (evtHandler.listening()) {
          errors.push(`Event stream error: ${err.message}`);
        }
      });

      // Wait for event handler to connect
      await this.sleep(2000);

      // Create session
      this.logger.log('Creating session...');
      const session = await this.client.createSession({
        title: testCase.name,
      });
      sessionId = session.id;
      this.logger.log(`Session created: ${sessionId}`);

      // Send prompt(s)
      await this.sendPrompts(testCase, sessionId, errors);

      // Give time for final events to arrive
      await this.sleep(3000);

      // Stop event handler
      this.eventHandler.stopListening();

      // Validate agent if specified
      if (testCase.agent) {
        await this.validateAgent(testCase, sessionId, errors);
      }

      const duration = Date.now() - startTime;

      return {
        sessionId,
        events,
        errors,
        approvalsGiven,
        duration,
      };
    } catch (error) {
      const duration = Date.now() - startTime;
      errors.push(`Test execution failed: ${(error as Error).message}`);

      this.logger.log(`\nTest FAILED with exception`);
      this.logger.log(`Error: ${(error as Error).message}`);

      return {
        sessionId,
        events,
        errors,
        approvalsGiven,
        duration,
      };
    }
  }

  /**
   * Send prompts for a test case (single or multi-turn)
   */
  private async sendPrompts(
    testCase: TestCase,
    sessionId: string,
    errors: string[]
  ): Promise<void> {
    const timeout = testCase.timeout || this.config.defaultTimeout;
    const modelToUse = testCase.model || this.config.defaultModel;
    const agentToUse = testCase.agent || 'openagent';
    
    this.logger.log(`Agent: ${agentToUse}`);
    this.logger.log(`Model: ${modelToUse}`);
    
    // Check if multi-message test
    if (testCase.prompts && testCase.prompts.length > 0) {
      await this.sendMultiTurnPrompts(testCase, sessionId, timeout, modelToUse, agentToUse);
    } else {
      await this.sendSinglePrompt(testCase, sessionId, timeout, modelToUse, agentToUse);
    }
  }

  /**
   * Send multiple prompts for multi-turn tests
   */
  private async sendMultiTurnPrompts(
    testCase: TestCase,
    sessionId: string,
    timeout: number,
    modelToUse: string,
    agentToUse: string
  ): Promise<void> {
    this.logger.log(`Sending ${testCase.prompts!.length} prompts (multi-turn)...`);
    this.logger.log(`Using smart timeout: ${timeout}ms per prompt, max ${timeout * 2}ms absolute`);
    
    for (let i = 0; i < testCase.prompts!.length; i++) {
      const msg = testCase.prompts![i];
      this.logger.log(`\nPrompt ${i + 1}/${testCase.prompts!.length}:`);
      this.logger.log(`  Text: ${msg.text.substring(0, 100)}${msg.text.length > 100 ? '...' : ''}`);
      if (msg.expectContext) {
        this.logger.log(`  Expects context: ${msg.contextFile || 'yes'}`);
      }
      
      // Add delay if specified
      if (msg.delayMs && i > 0) {
        this.logger.log(`  Waiting ${msg.delayMs}ms before sending...`);
        await this.sleep(msg.delayMs);
      }
      
      const promptPromise = this.client.sendPrompt(sessionId, {
        text: msg.text,
        agent: agentToUse,
        model: modelToUse ? this.parseModel(modelToUse) : undefined,
        directory: this.config.projectPath,
      });
      
      await this.withSmartTimeout(
        promptPromise,
        timeout,
        timeout * 2,
        `Prompt ${i + 1} execution timed out`
      );
      this.logger.log(`  Completed`);
      
      // Small delay between messages
      if (i < testCase.prompts!.length - 1) {
        await this.sleep(1000);
      }
    }
    
    this.logger.log('\nAll prompts completed');
  }

  /**
   * Send a single prompt
   */
  private async sendSinglePrompt(
    testCase: TestCase,
    sessionId: string,
    timeout: number,
    modelToUse: string,
    agentToUse: string
  ): Promise<void> {
    this.logger.log('Sending prompt...');
    this.logger.log(`Prompt: ${testCase.prompt!.substring(0, 100)}${testCase.prompt!.length > 100 ? '...' : ''}`);
    
    const promptPromise = this.client.sendPrompt(sessionId, {
      text: testCase.prompt!,
      agent: agentToUse,
      model: modelToUse ? this.parseModel(modelToUse) : undefined,
      directory: this.config.projectPath,
    });

    await this.withTimeout(promptPromise, timeout, 'Prompt execution timed out');
    this.logger.log('Prompt completed');
  }

  /**
   * Validate that the correct agent was used
   */
  private async validateAgent(
    testCase: TestCase,
    sessionId: string,
    errors: string[]
  ): Promise<void> {
    this.logger.log(`Validating agent: ${testCase.agent}...`);
    try {
      const sessionInfo = await this.client.getSession(sessionId);
      const messages = sessionInfo.messages;
      
      if (messages && messages.length > 0) {
        const firstMessage = messages[0].info as any;
        const actualAgent = firstMessage.agent;
        
        if (actualAgent && actualAgent !== testCase.agent) {
          errors.push(`Agent mismatch: expected '${testCase.agent}', got '${actualAgent}'`);
          this.logger.log(`  ❌ Agent mismatch: expected '${testCase.agent}', got '${actualAgent}'`);
        } else if (actualAgent) {
          this.logger.log(`  ✅ Agent verified: ${actualAgent}`);
        } else {
          this.logger.log(`  ⚠️  Agent not set in message`);
        }
      }
    } catch (error) {
      this.logger.log(`  Warning: Could not validate agent: ${(error as Error).message}`);
    }
  }

  /**
   * Parse model string (provider/model format)
   */
  private parseModel(model: string): { providerID: string; modelID: string } {
    const [providerID, modelID] = model.split('/');
    if (!providerID || !modelID) {
      throw new Error(`Invalid model format: ${model}. Expected provider/model`);
    }
    return { providerID, modelID };
  }

  /**
   * Sleep for ms
   */
  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Run promise with timeout
   */
  private async withTimeout<T>(promise: Promise<T>, timeoutMs: number, message: string): Promise<T> {
    return Promise.race([
      promise,
      new Promise<T>((_, reject) =>
        setTimeout(() => reject(new Error(message)), timeoutMs)
      ),
    ]);
  }

  /**
   * Run promise with smart timeout that monitors activity
   * - Checks if events are still coming in
   * - Extends timeout if activity detected
   * - Has absolute maximum timeout
   */
  private async withSmartTimeout<T>(
    promise: Promise<T>,
    baseTimeoutMs: number,
    maxTimeoutMs: number,
    message: string
  ): Promise<T> {
    const startTime = Date.now();
    let lastActivityTime = startTime;
    let isActive = true;

    // Monitor event activity
    const activityMonitor = setInterval(() => {
      const now = Date.now();
      const timeSinceLastActivity = now - lastActivityTime;
      const totalTime = now - startTime;

      // Check if we've exceeded absolute max timeout
      if (totalTime > maxTimeoutMs) {
        isActive = false;
        clearInterval(activityMonitor);
        return;
      }

      // If no activity for baseTimeout, consider it stalled
      if (timeSinceLastActivity > baseTimeoutMs) {
        isActive = false;
        clearInterval(activityMonitor);
      }
    }, 1000);

    // Update last activity time when events arrive
    this.eventHandler.onAny(() => {
      lastActivityTime = Date.now();
    });

    try {
      const result = await Promise.race([
        promise,
        new Promise<T>((_, reject) => {
          const checkTimeout = setInterval(() => {
            const now = Date.now();
            const totalTime = now - startTime;
            const timeSinceActivity = now - lastActivityTime;

            if (totalTime > maxTimeoutMs) {
              clearInterval(checkTimeout);
              clearInterval(activityMonitor);
              reject(new Error(`${message} (absolute max timeout: ${maxTimeoutMs}ms)`));
            } else if (timeSinceActivity > baseTimeoutMs && !isActive) {
              clearInterval(checkTimeout);
              clearInterval(activityMonitor);
              reject(new Error(`${message} (no activity for ${baseTimeoutMs}ms)`));
            }
          }, 1000);
        })
      ]);

      clearInterval(activityMonitor);
      return result;
    } catch (error) {
      clearInterval(activityMonitor);
      throw error;
    }
  }
}
