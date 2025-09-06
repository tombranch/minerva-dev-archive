# Common Patterns & Solutions for TypeScript Cleanup

## Overview
This document provides reusable solutions for the most common `any` type patterns found throughout the Minerva codebase. Use these patterns to consistently fix similar issues across all phases.

## Git Commit Patterns for All Phases

### Frequent Commits with --no-verify Flag
```bash
# Start of each phase
git add . && git commit --no-verify -m "Phase N start: [brief description]"

# After fixing each file
git add [filename] && git commit --no-verify -m "Phase N: Fix [type of issue] in [filename]"

# After completing each directory
git add [directory]/ && git commit --no-verify -m "Phase N: COMPLETE - [directory] fixed"

# Progress checkpoints every 1-2 hours
git add . && git commit --no-verify -m "Phase N checkpoint: [summary of progress]"

# End of each phase  
git add . && git commit --no-verify -m "Phase N COMPLETE: [summary of phase achievements]"
```

## API Route Patterns

### Pattern 1: Request Handler Parameters
```typescript
// ❌ Before (common in 100+ files)
export async function GET(request: any) {
export async function POST(request: any, context: any) {

// ✅ After
import { NextRequest } from 'next/server';

export async function GET(request: NextRequest) {
export async function POST(
  request: NextRequest, 
  context: { params: Record<string, string> }
) {
```

### Pattern 2: API Response Data
```typescript
// ❌ Before
const responseData: any = {
  results: data,
  pagination: paginationInfo
};

// ✅ After
interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    hasMore: boolean;
  };
}

const responseData: ApiResponse<YourDataType[]> = {
  success: true,
  data: results,
  pagination: paginationInfo
};
```

## Database Query Patterns

### Pattern 1: Supabase Query Results
```typescript
// ❌ Before (80+ instances)
const { data: rows }: any = await supabase.from('table').select('*');
const result: any = await supabase.from('ai_jobs').select('*').eq('id', id);

// ✅ After - Use generated types
import { Database } from '@/lib/database.types';

type AIJob = Database['public']['Tables']['ai_processing_jobs']['Row'];
type AIJobInsert = Database['public']['Tables']['ai_processing_jobs']['Insert'];

const { data: rows }: { data: AIJob[] | null } = 
  await supabase.from('ai_processing_jobs').select('*');

const { data: result }: { data: AIJob | null } = 
  await supabase.from('ai_processing_jobs').select('*').eq('id', id).single();
```

### Pattern 2: Database Operations
```typescript
// ❌ Before
const insertData: any = { name, description, settings };
const updateData: any = { ...changes, updated_at: new Date().toISOString() };

// ✅ After
type TableInsert = Database['public']['Tables']['your_table']['Insert'];
type TableUpdate = Database['public']['Tables']['your_table']['Update'];

const insertData: TableInsert = { name, description, settings };
const updateData: TableUpdate = { 
  ...changes, 
  updated_at: new Date().toISOString() 
};
```

## Analytics & Metrics Patterns

### Pattern 1: Analytics Results
```typescript
// ❌ Before (150+ instances in analytics/)
const metrics: any = calculateMetrics(data);
const analysisResult: any = await processAnalytics(input);

// ✅ After - Create specific interfaces
interface ProcessingMetrics {
  totalJobs: number;
  successRate: number;
  averageLatency: number;
  errorRate: number;
  throughput: number;
  timeRange: {
    start: string;
    end: string;
  };
}

interface AnalyticsResult {
  accuracy: {
    overall: number;
    byProvider: Record<string, number>;
    trend: 'improving' | 'declining' | 'stable';
  };
  performance: ProcessingMetrics;
  costs: {
    total: number;
    perJob: number;
    byProvider: Record<string, number>;
  };
}

const metrics: ProcessingMetrics = calculateMetrics(data);
const analysisResult: AnalyticsResult = await processAnalytics(input);
```

