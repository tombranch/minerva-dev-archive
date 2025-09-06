# Phase 3: Real-time Infrastructure & Monitoring Plan
## AI Features Management Interface Redesign - Days 7-9

**Phase Duration:** 3 Days  
**Focus:** Implement real-time features and comprehensive monitoring  
**Risk Level:** High (significant new infrastructure)  
**Team:** 1 Senior Frontend Developer + 1 Backend Developer + 1 DevOps Engineer

---

## Phase Overview

Phase 3 introduces the most complex technical requirements: real-time infrastructure for live metrics updates, log streaming, and contextual monitoring. This phase transforms the static interface into a dynamic, real-time management platform.

**Key Dependencies from Phase 2:**
- ✅ Unified interface with embedded testing
- ✅ Settings consolidation and prompt management
- ✅ Test result display patterns

**New Infrastructure Required:**
- 🔧 WebSocket/SSE infrastructure for real-time communications
- 🔧 Log aggregation and streaming service
- 🔧 Real-time metrics collection and broadcasting
- 🔧 Drawer-based log interface
- 🔧 Contextual monitoring and alerting

---

## Day 7: Real-time Infrastructure Foundation

### Task 7.1: WebSocket Infrastructure Setup
**Duration:** 4 hours  
**Priority:** High  
**Complexity:** High

**Objective:** Create WebSocket server infrastructure for real-time communications

**Implementation Steps:**
1. **Create WebSocket server with Next.js API routes:**
   ```typescript
   // lib/websocket/websocket-server.ts
   import { WebSocketServer } from 'ws';
   import { createServer } from 'http';
   import { parse } from 'url';
   
   export interface WebSocketMessage {
     type: 'metrics_update' | 'log_entry' | 'status_change' | 'test_result';
     featureId: string;
     data: any;
     timestamp: string;
   }
   
   export class AIManagementWebSocketServer {
     private wss: WebSocketServer;
     private clients: Map<string, Set<WebSocket>> = new Map();
     
     constructor(server: any) {
       this.wss = new WebSocketServer({ server });
       this.setupWebSocketHandlers();
     }
     
     private setupWebSocketHandlers(): void {
       this.wss.on('connection', (ws, request) => {
         const { query } = parse(request.url || '', true);
         const featureId = query.featureId as string;
         const userId = this.authenticateUser(request);
         
         if (!userId || !featureId) {
           ws.close(1008, 'Authentication required');
           return;
         }
         
         // Add client to feature subscription
         if (!this.clients.has(featureId)) {
           this.clients.set(featureId, new Set());
         }
         this.clients.get(featureId)!.add(ws);
         
         ws.on('close', () => {
           this.clients.get(featureId)?.delete(ws);
           if (this.clients.get(featureId)?.size === 0) {
             this.clients.delete(featureId);
           }
         });
         
         ws.on('message', (message) => {
           try {
             const data = JSON.parse(message.toString());
             this.handleClientMessage(ws, featureId, data);
           } catch (error) {
             console.error('Invalid WebSocket message:', error);
           }
         });
         
         // Send initial connection confirmation
         this.sendToClient(ws, {
           type: 'connection_confirmed',
           featureId,
           data: { connected: true },
           timestamp: new Date().toISOString()
         });
       });
     }
     
     public broadcastToFeature(featureId: string, message: WebSocketMessage): void {
       const clients = this.clients.get(featureId);
       if (!clients) return;
       
       const messageStr = JSON.stringify(message);
       clients.forEach(client => {
         if (client.readyState === WebSocket.OPEN) {
           client.send(messageStr);
         }
       });
     }
     
     public broadcastMetricsUpdate(featureId: string, metrics: any): void {
       this.broadcastToFeature(featureId, {
         type: 'metrics_update',
         featureId,
         data: metrics,
         timestamp: new Date().toISOString()
       });
     }
     
     public broadcastLogEntry(featureId: string, logEntry: any): void {
       this.broadcastToFeature(featureId, {
         type: 'log_entry',
         featureId,
         data: logEntry,
         timestamp: new Date().toISOString()
       });
     }
     
     private sendToClient(ws: WebSocket, message: any): void {
       if (ws.readyState === WebSocket.OPEN) {
         ws.send(JSON.stringify(message));
       }
     }
     
     private authenticateUser(request: any): string | null {
       // Integrate with existing Supabase auth
       const authHeader = request.headers.authorization;
       if (!authHeader) return null;
       
       // Validate JWT token and return user ID
       // Implementation depends on existing auth system
       return 'user-id'; // Placeholder
     }
     
     private handleClientMessage(ws: WebSocket, featureId: string, data: any): void {
       switch (data.type) {
         case 'subscribe_logs':
           // Client wants to start receiving log entries
           this.startLogStreaming(featureId, ws);
           break;
         case 'unsubscribe_logs':
           // Client wants to stop receiving log entries
           this.stopLogStreaming(featureId, ws);
           break;
         default:
           console.warn('Unknown client message type:', data.type);
       }
     }
     
     private startLogStreaming(featureId: string, ws: WebSocket): void {
       // Start streaming logs for this feature to this client
       // Implementation in log streaming section
     }
     
     private stopLogStreaming(featureId: string, ws: WebSocket): void {
       // Stop streaming logs for this feature to this client
       // Implementation in log streaming section
     }
   }
   ```

2. **Create WebSocket API route:**
   ```typescript
   // app/api/platform/ai-management/websocket/route.ts
   import { NextRequest } from 'next/server';
   import { AIManagementWebSocketServer } from '@/lib/websocket/websocket-server';
   
   let wsServer: AIManagementWebSocketServer | null = null;
   
   export async function GET(request: NextRequest) {
     // WebSocket upgrade handling
     if (request.headers.get('upgrade') !== 'websocket') {
       return new Response('Expected WebSocket upgrade', { status: 426 });
     }
     
     // In development, we'll use a different approach
     // In production, this would be handled by the server
     return new Response('WebSocket endpoint - use production server', {
       status: 200,
       headers: {
         'Content-Type': 'text/plain'
       }
     });
   }
   
   // Export function to get/create WebSocket server instance
   export function getWebSocketServer(): AIManagementWebSocketServer | null {
     return wsServer;
   }
   
   export function initWebSocketServer(server: any): void {
     if (!wsServer) {
       wsServer = new AIManagementWebSocketServer(server);
     }
   }
   ```

