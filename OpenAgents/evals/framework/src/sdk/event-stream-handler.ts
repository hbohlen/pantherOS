import { createOpencodeClient } from '@opencode-ai/sdk';

export type EventType = 
  | 'session.created'
  | 'session.updated'
  | 'session.deleted'
  | 'message.created'
  | 'message.updated'
  | 'message.deleted'
  | 'part.created'
  | 'part.updated'
  | 'part.deleted'
  | 'permission.request'
  | 'permission.response'
  | 'tool.call'
  | 'tool.result'
  | 'file.edited'
  | 'command.executed';

export interface ServerEvent {
  type: EventType;
  properties: any;
  timestamp?: number;
}

export interface PermissionRequestEvent {
  type: 'permission.request';
  properties: {
    sessionId: string;
    permissionId: string;
    message?: string;
    tool?: string;
    args?: any;
  };
}

export type EventHandler = (event: ServerEvent) => void | Promise<void>;
export type PermissionHandler = (event: PermissionRequestEvent) => Promise<boolean>;

export class EventStreamHandler {
  private client: ReturnType<typeof createOpencodeClient>;
  private eventHandlers: Map<EventType, EventHandler[]> = new Map();
  private permissionHandler: PermissionHandler | null = null;
  private isListening: boolean = false;
  private abortController: AbortController | null = null;

  constructor(baseUrl: string) {
    this.client = createOpencodeClient({ baseUrl });
  }

  /**
   * Register an event handler for a specific event type
   */
  on(eventType: EventType, handler: EventHandler): void {
    if (!this.eventHandlers.has(eventType)) {
      this.eventHandlers.set(eventType, []);
    }
    this.eventHandlers.get(eventType)!.push(handler);
  }

  /**
   * Register a handler for all events
   */
  onAny(handler: EventHandler): void {
    this.on('session.created', handler);
    this.on('session.updated', handler);
    this.on('message.created', handler);
    this.on('message.updated', handler);
    this.on('part.created', handler);
    this.on('part.updated', handler);
    this.on('permission.request', handler);
    this.on('tool.call', handler);
    this.on('tool.result', handler);
  }

  /**
   * Register a permission handler
   * The handler should return true to approve, false to deny
   */
  onPermission(handler: PermissionHandler): void {
    this.permissionHandler = handler;
  }

  /**
   * Start listening to the event stream
   */
  async startListening(): Promise<void> {
    if (this.isListening) {
      throw new Error('Already listening to event stream');
    }

    this.abortController = new AbortController();
    this.isListening = true;

    try {
      const response = await this.client.event.subscribe();

      // Process events from the stream
      for await (const event of response.stream) {
        if (!this.isListening) {
          break;
        }

        const serverEvent: ServerEvent = {
          type: event.type as EventType,
          properties: event.properties,
          timestamp: Date.now(),
        };

        // Handle permission requests automatically if handler is registered
        if ((event.type as string) === 'permission.request' && this.permissionHandler) {
          try {
            const approved = await this.permissionHandler(serverEvent as PermissionRequestEvent);
            
            // Respond to the permission request
            const { sessionId, permissionId } = event.properties as any;
            await this.client.postSessionIdPermissionsPermissionId({
              path: { id: sessionId, permissionID: permissionId },
              body: { response: approved ? 'once' : 'reject' },
            });
          } catch (error) {
            console.error('Error handling permission request:', error);
          }
        }

        // Trigger registered event handlers
        const handlers = this.eventHandlers.get(serverEvent.type) || [];
        for (const handler of handlers) {
          try {
            await handler(serverEvent);
          } catch (error) {
            console.error(`Error in event handler for ${serverEvent.type}:`, error);
          }
        }
      }
    } catch (error) {
      if (this.isListening) {
        console.error('Event stream error:', error);
        throw error;
      }
    } finally {
      this.isListening = false;
    }
  }

  /**
   * Stop listening to the event stream
   */
  stopListening(): void {
    this.isListening = false;
    if (this.abortController) {
      this.abortController.abort();
      this.abortController = null;
    }
  }

  /**
   * Check if currently listening
   */
  listening(): boolean {
    return this.isListening;
  }

  /**
   * Remove all event handlers
   */
  removeAllHandlers(): void {
    this.eventHandlers.clear();
    this.permissionHandler = null;
  }

  /**
   * Remove handlers for a specific event type
   */
  removeHandlers(eventType: EventType): void {
    this.eventHandlers.delete(eventType);
  }
}