### Pattern 2: Time Series Data
```typescript
// ❌ Before
const timeSeriesData: any[] = data.map((point: any) => ({
  timestamp: point.time,
  value: point.val,
  metadata: point.meta
}));

// ✅ After
interface TimeSeriesPoint<T = number> {
  timestamp: string;
  value: T;
  metadata?: Record<string, unknown>;
}

interface MetricsPoint {
  accuracy: number;
  latency: number;
  cost: number;
}

const timeSeriesData: TimeSeriesPoint<MetricsPoint>[] = data.map(point => ({
  timestamp: point.time,
  value: {
    accuracy: point.accuracy,
    latency: point.latency,
    cost: point.cost
  },
  metadata: point.meta
}));
```

## AI Processing Patterns

### Pattern 1: AI Job Results
```typescript
// ❌ Before (100+ instances in ai/ directory)
const jobResult: any = await processAI(input);
const aiResponse: any = await callProvider(prompt);

// ✅ After
interface AIJobResult {
  jobId: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  result?: {
    tags: string[];
    confidence: number;
    processingTime: number;
    model: string;
    provider: string;
  };
  error?: {
    code: string;
    message: string;
    retryable: boolean;
  };
  metadata: {
    startedAt: string;
    completedAt?: string;
    retryCount: number;
  };
}

const jobResult: AIJobResult = await processAI(input);
```

### Pattern 2: Provider Responses
```typescript
// ❌ Before
const providerResponse: any = await aiProvider.analyze(image);

// ✅ After
interface AIProviderResponse {
  success: boolean;
  data?: {
    labels: Array<{
      name: string;
      confidence: number;
      category: 'machine' | 'hazard' | 'control' | 'component';
    }>;
    processingTime: number;
    model: string;
  };
  error?: {
    code: string;
    message: string;
    details?: Record<string, unknown>;
  };
  usage: {
    tokensUsed?: number;
    costUSD: number;
  };
}

const providerResponse: AIProviderResponse = await aiProvider.analyze(image);
```

## Testing & Validation Patterns

### Pattern 1: Test Results
```typescript
// ❌ Before (50+ instances in testing/)
const testResult: any = await runTest(config);
const validationResult: any = validateModel(model);

// ✅ After
interface TestResult {
  testId: string;
  success: boolean;
  metrics: {
    accuracy: number;
    precision: number;
    recall: number;
    f1Score: number;
  };
  performance: {
    latency: number;
    throughput: number;
  };
  errors: Array<{
    type: string;
    message: string;
    severity: 'low' | 'medium' | 'high';
  }>;
  metadata: {
    testType: 'accuracy' | 'performance' | 'load' | 'regression';
    duration: number;
    sampleSize: number;
  };
}

const testResult: TestResult = await runTest(config);
```

## Platform Management Patterns

### Pattern 1: Bulk Operations
```typescript
// ❌ Before (60+ instances in platform/)
const operation: any = {
  id: generateId(),
  type: 'bulk_update',
  status: 'pending',
  items: items
};

// ✅ After
type BulkOperationType = 
  | 'bulk_update' 
  | 'bulk_delete' 
  | 'bulk_export' 
  | 'bulk_import';

type OperationStatus = 
  | 'pending' 
  | 'processing' 
  | 'completed' 
  | 'failed' 
  | 'cancelled';

interface BulkOperation<T = unknown> {
  id: string;
  type: BulkOperationType;
  status: OperationStatus;
  items: T[];
  progress: {
    total: number;
    processed: number;
    successful: number;
    failed: number;
  };
  errors: Array<{
    itemId: string;
    error: string;
    retryable: boolean;
  }>;
  timing: {
    startedAt: string;
    completedAt?: string;
    estimatedCompletion?: string;
  };
}

const operation: BulkOperation<YourItemType> = {
  id: generateId(),
  type: 'bulk_update',
  status: 'pending',
  items: items,
  // ... other required properties
};
```

## Error Handling Patterns