3. **Create client-side WebSocket manager:**
   ```typescript
   // lib/websocket/websocket-client.ts
   export class WebSocketManager {
     private ws: WebSocket | null = null;
     private reconnectAttempts = 0;
     private maxReconnectAttempts = 5;
     private reconnectDelay = 1000;
     private listeners: Map<string, Set<(data: any) => void>> = new Map();
     
     constructor(private featureId: string) {}
     
     public connect(): Promise<void> {
       return new Promise((resolve, reject) => {
         try {
           const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
           const wsUrl = `${protocol}//${window.location.host}/api/platform/ai-management/websocket?featureId=${this.featureId}`;
           
           this.ws = new WebSocket(wsUrl);
           
           this.ws.onopen = () => {
             console.log('WebSocket connected for feature:', this.featureId);
             this.reconnectAttempts = 0;
             resolve();
           };
           
           this.ws.onmessage = (event) => {
             try {
               const message = JSON.parse(event.data);
               this.handleMessage(message);
             } catch (error) {
               console.error('Failed to parse WebSocket message:', error);
             }
           };
           
           this.ws.onclose = (event) => {
             console.log('WebSocket closed:', event.code, event.reason);
             this.handleReconnection();
           };
           
           this.ws.onerror = (error) => {
             console.error('WebSocket error:', error);
             reject(error);
           };
         } catch (error) {
           reject(error);
         }
       });
     }
     
     public disconnect(): void {
       if (this.ws) {
         this.ws.close();
         this.ws = null;
       }
     }
     
     public subscribe(messageType: string, callback: (data: any) => void): () => void {
       if (!this.listeners.has(messageType)) {
         this.listeners.set(messageType, new Set());
       }
       this.listeners.get(messageType)!.add(callback);
       
       // Return unsubscribe function
       return () => {
         this.listeners.get(messageType)?.delete(callback);
       };
     }
     
     public send(message: any): void {
       if (this.ws && this.ws.readyState === WebSocket.OPEN) {
         this.ws.send(JSON.stringify(message));
       }
     }
     
     private handleMessage(message: WebSocketMessage): void {
       const listeners = this.listeners.get(message.type);
       if (listeners) {
         listeners.forEach(callback => callback(message.data));
       }
     }
     
     private handleReconnection(): void {
       if (this.reconnectAttempts < this.maxReconnectAttempts) {
         this.reconnectAttempts++;
         const delay = this.reconnectDelay * Math.pow(2, this.reconnectAttempts - 1);
         
         console.log(`Attempting to reconnect in ${delay}ms (attempt ${this.reconnectAttempts})`);
         
         setTimeout(() => {
           this.connect().catch(console.error);
         }, delay);
       } else {
         console.error('Max reconnection attempts reached');
       }
     }
   }
   
   // React hook for WebSocket management
   export function useWebSocket(featureId: string) {
     const wsManagerRef = useRef<WebSocketManager | null>(null);
     const [isConnected, setIsConnected] = useState(false);
     
     useEffect(() => {
       if (!featureId) return;
       
       wsManagerRef.current = new WebSocketManager(featureId);
       
       wsManagerRef.current.connect()
         .then(() => setIsConnected(true))
         .catch(console.error);
       
       return () => {
         wsManagerRef.current?.disconnect();
         setIsConnected(false);
       };
     }, [featureId]);
     
     const subscribe = useCallback((messageType: string, callback: (data: any) => void) => {
       return wsManagerRef.current?.subscribe(messageType, callback) || (() => {});
     }, []);
     
     const send = useCallback((message: any) => {
       wsManagerRef.current?.send(message);
     }, []);
     
     return { isConnected, subscribe, send };
   }
   ```

**Files to Create:**
- `lib/websocket/websocket-server.ts`
- `lib/websocket/websocket-client.ts`
- `app/api/platform/ai-management/websocket/route.ts`

**Acceptance Criteria:**
- [ ] WebSocket server handles multiple concurrent connections
- [ ] Client-side automatic reconnection with exponential backoff
- [ ] Feature-specific message routing and subscription
- [ ] Authentication integration with existing auth system
- [ ] Graceful error handling and connection management

### Task 7.2: Real-time Metrics Collection Service
**Duration:** 3 hours  
**Priority:** High  
**Complexity:** Medium

**Objective:** Create service to collect and broadcast real-time metrics

**Implementation Steps:**
1. **Create metrics collection service:**
   ```typescript
   // lib/services/metrics/real-time-metrics-service.ts
   export interface MetricsSnapshot {
     featureId: string;
     timestamp: string;
     metrics: {
       uptime: number;
       error_rate: number;
       response_time: number;
       success_rate: number;
       total_requests: number;
       cost_per_request: number;
       requests_per_minute: number;
     };
     health_status: 'healthy' | 'warning' | 'error';
     alerts: Array<{
       type: string;
       message: string;
       severity: 'low' | 'medium' | 'high';
       timestamp: string;
     }>;
   }
   
   export class RealTimeMetricsService {
     private metricsCache: Map<string, MetricsSnapshot> = new Map();
     private updateIntervals: Map<string, NodeJS.Timeout> = new Map();
     
     public startMetricsCollection(featureId: string): void {
       // Clear existing interval if any
       this.stopMetricsCollection(featureId);
       
       // Collect initial metrics
       this.collectMetrics(featureId);
       
       // Set up periodic collection (every 30 seconds)
       const interval = setInterval(() => {
         this.collectMetrics(featureId);
       }, 30000);
       
       this.updateIntervals.set(featureId, interval);
     }
     
     public stopMetricsCollection(featureId: string): void {
       const interval = this.updateIntervals.get(featureId);
       if (interval) {
         clearInterval(interval);
         this.updateIntervals.delete(featureId);
       }
     }
     
     public getLatestMetrics(featureId: string): MetricsSnapshot | null {
       return this.metricsCache.get(featureId) || null;
     }
     
     private async collectMetrics(featureId: string): Promise<void> {
       try {
         // Collect metrics from various sources
         const [basicMetrics, performanceMetrics, costMetrics, healthData] = await Promise.all([
           this.getBasicMetrics(featureId),
           this.getPerformanceMetrics(featureId),
           this.getCostMetrics(featureId),
           this.getHealthStatus(featureId)
         ]);
         
         const snapshot: MetricsSnapshot = {
           featureId,
           timestamp: new Date().toISOString(),
           metrics: {
             ...basicMetrics,
             ...performanceMetrics,
             ...costMetrics
           },
           health_status: healthData.status,
           alerts: healthData.alerts
         };
         
         // Cache the snapshot
         this.metricsCache.set(featureId, snapshot);
         
         // Broadcast to WebSocket clients
         this.broadcastMetricsUpdate(featureId, snapshot);
         
       } catch (error) {
         console.error(`Failed to collect metrics for feature ${featureId}:`, error);
       }
     }
     
     private async getBasicMetrics(featureId: string) {
       // Query database for basic metrics
       const response = await fetch(`/api/platform/ai-management/features/${featureId}/metrics?time_range=5m`);
       if (!response.ok) throw new Error('Failed to fetch basic metrics');
       const data = await response.json();
       
       return {
         uptime: data.uptime || 0,
         total_requests: data.total_requests || 0,
         requests_per_minute: data.requests_per_minute || 0
       };
     }
     
     private async getPerformanceMetrics(featureId: string) {
       // Query performance data
       const response = await fetch(`/api/platform/ai-management/features/${featureId}/performance?time_range=5m`);
       if (!response.ok) throw new Error('Failed to fetch performance metrics');
       const data = await response.json();
       
       return {
         error_rate: data.error_rate || 0,
         response_time: data.avg_response_time || 0,
         success_rate: data.success_rate || 0
       };
     }
     
     private async getCostMetrics(featureId: string) {
       // Query cost data
       const response = await fetch(`/api/platform/ai-management/features/${featureId}/costs?time_range=5m`);
       if (!response.ok) throw new Error('Failed to fetch cost metrics');
       const data = await response.json();
       
       return {
         cost_per_request: data.cost_per_request || 0
       };
     }
     
     private async getHealthStatus(featureId: string) {
       // Determine health status based on metrics and alerts
       const response = await fetch(`/api/platform/ai-management/features/${featureId}/health`);
       if (!response.ok) throw new Error('Failed to fetch health status');
       const data = await response.json();
       
       return {
         status: data.status || 'healthy',
         alerts: data.alerts || []
       };
     }
     
     private broadcastMetricsUpdate(featureId: string, snapshot: MetricsSnapshot): void {
       // Get WebSocket server instance and broadcast
       const wsServer = getWebSocketServer();
       if (wsServer) {
         wsServer.broadcastMetricsUpdate(featureId, snapshot);
       }
     }
   }
   
   // Singleton instance
   const metricsService = new RealTimeMetricsService();
   export { metricsService };
   ```

2. **Create real-time metrics React hook:**
   ```typescript
   // hooks/useRealTimeMetrics.ts
   import { useState, useEffect } from 'react';
   import { useWebSocket } from '@/lib/websocket/websocket-client';
   import type { MetricsSnapshot } from '@/lib/services/metrics/real-time-metrics-service';
   
   export function useRealTimeMetrics(featureId: string, autoRefresh: boolean = true) {
     const [metrics, setMetrics] = useState<MetricsSnapshot | null>(null);
     const [lastUpdated, setLastUpdated] = useState<Date | null>(null);
     const [isLoading, setIsLoading] = useState(true);
     const { isConnected, subscribe } = useWebSocket(featureId);
     
     // Subscribe to WebSocket metrics updates
     useEffect(() => {
       if (!isConnected || !autoRefresh) return;
       
       const unsubscribe = subscribe('metrics_update', (data: MetricsSnapshot) => {
         setMetrics(data);
         setLastUpdated(new Date());
         setIsLoading(false);
       });
       
       return unsubscribe;
     }, [isConnected, autoRefresh, subscribe]);
     
     // Fetch initial metrics
     useEffect(() => {
       if (!featureId) return;
       
       const fetchInitialMetrics = async () => {
         try {
           const response = await fetch(`/api/platform/ai-management/features/${featureId}/metrics/current`);
           if (response.ok) {
             const data = await response.json();
             setMetrics(data.data);
             setLastUpdated(new Date());
           }
         } catch (error) {
           console.error('Failed to fetch initial metrics:', error);
         } finally {
           setIsLoading(false);
         }
       };
       
       fetchInitialMetrics();
     }, [featureId]);
     
     const refreshMetrics = async () => {
       if (!featureId) return;
       
       setIsLoading(true);
       try {
         const response = await fetch(`/api/platform/ai-management/features/${featureId}/metrics/current`);
         if (response.ok) {
           const data = await response.json();
           setMetrics(data.data);
           setLastUpdated(new Date());
         }
       } catch (error) {
         console.error('Failed to refresh metrics:', error);
       } finally {
         setIsLoading(false);
       }
     };
     
     return {
       metrics,
       lastUpdated,
       isLoading,
       isConnected,
       refreshMetrics
     };
   }
   ```

**Files to Create:**
- `lib/services/metrics/real-time-metrics-service.ts`
- `hooks/useRealTimeMetrics.ts`
- `app/api/platform/ai-management/features/[id]/metrics/current/route.ts`

**Acceptance Criteria:**
- [ ] Metrics collection runs every 30 seconds for active features
- [ ] Real-time updates broadcast to WebSocket clients
- [ ] React hook provides easy access to live metrics
- [ ] Metrics include performance, cost, and health data
- [ ] Graceful handling of metrics collection failures

### Task 7.3: Server-Sent Events Fallback
**Duration:** 1 hour  
**Priority:** Medium  
**Complexity:** Low

**Objective:** Implement SSE fallback for environments where WebSocket is blocked

**Implementation Steps:**
1. **Create SSE endpoint:**
   ```typescript
   // app/api/platform/ai-management/features/[id]/metrics/stream/route.ts
   export async function GET(
     request: Request,
     { params }: { params: { id: string } }
   ) {
     const featureId = params.id;
     
     // Set up SSE headers
     const headers = new Headers({
       'Content-Type': 'text/event-stream',
       'Cache-Control': 'no-cache',
       'Connection': 'keep-alive',
       'Access-Control-Allow-Origin': '*',
       'Access-Control-Allow-Headers': 'Cache-Control'
     });
     
     // Create readable stream for SSE
     const stream = new ReadableStream({
       start(controller) {
         // Send initial connection message
         controller.enqueue(`data: ${JSON.stringify({
           type: 'connected',
           featureId
         })}\n\n`);
         
         // Set up metrics streaming
         const interval = setInterval(async () => {
           try {
             const response = await fetch(`http://localhost:3000/api/platform/ai-management/features/${featureId}/metrics/current`);
             if (response.ok) {
               const data = await response.json();
               controller.enqueue(`data: ${JSON.stringify({
                 type: 'metrics_update',
                 data: data.data
               })}\n\n`);
             }
           } catch (error) {
             console.error('SSE metrics fetch error:', error);
           }
         }, 30000);
         
         // Clean up on close
         request.signal.addEventListener('abort', () => {
           clearInterval(interval);
           controller.close();
         });
       }
     });
     
     return new Response(stream, { headers });
   }
   ```

2. **Create SSE client hook:**
   ```typescript
   // hooks/useServerSentEvents.ts
   export function useServerSentEvents(featureId: string, enabled: boolean = true) {
     const [isConnected, setIsConnected] = useState(false);
     const [data, setData] = useState<any>(null);
     const eventSourceRef = useRef<EventSource | null>(null);
     
     useEffect(() => {
       if (!enabled || !featureId) return;
       
       const eventSource = new EventSource(
         `/api/platform/ai-management/features/${featureId}/metrics/stream`
       );
       
       eventSource.onopen = () => {
         setIsConnected(true);
       };
       
       eventSource.onmessage = (event) => {
         try {
           const message = JSON.parse(event.data);
           if (message.type === 'metrics_update') {
             setData(message.data);
           }
         } catch (error) {
           console.error('Failed to parse SSE message:', error);
         }
       };
       
       eventSource.onerror = () => {
         setIsConnected(false);
       };
       
       eventSourceRef.current = eventSource;
       
       return () => {
         eventSource.close();
         setIsConnected(false);
       };
     }, [featureId, enabled]);
     
     return { isConnected, data };
   }
   ```

**Files to Create:**
- `app/api/platform/ai-management/features/[id]/metrics/stream/route.ts`
- `hooks/useServerSentEvents.ts`

**Acceptance Criteria:**
- [ ] SSE endpoint streams metrics updates
- [ ] Automatic fallback when WebSocket unavailable
- [ ] Proper connection cleanup on component unmount
- [ ] Compatible with restrictive network environments

---

## Day 8: Log Streaming and Drawer Interface

### Task 8.1: Log Aggregation Service
**Duration:** 4 hours  
**Priority:** High  
**Complexity:** High

**Objective:** Create log aggregation service with real-time streaming capabilities

**Implementation Steps:**
1. **Create log streaming service:**
   ```typescript
   // lib/services/logging/log-streaming-service.ts
   export interface LogEntry {
     id: string;
     featureId: string;
     timestamp: string;
     level: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
     message: string;
     metadata?: Record<string, any>;
     source: string;
     environment: 'development' | 'staging' | 'production';
     trace_id?: string;
     user_id?: string;
   }
   
   export interface LogFilters {
     level?: string[];
     timeRange?: {
       start: Date;
       end: Date;
     };
     environment?: string;
     source?: string;
     search?: string;
   }
   
   export class LogStreamingService {
     private logBuffer: Map<string, LogEntry[]> = new Map();
     private maxBufferSize = 1000;
     private streamingClients: Map<string, Set<WebSocket>> = new Map();
     
     public async getFilteredLogs(featureId: string, filters: LogFilters): Promise<LogEntry[]> {
       // Fetch from database with filters
       const params = new URLSearchParams();
       params.append('feature_id', featureId);
       
       if (filters.level && filters.level.length > 0) {
         params.append('levels', filters.level.join(','));
       }
       
       if (filters.timeRange) {
         params.append('start_time', filters.timeRange.start.toISOString());
         params.append('end_time', filters.timeRange.end.toISOString());
       }
       
       if (filters.environment) {
         params.append('environment', filters.environment);
       }
       
       if (filters.source) {
         params.append('source', filters.source);
       }
       
       if (filters.search) {
         params.append('search', filters.search);
       }
       
       const response = await fetch(`/api/platform/ai-management/logs?${params}`);
       if (!response.ok) throw new Error('Failed to fetch logs');
       
       const data = await response.json();
       return data.logs;
     }
     
     public startLogStreaming(featureId: string, ws: WebSocket): void {
       if (!this.streamingClients.has(featureId)) {
         this.streamingClients.set(featureId, new Set());
       }
       this.streamingClients.get(featureId)!.add(ws);
       
       // Send recent logs from buffer
       const recentLogs = this.logBuffer.get(featureId) || [];
       const last50Logs = recentLogs.slice(-50);
       
       ws.send(JSON.stringify({
         type: 'log_history',
         data: last50Logs
       }));
     }
     
     public stopLogStreaming(featureId: string, ws: WebSocket): void {
       this.streamingClients.get(featureId)?.delete(ws);
     }
     
     public ingestLogEntry(logEntry: LogEntry): void {
       // Add to buffer
       if (!this.logBuffer.has(logEntry.featureId)) {
         this.logBuffer.set(logEntry.featureId, []);
       }
       
       const buffer = this.logBuffer.get(logEntry.featureId)!;
       buffer.push(logEntry);
       
       // Maintain buffer size
       if (buffer.length > this.maxBufferSize) {
         buffer.splice(0, buffer.length - this.maxBufferSize);
       }
       
       // Broadcast to streaming clients
       this.broadcastLogEntry(logEntry);
     }
     
     private broadcastLogEntry(logEntry: LogEntry): void {
       const clients = this.streamingClients.get(logEntry.featureId);
       if (!clients) return;
       
       const message = JSON.stringify({
         type: 'log_entry',
         data: logEntry
       });
       
       clients.forEach(client => {
         if (client.readyState === WebSocket.OPEN) {
           client.send(message);
         }
       });
     }
     
     public async exportLogs(featureId: string, filters: LogFilters, format: 'json' | 'csv'): Promise<Blob> {
       const logs = await this.getFilteredLogs(featureId, filters);
       
       if (format === 'json') {
         return new Blob([JSON.stringify(logs, null, 2)], { type: 'application/json' });
       } else {
         const csv = this.convertLogsToCSV(logs);
         return new Blob([csv], { type: 'text/csv' });
       }
     }
     
     private convertLogsToCSV(logs: LogEntry[]): string {
       const headers = ['timestamp', 'level', 'message', 'source', 'environment', 'trace_id'];
       const csvLines = [headers.join(',')];
       
       logs.forEach(log => {
         const row = [
           log.timestamp,
           log.level,
           `"${log.message.replace(/"/g, '""')}"`,
           log.source,
           log.environment,
           log.trace_id || ''
         ];
         csvLines.push(row.join(','));
       });
       
       return csvLines.join('\n');
     }
   }
   
   // Singleton instance
   export const logStreamingService = new LogStreamingService();
   ```

2. **Create log API endpoints:**
   ```typescript
   // app/api/platform/ai-management/logs/route.ts
   import { logStreamingService } from '@/lib/services/logging/log-streaming-service';
   
   export async function GET(request: Request) {
     const { searchParams } = new URL(request.url);
     const featureId = searchParams.get('feature_id');
     
     if (!featureId) {
       return Response.json({ error: 'Feature ID required' }, { status: 400 });
     }
     
     try {
       const filters = {
         level: searchParams.get('levels')?.split(','),
         environment: searchParams.get('environment') || undefined,
         source: searchParams.get('source') || undefined,
         search: searchParams.get('search') || undefined,
         timeRange: searchParams.get('start_time') && searchParams.get('end_time') ? {
           start: new Date(searchParams.get('start_time')!),
           end: new Date(searchParams.get('end_time')!)
         } : undefined
       };
       
       const logs = await logStreamingService.getFilteredLogs(featureId, filters);
       
       return Response.json({ logs });
     } catch (error) {
       console.error('Failed to fetch logs:', error);
       return Response.json({ error: 'Failed to fetch logs' }, { status: 500 });
     }
   }
   
   export async function POST(request: Request) {
     try {
       const logEntry = await request.json();
       
       // Validate log entry
       if (!logEntry.featureId || !logEntry.message) {
         return Response.json({ error: 'Invalid log entry' }, { status: 400 });
       }
       
       // Add timestamp if not provided
       if (!logEntry.timestamp) {
         logEntry.timestamp = new Date().toISOString();
       }
       
       // Add unique ID
       logEntry.id = `log-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
       
       // Ingest log entry
       logStreamingService.ingestLogEntry(logEntry);
       
       return Response.json({ success: true });
     } catch (error) {
       console.error('Failed to ingest log entry:', error);
       return Response.json({ error: 'Failed to ingest log entry' }, { status: 500 });
     }
   }
   ```

**Files to Create:**
- `lib/services/logging/log-streaming-service.ts`
- `app/api/platform/ai-management/logs/route.ts`
- `app/api/platform/ai-management/logs/export/route.ts`

**Acceptance Criteria:**
- [ ] Log ingestion with real-time buffering
- [ ] Filtered log retrieval with search capabilities
- [ ] Real-time log streaming to WebSocket clients
- [ ] Log export in JSON and CSV formats
- [ ] Efficient memory management with buffer limits

### Task 8.2: Create Log Drawer Interface
**Duration:** 3 hours  
**Priority:** High  
**Complexity:** Medium

**Objective:** Create slide-out drawer component for log access

**Implementation Steps:**
1. **Create LogsDrawer component:**
   ```typescript
   // components/platform/ai-management/unified/monitoring/LogsDrawer.tsx
   import { useState, useEffect, useCallback } from 'react';
   import { useWebSocket } from '@/lib/websocket/websocket-client';
   import type { LogEntry, LogFilters } from '@/lib/services/logging/log-streaming-service';
   
   interface LogsDrawerProps {
     featureId: string;
     isOpen: boolean;
     onClose: () => void;
   }
   
   export function LogsDrawer({ featureId, isOpen, onClose }: LogsDrawerProps) {
     const [logs, setLogs] = useState<LogEntry[]>([]);
     const [filters, setFilters] = useState<LogFilters>({
       level: [],
       timeRange: {
         start: new Date(Date.now() - 24 * 60 * 60 * 1000), // Last 24 hours
         end: new Date()
       }
     });
     const [isStreaming, setIsStreaming] = useState(false);
     const [isLoading, setIsLoading] = useState(false);
     const [searchQuery, setSearchQuery] = useState('');
     
     const { isConnected, subscribe, send } = useWebSocket(featureId);
     
     // Subscribe to log entries
     useEffect(() => {
       if (!isConnected || !isOpen) return;
       
       const unsubscribeHistory = subscribe('log_history', (historyLogs: LogEntry[]) => {
         setLogs(historyLogs);
       });
       
       const unsubscribeEntry = subscribe('log_entry', (logEntry: LogEntry) => {
         setLogs(prev => [...prev, logEntry].slice(-1000)); // Keep last 1000 logs
       });
       
       return () => {
         unsubscribeHistory();
         unsubscribeEntry();
       };
     }, [isConnected, isOpen, subscribe]);
     
     // Start/stop log streaming
     const toggleStreaming = useCallback(() => {
       if (isStreaming) {
         send({ type: 'unsubscribe_logs' });
         setIsStreaming(false);
       } else {
         send({ type: 'subscribe_logs' });
         setIsStreaming(true);
       }
     }, [isStreaming, send]);
     
     // Fetch historical logs
     const fetchLogs = useCallback(async () => {
       setIsLoading(true);
       try {
         const params = new URLSearchParams({
           feature_id: featureId,
           start_time: filters.timeRange?.start.toISOString() || '',
           end_time: filters.timeRange?.end.toISOString() || ''
         });
         
         if (filters.level && filters.level.length > 0) {
           params.append('levels', filters.level.join(','));
         }
         
         if (filters.environment) {
           params.append('environment', filters.environment);
         }
         
         if (searchQuery) {
           params.append('search', searchQuery);
         }
         
         const response = await fetch(`/api/platform/ai-management/logs?${params}`);
         if (response.ok) {
           const data = await response.json();
           setLogs(data.logs);
         }
       } catch (error) {
         console.error('Failed to fetch logs:', error);
         toast.error('Failed to fetch logs');
       } finally {
         setIsLoading(false);
       }
     }, [featureId, filters, searchQuery]);
     
     // Filter logs based on search query
     const filteredLogs = useMemo(() => {
       if (!searchQuery) return logs;
       
       const query = searchQuery.toLowerCase();
       return logs.filter(log =>
         log.message.toLowerCase().includes(query) ||
         log.source.toLowerCase().includes(query) ||
         (log.metadata && JSON.stringify(log.metadata).toLowerCase().includes(query))
       );
     }, [logs, searchQuery]);
     
     // Export logs
     const exportLogs = async (format: 'json' | 'csv') => {
       try {
         const params = new URLSearchParams({
           feature_id: featureId,
           format,
           start_time: filters.timeRange?.start.toISOString() || '',
           end_time: filters.timeRange?.end.toISOString() || ''
         });
         
         const response = await fetch(`/api/platform/ai-management/logs/export?${params}`);
         if (response.ok) {
           const blob = await response.blob();
           const url = URL.createObjectURL(blob);
           const a = document.createElement('a');
           a.href = url;
           a.download = `logs-${featureId}-${new Date().toISOString().split('T')[0]}.${format}`;
           a.click();
           URL.revokeObjectURL(url);
         }
       } catch (error) {
         console.error('Failed to export logs:', error);
         toast.error('Failed to export logs');
       }
     };
     
     if (!isOpen) return null;
     
     return (
       <div className="fixed inset-y-0 right-0 w-1/2 bg-white shadow-xl border-l z-50 flex flex-col">
         {/* Header */}
         <div className="bg-gray-50 px-6 py-4 border-b">
           <div className="flex items-center justify-between">
             <div className="flex items-center gap-3">
               <h2 className="text-lg font-semibold">System Logs</h2>
               <Badge variant={isConnected ? 'secondary' : 'destructive'}>
                 {isConnected ? 'Connected' : 'Disconnected'}
               </Badge>
               {isStreaming && (
                 <Badge variant="default" className="animate-pulse">
                   Live
                 </Badge>
               )}
             </div>
             <div className="flex items-center gap-2">
               <Button
                 variant="outline"
                 size="sm"
                 onClick={toggleStreaming}
                 disabled={!isConnected}
               >
                 {isStreaming ? 'Stop Streaming' : 'Start Streaming'}
               </Button>
               <Button variant="ghost" size="sm" onClick={onClose}>
                 <X className="h-4 w-4" />
               </Button>
             </div>
           </div>
         </div>
         
         {/* Filters and Search */}
         <div className="p-4 border-b space-y-4">
           <div className="flex items-center gap-2">
             <Input
               placeholder="Search logs..."
               value={searchQuery}
               onChange={(e) => setSearchQuery(e.target.value)}
               className="flex-1"
             />
             <Button onClick={fetchLogs} disabled={isLoading}>
               {isLoading ? <Loader2 className="h-4 w-4 animate-spin" /> : <Search className="h-4 w-4" />}
             </Button>
           </div>
           
           <div className="flex items-center gap-2 flex-wrap">
             <LogLevelFilter filters={filters} onFiltersChange={setFilters} />
             <TimeRangeFilter filters={filters} onFiltersChange={setFilters} />
             <EnvironmentFilter filters={filters} onFiltersChange={setFilters} />
             
             <DropdownMenu>
               <DropdownMenuTrigger asChild>
                 <Button variant="outline" size="sm">
                   <Download className="h-4 w-4 mr-2" />
                   Export
                 </Button>
               </DropdownMenuTrigger>
               <DropdownMenuContent>
                 <DropdownMenuItem onClick={() => exportLogs('json')}>
                   Export as JSON
                 </DropdownMenuItem>
                 <DropdownMenuItem onClick={() => exportLogs('csv')}>
                   Export as CSV
                 </DropdownMenuItem>
               </DropdownMenuContent>
             </DropdownMenu>
           </div>
         </div>
         
         {/* Log Entries */}
         <div className="flex-1 overflow-auto p-4">
           {filteredLogs.length === 0 ? (
             <div className="text-center py-8">
               <FileText className="h-12 w-12 text-gray-400 mx-auto mb-4" />
               <p className="text-gray-500">No logs found</p>
               {!isStreaming && (
                 <Button variant="outline" className="mt-2" onClick={fetchLogs}>
                   Fetch Historical Logs
                 </Button>
               )}
             </div>
           ) : (
             <div className="space-y-2">
               {filteredLogs.map((log) => (
                 <LogEntryItem key={log.id} log={log} />
               ))}
             </div>
           )}
         </div>
       </div>
     );
   }
   ```

2. **Create LogEntryItem component:**
   ```typescript
   // components/platform/ai-management/unified/monitoring/LogEntryItem.tsx
   interface LogEntryItemProps {
     log: LogEntry;
   }
   
   export function LogEntryItem({ log }: LogEntryItemProps) {
     const [isExpanded, setIsExpanded] = useState(false);
     
     const getLevelColor = (level: string) => {
       switch (level) {
         case 'error':
         case 'fatal':
           return 'text-red-600 bg-red-50';
         case 'warn':
           return 'text-yellow-600 bg-yellow-50';
         case 'info':
           return 'text-blue-600 bg-blue-50';
         case 'debug':
           return 'text-gray-600 bg-gray-50';
         default:
           return 'text-gray-600 bg-gray-50';
       }
     };
     
     const formatTimestamp = (timestamp: string) => {
       return new Date(timestamp).toLocaleString();
     };
     
     return (
       <div className="border rounded-lg p-3 space-y-2">
         <div className="flex items-start justify-between">
           <div className="flex items-center gap-2 min-w-0 flex-1">
             <Badge className={`text-xs ${getLevelColor(log.level)}`}>
               {log.level.toUpperCase()}
             </Badge>
             <span className="text-xs text-gray-500 font-mono">
               {formatTimestamp(log.timestamp)}
             </span>
             <span className="text-xs text-gray-400">
               {log.source}
             </span>
             {log.environment && (
               <Badge variant="outline" className="text-xs">
                 {log.environment}
               </Badge>
             )}
           </div>
           
           {log.metadata && Object.keys(log.metadata).length > 0 && (
             <Button
               variant="ghost"
               size="sm"
               onClick={() => setIsExpanded(!isExpanded)}
             >
               {isExpanded ? <ChevronUp className="h-4 w-4" /> : <ChevronDown className="h-4 w-4" />}
             </Button>
           )}
         </div>
         
         <div className="space-y-2">
           <p className="text-sm text-gray-900 font-mono leading-relaxed">
             {log.message}
           </p>
           
           {log.trace_id && (
             <div className="text-xs text-gray-500">
               Trace ID: <code className="bg-gray-100 px-1 rounded">{log.trace_id}</code>
             </div>
           )}
           
           {isExpanded && log.metadata && (
             <details className="text-xs">
               <summary className="cursor-pointer text-gray-600 mb-2">
                 Metadata ({Object.keys(log.metadata).length} fields)
               </summary>
               <pre className="bg-gray-50 p-2 rounded text-xs overflow-auto">
                 {JSON.stringify(log.metadata, null, 2)}
               </pre>
             </details>
           )}
         </div>
       </div>
     );
   }
   ```

**Files to Create:**
- `components/platform/ai-management/unified/monitoring/LogsDrawer.tsx`
- `components/platform/ai-management/unified/monitoring/LogEntryItem.tsx`
- `components/platform/ai-management/unified/monitoring/LogFilters.tsx`

**Acceptance Criteria:**
- [ ] Slide-out drawer interface with proper z-index
- [ ] Real-time log streaming with auto-scroll
- [ ] Search and filter functionality
- [ ] Log level color coding
- [ ] Export capabilities (JSON/CSV)
- [ ] Expandable log entries with metadata

### Task 8.3: Integrate Logs Access in Settings
**Duration:** 1 hour  
**Priority:** Medium  
**Complexity:** Low

**Objective:** Add "View Logs" buttons throughout the settings interface

**Implementation Steps:**
1. **Update existing components with log access:**
   ```typescript
   // Update components to include log access
   
   // In ModelAssignmentSection.tsx
   export function ModelAssignmentSection({ featureId }: ModelAssignmentSectionProps) {
     const [logsDrawerOpen, setLogsDrawerOpen] = useState(false);
     
     return (
       <div className="space-y-6">
         {/* Existing model assignment interface */}
         <FeatureModelAssignment featureId={featureId} />
         
         {/* Add logs access button */}
         <div className="flex justify-between items-center">
           <div>
             <h4 className="font-medium">Model Diagnostics</h4>
             <p className="text-sm text-muted-foreground">
               View model execution logs and performance data
             </p>
           </div>
           <Button
             variant="outline"
             onClick={() => setLogsDrawerOpen(true)}
           >
             <FileText className="h-4 w-4 mr-2" />
             View Logs
           </Button>
         </div>
         
         {/* Logs Drawer */}
         <LogsDrawer
           featureId={featureId}
           isOpen={logsDrawerOpen}
           onClose={() => setLogsDrawerOpen(false)}
         />
       </div>
     );
   }
   ```

**Files to Modify:**
- `components/platform/ai-management/unified/sections/ModelAssignmentSection.tsx`
- `components/platform/ai-management/unified/sections/PromptManagementSection.tsx`
- `components/platform/ai-management/unified/sections/RateLimitsSection.tsx`

**Acceptance Criteria:**
- [ ] "View Logs" buttons accessible from all major settings sections
- [ ] Consistent button placement and styling
- [ ] Drawer opens with appropriate context
- [ ] No interference with existing functionality

---

## Day 9: Contextual Monitoring and Alerts

### Task 9.1: Create Alert Management System
**Duration:** 3 hours  
**Priority:** High  
**Complexity:** Medium

**Objective:** Implement alert threshold configuration and real-time alerting

**Implementation Steps:**
1. **Create AlertManager service:**
   ```typescript
   // lib/services/alerts/alert-manager.ts
   export interface AlertRule {
     id: string;
     featureId: string;
     name: string;
     metric: string;
     condition: 'greater_than' | 'less_than' | 'equals';
     threshold: number;
     severity: 'low' | 'medium' | 'high' | 'critical';
     enabled: boolean;
     cooldown_minutes: number;
     notification_channels: string[];
   }
   
   export interface Alert {
     id: string;
     ruleId: string;
     featureId: string;
     title: string;
     message: string;
     severity: 'low' | 'medium' | 'high' | 'critical';
     status: 'active' | 'acknowledged' | 'resolved';
     triggered_at: string;
     resolved_at?: string;
     metadata: Record<string, any>;
   }
   
   export class AlertManager {
     private activeAlerts: Map<string, Alert> = new Map();
     private alertRules: Map<string, AlertRule[]> = new Map();
     
     public async loadAlertRules(featureId: string): Promise<void> {
       try {
         const response = await fetch(`/api/platform/ai-management/features/${featureId}/alerts/rules`);
         if (response.ok) {
           const data = await response.json();
           this.alertRules.set(featureId, data.rules);
         }
       } catch (error) {
         console.error('Failed to load alert rules:', error);
       }
     }
     
     public checkMetricsForAlerts(featureId: string, metrics: any): Alert[] {
       const rules = this.alertRules.get(featureId) || [];
       const triggeredAlerts: Alert[] = [];
       
       rules.forEach(rule => {
         if (!rule.enabled) return;
         
         const metricValue = this.getMetricValue(metrics, rule.metric);
         if (metricValue === null) return;
         
         const shouldTrigger = this.evaluateCondition(metricValue, rule);
         
         if (shouldTrigger) {
           const alert = this.createAlert(rule, metricValue, metrics);
           triggeredAlerts.push(alert);
           this.activeAlerts.set(alert.id, alert);
         }
       });
       
       return triggeredAlerts;
     }
     
     private getMetricValue(metrics: any, metricPath: string): number | null {
       const parts = metricPath.split('.');
       let value = metrics;
       
       for (const part of parts) {
         if (value && typeof value === 'object' && part in value) {
           value = value[part];
         } else {
           return null;
         }
       }
       
       return typeof value === 'number' ? value : null;
     }
     
     private evaluateCondition(value: number, rule: AlertRule): boolean {
       switch (rule.condition) {
         case 'greater_than':
           return value > rule.threshold;
         case 'less_than':
           return value < rule.threshold;
         case 'equals':
           return value === rule.threshold;
         default:
           return false;
       }
     }
     
     private createAlert(rule: AlertRule, triggerValue: number, metrics: any): Alert {
       return {
         id: `alert-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
         ruleId: rule.id,
         featureId: rule.featureId,
         title: `${rule.name} Alert`,
         message: `${rule.metric} is ${triggerValue}, which is ${rule.condition.replace('_', ' ')} threshold of ${rule.threshold}`,
         severity: rule.severity,
         status: 'active',
         triggered_at: new Date().toISOString(),
         metadata: {
           trigger_value: triggerValue,
           threshold: rule.threshold,
           condition: rule.condition,
           metrics_snapshot: metrics
         }
       };
     }
     
     public getActiveAlerts(featureId: string): Alert[] {
       return Array.from(this.activeAlerts.values())
         .filter(alert => alert.featureId === featureId && alert.status === 'active');
     }
     
     public acknowledgeAlert(alertId: string): void {
       const alert = this.activeAlerts.get(alertId);
       if (alert) {
         alert.status = 'acknowledged';
         this.activeAlerts.set(alertId, alert);
       }
     }
     
     public resolveAlert(alertId: string): void {
       const alert = this.activeAlerts.get(alertId);
       if (alert) {
         alert.status = 'resolved';
         alert.resolved_at = new Date().toISOString();
         this.activeAlerts.set(alertId, alert);
       }
     }
   }
   
   export const alertManager = new AlertManager();
   ```

2. **Create AlertsPanel component:**
   ```typescript
   // components/platform/ai-management/unified/monitoring/AlertsPanel.tsx
   interface AlertsPanelProps {
     featureId: string;
     alerts: Alert[];
     onAcknowledge: (alertId: string) => void;
     onResolve: (alertId: string) => void;
   }
   
   export function AlertsPanel({ featureId, alerts, onAcknowledge, onResolve }: AlertsPanelProps) {
     const activeAlerts = alerts.filter(alert => alert.status === 'active');
     const acknowledgedAlerts = alerts.filter(alert => alert.status === 'acknowledged');
     
     if (alerts.length === 0) {
       return (
         <Card>
           <CardContent className="py-6">
             <div className="text-center">
               <CheckCircle className="h-12 w-12 text-green-500 mx-auto mb-4" />
               <h3 className="font-medium text-gray-900 mb-2">All Clear</h3>
               <p className="text-sm text-gray-600">No active alerts for this feature</p>
             </div>
           </CardContent>
         </Card>
       );
     }
     
     return (
       <div className="space-y-4">
         {/* Active Alerts */}
         {activeAlerts.length > 0 && (
           <Card>
             <CardHeader>
               <CardTitle className="flex items-center gap-2">
                 <AlertTriangle className="h-5 w-5 text-red-500" />
                 Active Alerts ({activeAlerts.length})
               </CardTitle>
             </CardHeader>
             <CardContent className="space-y-3">
               {activeAlerts.map(alert => (
                 <AlertItem
                   key={alert.id}
                   alert={alert}
                   onAcknowledge={onAcknowledge}
                   onResolve={onResolve}
                 />
               ))}
             </CardContent>
           </Card>
         )}
         
         {/* Acknowledged Alerts */}
         {acknowledgedAlerts.length > 0 && (
           <Card>
             <CardHeader>
               <CardTitle className="flex items-center gap-2">
                 <Clock className="h-5 w-5 text-yellow-500" />
                 Acknowledged Alerts ({acknowledgedAlerts.length})
               </CardTitle>
             </CardHeader>
             <CardContent className="space-y-3">
               {acknowledgedAlerts.map(alert => (
                 <AlertItem
                   key={alert.id}
                   alert={alert}
                   onAcknowledge={onAcknowledge}
                   onResolve={onResolve}
                 />
               ))}
             </CardContent>
           </Card>
         )}
       </div>
     );
   }
   
   interface AlertItemProps {
     alert: Alert;
     onAcknowledge: (alertId: string) => void;
     onResolve: (alertId: string) => void;
   }
   
   function AlertItem({ alert, onAcknowledge, onResolve }: AlertItemProps) {
     const getSeverityColor = (severity: string) => {
       switch (severity) {
         case 'critical':
           return 'border-red-500 bg-red-50 text-red-800';
         case 'high':
           return 'border-orange-500 bg-orange-50 text-orange-800';
         case 'medium':
           return 'border-yellow-500 bg-yellow-50 text-yellow-800';
         case 'low':
           return 'border-blue-500 bg-blue-50 text-blue-800';
         default:
           return 'border-gray-500 bg-gray-50 text-gray-800';
       }
     };
     
     return (
       <div className={`border-l-4 p-4 rounded-r ${getSeverityColor(alert.severity)}`}>
         <div className="flex items-start justify-between">
           <div className="space-y-1">
             <h4 className="font-medium">{alert.title}</h4>
             <p className="text-sm">{alert.message}</p>
             <div className="flex items-center gap-4 text-xs">
               <span>Triggered {new Date(alert.triggered_at).toLocaleString()}</span>
               <Badge variant="outline" className="text-xs">
                 {alert.severity}
               </Badge>
               <Badge variant="secondary" className="text-xs">
                 {alert.status}
               </Badge>
             </div>
           </div>
           
           <div className="flex items-center gap-2">
             {alert.status === 'active' && (
               <>
                 <Button
                   variant="outline"
                   size="sm"
                   onClick={() => onAcknowledge(alert.id)}
                 >
                   Acknowledge
                 </Button>
                 <Button
                   variant="default"
                   size="sm"
                   onClick={() => onResolve(alert.id)}
                 >
                   Resolve
                 </Button>
               </>
             )}
             
             {alert.status === 'acknowledged' && (
               <Button
                 variant="default"
                 size="sm"
                 onClick={() => onResolve(alert.id)}
               >
                 Resolve
               </Button>
             )}
           </div>
         </div>
       </div>
     );
   }
   ```

**Files to Create:**
- `lib/services/alerts/alert-manager.ts`
- `components/platform/ai-management/unified/monitoring/AlertsPanel.tsx`
- `app/api/platform/ai-management/features/[id]/alerts/route.ts`

**Acceptance Criteria:**
- [ ] Alert rules can be configured per feature
- [ ] Real-time alert evaluation based on metrics
- [ ] Alert acknowledgment and resolution workflow
- [ ] Visual severity indicators
- [ ] Alert history tracking

### Task 9.2: Integrate Real-time Updates Throughout Interface
**Duration:** 3 hours  
**Priority:** High  
**Complexity:** Medium

**Objective:** Connect real-time infrastructure to all UI components

**Implementation Steps:**
1. **Update UnifiedOverviewTab with real-time data:**
   ```typescript
   // Update components/platform/ai-management/unified/UnifiedOverviewTab.tsx
   export function UnifiedOverviewTab({
     organizationId,
     timeRange = '24h',
     autoRefresh = true,
     refreshInterval = 30000,
     feature,
   }: UnifiedOverviewTabProps) {
     const { metrics, lastUpdated, isConnected } = useRealTimeMetrics(
       feature?.id || '',
       autoRefresh
     );
     const [alerts, setAlerts] = useState<Alert[]>([]);
     
     // Update alerts when metrics change
     useEffect(() => {
       if (metrics && feature?.id) {
         const newAlerts = alertManager.checkMetricsForAlerts(feature.id, metrics);
         if (newAlerts.length > 0) {
           setAlerts(prev => [...prev, ...newAlerts]);
         }
       }
     }, [metrics, feature?.id]);
     
     return (
       <div className="space-y-6">
         {/* Connection Status */}
         <div className="flex items-center justify-between">
           <div className="flex items-center gap-2">
             <div className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`} />
             <span className="text-sm text-muted-foreground">
               {isConnected ? 'Live updates active' : 'Disconnected'}
               {lastUpdated && ` • Last updated ${formatTimeAgo(lastUpdated)}`}
             </span>
           </div>
         </div>
         
         {/* Feature Context with Real-time Metrics */}
         {feature && (
           <FeatureContextCard
             feature={{
               ...feature,
               metrics: metrics?.metrics || feature.metrics
             }}
             showConfigurationSummary={true}
             onQuickEdit={() => setActiveTab('settings')}
           />
         )}
         
         {/* Alerts Panel */}
         <AlertsPanel
           featureId={feature?.id || ''}
           alerts={alerts}
           onAcknowledge={(alertId) => alertManager.acknowledgeAlert(alertId)}
           onResolve={(alertId) => alertManager.resolveAlert(alertId)}
         />
         
         {/* Quick Health Summary with Real-time Data */}
         {feature && (
           <QuickHealthSummary
             feature={{
               ...feature,
               metrics: metrics?.metrics || feature.metrics,
               health_indicators: metrics?.health_status ? {
                 status: metrics.health_status,
                 alerts_count: alerts.filter(a => a.status === 'active').length,
                 last_error: alerts.find(a => a.severity === 'critical')?.message
               } : feature.health_indicators
             }}
             autoRefresh={autoRefresh}
             refreshInterval={refreshInterval}
             onViewLogs={() => setLogsDrawerOpen(true)}
           />
         )}
         
         {/* Integrated FeatureDashboard */}
         {feature && (
           <div className="border-t pt-6">
             <div className="mb-4">
               <h3 className="text-lg font-semibold">Performance Dashboard</h3>
               <p className="text-sm text-muted-foreground">
                 Real-time metrics and performance analytics
               </p>
             </div>
             <FeatureDashboard featureId={feature.id} />
           </div>
         )}
       </div>
     );
   }
   ```

2. **Update QuickHealthSummary with real-time alerts:**
   ```typescript
   // Update components/platform/ai-management/unified/QuickHealthSummary.tsx
   export function QuickHealthSummary({ feature, autoRefresh, refreshInterval, onViewLogs }: QuickHealthSummaryProps) {
     const { metrics, isConnected } = useRealTimeMetrics(feature.id, autoRefresh);
     const [alerts, setAlerts] = useState<Alert[]>([]);
     
     // Subscribe to real-time alerts
     useEffect(() => {
       if (!isConnected) return;
       
       const unsubscribe = subscribe('alert_triggered', (alert: Alert) => {
         if (alert.featureId === feature.id) {
           setAlerts(prev => [...prev, alert]);
           toast.error(`Alert: ${alert.title}`);
         }
       });
       
       return unsubscribe;
     }, [isConnected, feature.id]);
     
     const currentMetrics = metrics?.metrics || feature.metrics;
     const activeAlerts = alerts.filter(a => a.status === 'active');
     
     return (
       <Card>
         <CardHeader>
           <CardTitle className="flex items-center justify-between">
             <span className="flex items-center gap-2">
               {getHealthIcon(feature.health_indicators?.status)}
               System Health
               {isConnected && (
                 <Badge variant="secondary" className="text-xs">
                   Live
                 </Badge>
               )}
             </span>
             <div className="flex items-center gap-2 text-sm text-muted-foreground">
               <Clock className="h-4 w-4" />
               Updated {formatTimeAgo(lastUpdated)}
               {onViewLogs && (
                 <Button variant="outline" size="sm" onClick={onViewLogs}>
                   View Logs
                 </Button>
               )}
             </div>
           </CardTitle>
         </CardHeader>
         <CardContent>
           <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
             <HealthMetric
               label="Uptime"
               value={`${currentMetrics.uptime.toFixed(1)}%`}
               status={currentMetrics.uptime > 99 ? 'good' : 'warning'}
               isRealTime={isConnected}
             />
             <HealthMetric
               label="Success Rate"
               value={`${currentMetrics.success_rate.toFixed(1)}%`}
               status={currentMetrics.success_rate > 95 ? 'good' : 'warning'}
               isRealTime={isConnected}
             />
             <HealthMetric
               label="Error Rate"
               value={`${currentMetrics.error_rate.toFixed(2)}%`}
               status={currentMetrics.error_rate < 1 ? 'good' : 'error'}
               isRealTime={isConnected}
             />
             <HealthMetric
               label="Response Time"
               value={`${currentMetrics.response_time.toFixed(0)}ms`}
               status={currentMetrics.response_time < 500 ? 'good' : 'warning'}
               isRealTime={isConnected}
             />
           </div>
           
           {activeAlerts.length > 0 && (
             <Alert className="mt-4" variant="destructive">
               <AlertTriangle className="h-4 w-4" />
               <AlertDescription>
                 {activeAlerts.length} active alert(s) require attention
                 <div className="mt-1 text-sm">
                   Latest: {activeAlerts[0].message}
                 </div>
               </AlertDescription>
             </Alert>
           )}
         </CardContent>
       </Card>
     );
   }
   ```

**Files to Modify:**
- `components/platform/ai-management/unified/UnifiedOverviewTab.tsx`
- `components/platform/ai-management/unified/QuickHealthSummary.tsx`
- `components/platform/ai-management/unified/FeatureContextCard.tsx`

**Acceptance Criteria:**
- [ ] All components receive real-time metric updates
- [ ] Alert system integrated with UI components
- [ ] Connection status visible throughout interface
- [ ] Real-time indicators show live vs cached data
- [ ] Performance remains acceptable with real-time updates

### Task 9.3: Performance Optimization and Caching
**Duration:** 2 hours  
**Priority:** Medium  
**Complexity:** Medium

**Objective:** Optimize real-time performance and implement intelligent caching

**Implementation Steps:**
1. **Implement metrics caching and throttling:**
   ```typescript
   // lib/performance/metrics-cache.ts
   export class MetricsCache {
     private cache: Map<string, { data: any; timestamp: number; ttl: number }> = new Map();
     private updateQueue: Map<string, NodeJS.Timeout> = new Map();
     
     public get(key: string): any | null {
       const entry = this.cache.get(key);
       if (!entry) return null;
       
       if (Date.now() - entry.timestamp > entry.ttl) {
         this.cache.delete(key);
         return null;
       }
       
       return entry.data;
     }
     
     public set(key: string, data: any, ttl: number = 30000): void {
       this.cache.set(key, {
         data,
         timestamp: Date.now(),
         ttl
       });
       
       // Schedule cleanup
       setTimeout(() => {
         if (this.cache.get(key)?.timestamp === this.cache.get(key)?.timestamp) {
           this.cache.delete(key);
         }
       }, ttl);
     }
     
     public throttledUpdate(key: string, updateFn: () => Promise<any>, delay: number = 1000): void {
       // Clear existing timeout
       const existingTimeout = this.updateQueue.get(key);
       if (existingTimeout) {
         clearTimeout(existingTimeout);
       }
       
       // Set new timeout
       const timeout = setTimeout(async () => {
         try {
           const data = await updateFn();
           this.set(key, data);
         } catch (error) {
           console.error('Throttled update failed:', error);
         } finally {
           this.updateQueue.delete(key);
         }
       }, delay);
       
       this.updateQueue.set(key, timeout);
     }
     
     public clear(): void {
       this.cache.clear();
       this.updateQueue.forEach(timeout => clearTimeout(timeout));
       this.updateQueue.clear();
     }
   }
   
   export const metricsCache = new MetricsCache();
   ```

2. **Optimize WebSocket message handling:**
   ```typescript
   // lib/websocket/message-throttler.ts
   export class MessageThrottler {
     private messageQueue: Map<string, any[]> = new Map();
     private flushTimers: Map<string, NodeJS.Timeout> = new Map();
     
     public throttleMessage(type: string, data: any, flushDelay: number = 100): void {
       // Add message to queue
       if (!this.messageQueue.has(type)) {
         this.messageQueue.set(type, []);
       }
       this.messageQueue.get(type)!.push(data);
       
       // Clear existing timer
       const existingTimer = this.flushTimers.get(type);
       if (existingTimer) {
         clearTimeout(existingTimer);
       }
       
       // Set new timer to flush messages
       const timer = setTimeout(() => {
         this.flushMessages(type);
       }, flushDelay);
       
       this.flushTimers.set(type, timer);
     }
     
     private flushMessages(type: string): void {
       const messages = this.messageQueue.get(type);
       if (messages && messages.length > 0) {
         // Process batched messages
         this.processBatchedMessages(type, messages);
         this.messageQueue.set(type, []);
       }
       this.flushTimers.delete(type);
     }
     
     private processBatchedMessages(type: string, messages: any[]): void {
       switch (type) {
         case 'metrics_update':
           // Take only the latest metrics update
           const latestMetrics = messages[messages.length - 1];
           this.handleMetricsUpdate(latestMetrics);
           break;
         case 'log_entry':
           // Process all log entries
           messages.forEach(log => this.handleLogEntry(log));
           break;
         default:
           console.warn('Unknown message type for batching:', type);
       }
     }
   }
   ```

**Files to Create:**
- `lib/performance/metrics-cache.ts`
- `lib/websocket/message-throttler.ts`

**Acceptance Criteria:**
- [ ] Metrics updates throttled to prevent UI thrashing
- [ ] Intelligent caching reduces unnecessary API calls
- [ ] WebSocket message batching for high-frequency updates
- [ ] Memory usage remains stable during long sessions
- [ ] UI remains responsive during heavy real-time activity

---

## Integration and Testing

### WebSocket Infrastructure Testing
```bash
# Test WebSocket connections
npm test -- --testPathPattern="websocket.*test"

# Test real-time metrics
npm test -- --testPathPattern="real-time.*test"

# Test alert system
npm test -- --testPathPattern="alert.*test"
```

### Performance Testing
```bash
# Load test with multiple WebSocket connections
npm run test:load -- --connections=50 --duration=300s

# Memory leak testing
npm run test:memory -- --duration=3600s

# Real-time update performance
npm run test:realtime -- --update-frequency=1s
```

### Manual Testing Checklist
- [ ] WebSocket connection/reconnection works reliably
- [ ] Real-time metrics update correctly in all components
- [ ] Log streaming works without dropped messages
- [ ] Alert system triggers and resolves correctly
- [ ] Drawer interface slides smoothly and maintains state
- [ ] Performance remains acceptable with multiple features
- [ ] Fallback to SSE works when WebSocket blocked
- [ ] Memory usage stable during extended sessions

---

## Handoff Requirements

### Documentation for Next Phase
1. **Real-time Architecture:**
   - WebSocket server configuration and scaling
   - Message routing and subscription patterns
   - Performance characteristics and limitations

2. **Monitoring Infrastructure:**
   - Alert rule configuration and management
   - Log aggregation and retention policies
   - Metrics collection and caching strategies

3. **UI Integration Patterns:**
   - Real-time data binding patterns
   - Error handling and connection management
   - Performance optimization techniques

### Files Created Summary
**WebSocket Infrastructure:**
- `lib/websocket/websocket-server.ts`
- `lib/websocket/websocket-client.ts`
- `app/api/platform/ai-management/websocket/route.ts`

**Real-time Services:**
- `lib/services/metrics/real-time-metrics-service.ts`
- `lib/services/logging/log-streaming-service.ts`
- `lib/services/alerts/alert-manager.ts`

**UI Components:**
- `components/platform/ai-management/unified/monitoring/LogsDrawer.tsx`
- `components/platform/ai-management/unified/monitoring/AlertsPanel.tsx`
- `hooks/useRealTimeMetrics.ts`

**Performance Optimizations:**
- `lib/performance/metrics-cache.ts`
- `lib/websocket/message-throttler.ts`

### Success Criteria for Phase 3
- [ ] Real-time metrics update across all interface components
- [ ] Log streaming functional with filtering and search
- [ ] Alert system triggers and manages alerts correctly
- [ ] WebSocket connections reliable with automatic reconnection
- [ ] Drawer interface provides seamless log access
- [ ] Performance acceptable with real-time features enabled
- [ ] SSE fallback works in restricted environments
- [ ] Memory usage stable during extended real-time sessions

**Phase 3 Completion enables:**
- Phase 4 production polish and comprehensive testing
- Advanced analytics and monitoring dashboards
- Integration with external monitoring systems
- Multi-user real-time collaboration features