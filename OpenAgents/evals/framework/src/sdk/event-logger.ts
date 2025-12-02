/**
 * EventLogger - Event logging utilities
 * 
 * Handles logging of server events with meaningful details.
 * Extracted from test-runner.ts for better modularity.
 */

import type { ServerEvent } from './event-stream-handler.js';

/**
 * Log event with meaningful details
 * 
 * Event properties structure varies by type:
 * - session.created/updated: { id, title, ... }
 * - message.updated: { id, sessionID, role, ... }
 * - part.updated: { id, messageID, type, tool?, input?, output?, ... }
 */
export function logEvent(event: ServerEvent): void {
  const props = event.properties || {};
  
  switch (event.type) {
    case 'session.created':
      console.log(`📋 Session created`);
      break;
      
    case 'session.updated':
      // Session updates are frequent but not very informative
      // Skip logging unless there's something specific
      break;
      
    case 'message.created':
      console.log(`💬 New message (${props.role || 'assistant'})`);
      break;
      
    case 'message.updated':
      // Message updates happen frequently during streaming
      // Only log role changes or completion
      if (props.role === 'user') {
        console.log(`👤 User message received`);
      }
      // Skip assistant message updates (too noisy)
      break;
      
    case 'part.created':
    case 'part.updated':
      logPartEvent(props);
      break;
      
    case 'permission.request':
      console.log(`🔐 Permission requested: ${props.tool || 'unknown'}`);
      break;
      
    case 'permission.response':
      console.log(`🔐 Permission ${props.response === 'once' || props.approved ? 'granted' : 'denied'}`);
      break;
      
    case 'tool.call':
      console.log(`🔧 Tool call: ${props.tool || props.name || 'unknown'}`);
      break;
      
    case 'tool.result':
      const success = props.error ? '❌' : '✅';
      console.log(`${success} Tool result: ${props.tool || 'unknown'}`);
      break;
      
    default:
      // Skip unknown events to reduce noise
      break;
  }
}

/**
 * Log part events (tools, text, etc.)
 */
function logPartEvent(props: any): void {
  if (props.type === 'tool') {
    const toolName = props.tool || 'unknown';
    const status = props.state?.status || props.status || '';
    
    // Only log when tool starts or completes
    if (status === 'running' || status === 'pending') {
      console.log(`🔧 Tool: ${toolName} (starting)`);
      
      // Show tool input preview
      const input = props.state?.input || props.input || {};
      if (input.command) {
        const cmd = input.command.substring(0, 70);
        console.log(`   └─ ${cmd}${input.command.length > 70 ? '...' : ''}`);
      } else if (input.filePath) {
        console.log(`   └─ ${input.filePath}`);
      } else if (input.pattern) {
        console.log(`   └─ pattern: ${input.pattern}`);
      }
    } else if (status === 'completed') {
      console.log(`✅ Tool: ${toolName} (completed)`);
    } else if (status === 'error') {
      console.log(`❌ Tool: ${toolName} (error)`);
    }
  } else if (props.type === 'text') {
    // Text parts - show preview of assistant response
    const text = props.text || '';
    if (text.length > 0) {
      const preview = text.substring(0, 100).replace(/\n/g, ' ');
      console.log(`📝 ${preview}${text.length > 100 ? '...' : ''}`);
    }
  }
}

/**
 * Create a logger that respects debug mode
 */
export function createLogger(debug: boolean): {
  log: (message: string) => void;
  logEvent: (event: ServerEvent) => void;
} {
  return {
    log: (message: string) => {
      if (debug || message.includes('PASSED') || message.includes('FAILED')) {
        console.log(message);
      }
    },
    logEvent: (event: ServerEvent) => {
      if (debug) {
        logEvent(event);
      }
    },
  };
}