### Pattern 1: Error Objects
```typescript
// ❌ Before
const error: any = { message: 'Something failed' };
catch (error: any) { }

// ✅ After
interface AppError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  timestamp: string;
  retryable: boolean;
  severity: 'low' | 'medium' | 'high' | 'critical';
}

const error: AppError = {
  code: 'AI_PROCESSING_FAILED',
  message: 'Image analysis failed due to timeout',
  details: { timeout: 30000, retryCount: 3 },
  timestamp: new Date().toISOString(),
  retryable: true,
  severity: 'medium'
};

// For catch blocks
catch (error: unknown) {
  if (error instanceof Error) {
    // Handle Error objects
  } else {
    // Handle other types
  }
}
```

## Utility Function Patterns

### Pattern 1: Data Transformation
```typescript
// ❌ Before
function transformData(input: any): any {
  return input.map((item: any) => ({
    id: item.id,
    name: item.name,
    processed: processItem(item)
  }));
}

// ✅ After
interface InputItem {
  id: string;
  name: string;
  rawData: unknown;
}

interface ProcessedItem {
  id: string;
  name: string;
  processed: {
    timestamp: string;
    result: unknown;
    metadata: Record<string, unknown>;
  };
}

function transformData(input: InputItem[]): ProcessedItem[] {
  return input.map(item => ({
    id: item.id,
    name: item.name,
    processed: processItem(item)
  }));
}
```

## Configuration Patterns

### Pattern 1: Settings and Config
```typescript
// ❌ Before
const config: any = {
  providers: providerConfig,
  limits: limitConfig,
  features: featureFlags
};

// ✅ After
interface AIProviderConfig {
  name: string;
  endpoint: string;
  apiKey: string;
  timeout: number;
  retryConfig: {
    maxRetries: number;
    backoffMs: number;
  };
}

interface SystemConfig {
  providers: AIProviderConfig[];
  limits: {
    maxJobsPerHour: number;
    maxConcurrentJobs: number;
    timeoutMs: number;
  };
  features: {
    analytics: boolean;
    bulkOperations: boolean;
    advancedMetrics: boolean;
  };
}

const config: SystemConfig = {
  providers: providerConfig,
  limits: limitConfig,
  features: featureFlags
};
```

## Type Organization Strategy

### Create Shared Type Files
```typescript
// lib/types/api.ts
export interface ApiResponse<T = unknown> { }
export interface PaginationParams { }
export interface SortParams { }

// lib/types/ai/index.ts  
export interface AIJob { }
export interface AIProvider { }
export interface AIResult { }

// lib/types/platform/index.ts
export interface PlatformUser { }
export interface Organization { }
export interface BulkOperation<T> { }

// lib/types/analytics/index.ts
export interface MetricsData { }
export interface AnalyticsResult { }
export interface TimeSeriesPoint<T> { }
```

### Import and Usage
```typescript
// In your files
import { 
  ApiResponse, 
  PaginationParams 
} from '@/lib/types/api';

import { 
  AIJob, 
  AIResult 
} from '@/lib/types/ai';

import { 
  MetricsData,
  TimeSeriesPoint 
} from '@/lib/types/analytics';
```

## Validation Helpers

### Quick Type Checking Commands
```bash
# Check for remaining any types in specific directory
npx eslint ./app/api/ai/analytics/ | grep -c "any.*Specify a different type"

# Check TypeScript compilation for specific files
npx tsc --noEmit path/to/file.ts

# Full project any type count
npx eslint . | grep -c "any.*Specify a different type"
```

### Type Safety Verification
```typescript
// Add type assertions in development to catch issues
function processResult(result: unknown): ProcessedResult {
  // Runtime type checking in development
  if (process.env.NODE_ENV === 'development') {
    console.assert(typeof result === 'object' && result !== null);
    console.assert('id' in result && 'status' in result);
  }
  
  return result as ProcessedResult;
}
```

This pattern reference should cover 80%+ of the `any` type patterns in the Minerva codebase. Use these solutions consistently across all phases for maximum efficiency and code quality.