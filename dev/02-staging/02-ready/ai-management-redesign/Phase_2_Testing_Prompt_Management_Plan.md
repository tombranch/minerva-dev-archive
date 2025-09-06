# Phase 2: Testing & Prompt Management Plan
## AI Features Management Interface Redesign - Days 4-6

**Phase Duration:** 3 Days  
**Focus:** Build testing infrastructure and integrate prompt management  
**Risk Level:** Medium (new infrastructure required)  
**Team:** 1 Senior Frontend Developer + 1 Backend Developer

---

## Phase Overview

Phase 2 introduces new testing capabilities and integrates existing prompt management functionality into the unified interface. This phase requires building new infrastructure for embedded testing while leveraging existing prompt library components.

**Key Dependencies from Phase 1:**
- ✅ Unified interface foundation
- ✅ ConsolidatedSettingsTab with tabbed structure
- ✅ Existing API patterns and state management

**New Infrastructure Required:**
- 🔧 Testing service architecture with sandboxing
- 🔧 Test result persistence and history
- 🔧 Prompt management integration from existing library

---

## Day 4: Testing Service Architecture

### Task 4.1: Design Testing Service Infrastructure
**Duration:** 4 hours  
**Priority:** High  
**Complexity:** High

**Objective:** Create the backend testing service that can safely execute AI model and prompt tests

**Implementation Steps:**
1. **Create testing service API endpoints:**
   ```typescript
   // lib/services/ai-testing/testing-service.ts
   export interface TestInput {
     type: 'model' | 'prompt';
     content: string | File;
     variables?: Record<string, any>;
     modelId?: string;
     promptId?: string;
     environment?: 'development' | 'staging' | 'production';
   }
   
   export interface TestResult {
     id: string;
     featureId: string;
     testType: 'model' | 'prompt';
     input: TestInput;
     output: {
       response: any;
       confidence?: number;
       processingTime: number;
       cost: number;
       metadata: Record<string, any>;
     };
     timestamp: Date;
     status: 'success' | 'error' | 'timeout';
     error?: string;
   }
   
   export class AITestingService {
     async executeTest(featureId: string, input: TestInput): Promise<TestResult> {
       // Create sandbox environment
       const sandboxId = await this.createSandbox();
       
       try {
         // Execute test in sandbox
         const result = await this.executeSafeTest(sandboxId, input);
         
         // Save result to database
         await this.saveTestResult(featureId, result);
         
         return result;
       } finally {
         // Always clean up sandbox
         await this.destroySandbox(sandboxId);
       }
     }
     
     private async createSandbox(): Promise<string> {
       // Create isolated execution environment
       // Set resource limits (memory, CPU, time)
       // Configure network restrictions
       return `sandbox-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
     }
     
     private async executeSafeTest(sandboxId: string, input: TestInput): Promise<TestResult> {
       // Input validation and sanitization
       this.validateTestInput(input);
       
       // Execute with timeout and resource limits
       const startTime = Date.now();
       const result = await Promise.race([
         this.executeTestLogic(input),
         this.createTimeoutPromise(30000) // 30 second timeout
       ]);
       
       return {
         ...result,
         processingTime: Date.now() - startTime
       };
     }
   }
   ```

2. **Create API routes for testing:**
   ```typescript
   // app/api/platform/ai-management/features/[id]/test/route.ts
   import { AITestingService } from '@/lib/services/ai-testing/testing-service';
   
   export async function POST(
     request: Request,
     { params }: { params: { id: string } }
   ) {
     try {
       const { type, content, variables, modelId, promptId } = await request.json();
       
       const testingService = new AITestingService();
       const result = await testingService.executeTest(params.id, {
         type,
         content,
         variables,
         modelId,
         promptId
       });
       
       return Response.json({ success: true, data: result });
     } catch (error) {
       console.error('Test execution failed:', error);
       return Response.json(
         { success: false, error: error.message },
         { status: 500 }
       );
     }
   }
   
   export async function GET(
     request: Request,
     { params }: { params: { id: string } }
   ) {
     try {
       // Get test history for feature
       const testingService = new AITestingService();
       const history = await testingService.getTestHistory(params.id);
       
       return Response.json({ success: true, data: history });
     } catch (error) {
       return Response.json(
         { success: false, error: error.message },
         { status: 500 }
       );
     }
   }
   ```

3. **Create database schema for test results:**
   ```sql
   -- Database migration for test results
   CREATE TABLE ai_test_results (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     feature_id UUID REFERENCES platform_ai_features(id),
     test_type TEXT NOT NULL CHECK (test_type IN ('model', 'prompt')),
     input_data JSONB NOT NULL,
     output_data JSONB NOT NULL,
     processing_time_ms INTEGER NOT NULL,
     cost_usd DECIMAL(10, 6),
     status TEXT NOT NULL CHECK (status IN ('success', 'error', 'timeout')),
     error_message TEXT,
     created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
     created_by UUID REFERENCES auth.users(id)
   );
   
   CREATE INDEX idx_ai_test_results_feature_id ON ai_test_results(feature_id);
   CREATE INDEX idx_ai_test_results_created_at ON ai_test_results(created_at);
   ```

**Files to Create:**
- `lib/services/ai-testing/testing-service.ts`
- `app/api/platform/ai-management/features/[id]/test/route.ts`
- `app/api/platform/ai-management/features/[id]/test/history/route.ts`
- Database migration file

**Acceptance Criteria:**
- [ ] Testing service can execute model tests safely
- [ ] Sandbox environment isolates test execution
- [ ] Test results are persisted with full metadata
- [ ] API endpoints handle errors gracefully
- [ ] Resource limits prevent runaway tests

### Task 4.2: Implement Model Testing Integration
**Duration:** 3 hours  
**Priority:** High  
**Complexity:** Medium

**Objective:** Integrate model testing capabilities with existing FeatureModelAssignment

**Implementation Steps:**
1. **Enhance ModelAssignmentSection with testing:**
   ```typescript
   // components/platform/ai-management/unified/sections/ModelAssignmentSection.tsx
   import { useState } from 'react';
   import { useMutation } from '@tanstack/react-query';
   import { FeatureModelAssignment } from '../../features/FeatureModelAssignment';
   import { ModelTestingInterface } from '../testing/ModelTestingInterface';
   
   interface ModelAssignmentSectionProps {
     featureId: string;
   }
   
   export function ModelAssignmentSection({ featureId }: ModelAssignmentSectionProps) {
     const [showTesting, setShowTesting] = useState(false);
     const [selectedModelId, setSelectedModelId] = useState<string>('');
     
     return (
       <div className="space-y-6">
         {/* Existing FeatureModelAssignment component */}
         <FeatureModelAssignment 
           featureId={featureId}
           onModelSelect={setSelectedModelId}
         />
         
         {/* Testing Interface */}
         <Card>
           <CardHeader>
             <div className="flex items-center justify-between">
               <div>
                 <CardTitle>Model Testing</CardTitle>
                 <CardDescription>
                   Test the currently assigned model with sample inputs
                 </CardDescription>
               </div>
               <Button
                 variant="outline"
                 onClick={() => setShowTesting(!showTesting)}
               >
                 <TestTube className="h-4 w-4 mr-2" />
                 {showTesting ? 'Hide Testing' : 'Test Model'}
               </Button>
             </div>
           </CardHeader>
           
           {showTesting && (
             <CardContent>
               <ModelTestingInterface
                 featureId={featureId}
                 modelId={selectedModelId}
                 onTestComplete={(result) => {
                   toast.success('Test completed successfully');
                   // Optionally show results in modal
                 }}
               />
             </CardContent>
           )}
         </Card>
       </div>
     );
   }
   ```

2. **Create ModelTestingInterface component:**
   ```typescript
   // components/platform/ai-management/unified/testing/ModelTestingInterface.tsx
   interface ModelTestingInterfaceProps {
     featureId: string;
     modelId: string;
     onTestComplete?: (result: TestResult) => void;
   }
   
   export function ModelTestingInterface({
     featureId,
     modelId,
     onTestComplete
   }: ModelTestingInterfaceProps) {
     const [testInput, setTestInput] = useState<string>('');
     const [testFile, setTestFile] = useState<File | null>(null);
     const [isExpanded, setIsExpanded] = useState(false);
     
     const testModelMutation = useMutation({
       mutationFn: async (input: TestInput) => {
         const response = await fetch(`/api/platform/ai-management/features/${featureId}/test`, {
           method: 'POST',
           headers: { 'Content-Type': 'application/json' },
           body: JSON.stringify({
             type: 'model',
             content: input.content,
             modelId
           })
         });
         
         if (!response.ok) throw new Error('Test failed');
         return response.json();
       },
       onSuccess: (data) => {
         onTestComplete?.(data.data);
         setIsExpanded(true);
       }
     });
     
     const handleTest = () => {
       if (!testInput && !testFile) {
         toast.error('Please provide test input');
         return;
       }
       
       testModelMutation.mutate({
         content: testFile || testInput,
         modelId
       });
     };
     
     return (
       <div className="space-y-4">
         {/* Test Input Section */}
         <div className="space-y-4">
           <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
             {/* Text Input */}
             <div className="space-y-2">
               <Label htmlFor="test-text">Text Input</Label>
               <Textarea
                 id="test-text"
                 placeholder="Enter text for model testing..."
                 value={testInput}
                 onChange={(e) => setTestInput(e.target.value)}
                 rows={4}
               />
             </div>
             
             {/* File Upload for Vision Models */}
             <div className="space-y-2">
               <Label htmlFor="test-file">Image Upload</Label>
               <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center">
                 <input
                   id="test-file"
                   type="file"
                   accept="image/*"
                   onChange={(e) => setTestFile(e.target.files?.[0] || null)}
                   className="hidden"
                 />
                 <Button
                   variant="outline"
                   onClick={() => document.getElementById('test-file')?.click()}
                 >
                   <Upload className="h-4 w-4 mr-2" />
                   Upload Image
                 </Button>
                 {testFile && (
                   <p className="mt-2 text-sm text-muted-foreground">
                     Selected: {testFile.name}
                   </p>
                 )}
               </div>
             </div>
           </div>
           
           <div className="flex justify-end">
             <Button
               onClick={handleTest}
               disabled={testModelMutation.isPending || (!testInput && !testFile)}
             >
               {testModelMutation.isPending ? (
                 <>
                   <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                   Testing...
                 </>
               ) : (
                 <>
                   <Play className="h-4 w-4 mr-2" />
                   Run Test
                 </>
               )}
             </Button>
           </div>
         </div>
         
         {/* Test Results */}
         {testModelMutation.data && (
           <TestResultsDisplay
             result={testModelMutation.data.data}
             isExpanded={isExpanded}
             onToggleExpanded={() => setIsExpanded(!isExpanded)}
           />
         )}
         
         {testModelMutation.error && (
           <Alert variant="destructive">
             <AlertTriangle className="h-4 w-4" />
             <AlertDescription>
               Test failed: {testModelMutation.error.message}
             </AlertDescription>
           </Alert>
         )}
       </div>
     );
   }
   ```

**Files to Create:**
- `components/platform/ai-management/unified/sections/ModelAssignmentSection.tsx`
- `components/platform/ai-management/unified/testing/ModelTestingInterface.tsx`

**Acceptance Criteria:**
- [ ] "Test Model" button embedded within model assignment section
- [ ] Support for both text and image input testing
- [ ] Real-time test execution with loading states
- [ ] Expandable test results with detailed output
- [ ] Error handling for failed tests

### Task 4.3: Create Test Results Display Component
**Duration:** 1 hour  
**Priority:** Medium  
**Complexity:** Low

**Objective:** Create reusable component for displaying test results

**Implementation Steps:**
1. **Create TestResultsDisplay component:**
   ```typescript
   // components/platform/ai-management/unified/testing/TestResultsDisplay.tsx
   interface TestResultsDisplayProps {
     result: TestResult;
     isExpanded: boolean;
     onToggleExpanded: () => void;
   }
   
   export function TestResultsDisplay({
     result,
     isExpanded,
     onToggleExpanded
   }: TestResultsDisplayProps) {
     const formatJson = (obj: any) => {
       return JSON.stringify(obj, null, 2);
     };
     
     const getStatusColor = (status: string) => {
       switch (status) {
         case 'success': return 'text-green-600';
         case 'error': return 'text-red-600';
         case 'timeout': return 'text-yellow-600';
         default: return 'text-gray-600';
       }
     };
     
     return (
       <Card>
         <CardHeader>
           <div className="flex items-center justify-between">
             <CardTitle className="flex items-center gap-2">
               <div className={`w-2 h-2 rounded-full ${
                 result.status === 'success' ? 'bg-green-500' :
                 result.status === 'error' ? 'bg-red-500' : 'bg-yellow-500'
               }`} />
               Test Result
               <Badge variant="outline" className={getStatusColor(result.status)}>
                 {result.status}
               </Badge>
             </CardTitle>
             <Button variant="ghost" size="sm" onClick={onToggleExpanded}>
               {isExpanded ? (
                 <>
                   <ChevronUp className="h-4 w-4 mr-2" />
                   Collapse
                 </>
               ) : (
                 <>
                   <ChevronDown className="h-4 w-4 mr-2" />
                   Expand
                 </>
               )}
             </Button>
           </div>
         </CardHeader>
         
         <CardContent>
           {/* Summary Stats */}
           <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-4">
             <div className="text-center">
               <div className="text-2xl font-bold">{result.output.processingTime}ms</div>
               <div className="text-xs text-muted-foreground">Processing Time</div>
             </div>
             <div className="text-center">
               <div className="text-2xl font-bold">${result.output.cost.toFixed(4)}</div>
               <div className="text-xs text-muted-foreground">Cost</div>
             </div>
             {result.output.confidence && (
               <div className="text-center">
                 <div className="text-2xl font-bold">{(result.output.confidence * 100).toFixed(1)}%</div>
                 <div className="text-xs text-muted-foreground">Confidence</div>
               </div>
             )}
             <div className="text-center">
               <div className="text-2xl font-bold">{new Date(result.timestamp).toLocaleTimeString()}</div>
               <div className="text-xs text-muted-foreground">Timestamp</div>
             </div>
           </div>
           
           {/* Expanded Details */}
           {isExpanded && (
             <div className="space-y-4 border-t pt-4">
               <div>
                 <h4 className="font-medium mb-2">Response</h4>
                 <pre className="bg-gray-50 p-3 rounded text-sm overflow-auto max-h-48">
                   {formatJson(result.output.response)}
                 </pre>
               </div>
               
               {result.output.metadata && Object.keys(result.output.metadata).length > 0 && (
                 <div>
                   <h4 className="font-medium mb-2">Metadata</h4>
                   <pre className="bg-gray-50 p-3 rounded text-sm overflow-auto max-h-32">
                     {formatJson(result.output.metadata)}
                   </pre>
                 </div>
               )}
               
               {result.error && (
                 <div>
                   <h4 className="font-medium mb-2 text-red-600">Error Details</h4>
                   <pre className="bg-red-50 p-3 rounded text-sm text-red-700">
                     {result.error}
                   </pre>
                 </div>
               )}
             </div>
           )}
         </CardContent>
       </Card>
     );
   }
   ```

**Files to Create:**
- `components/platform/ai-management/unified/testing/TestResultsDisplay.tsx`

**Acceptance Criteria:**
- [ ] Summary stats display (processing time, cost, confidence, timestamp)
- [ ] Expandable detailed view with JSON response
- [ ] Status indicators with appropriate colors
- [ ] Error details display when test fails
- [ ] Responsive layout for different screen sizes

---

## Day 5: Prompt Management Integration

### Task 5.1: Analyze Existing Prompt Management Components
**Duration:** 2 hours  
**Priority:** High  
**Complexity:** Low

**Objective:** Understand existing prompt management infrastructure for integration

**Implementation Steps:**
1. **Examine existing prompt components:**
   ```bash
   # Find existing prompt management components
   find components -name "*prompt*" -o -name "*Prompt*"
   cat components/ai-management/PromptEditor.tsx
   ```

2. **Document existing APIs and patterns:**
   ```bash
   # Check existing prompt APIs
   find app/api -path "*prompt*" -type f
   ```

3. **Create integration strategy document:**
   ```markdown
   ## Prompt Management Integration Analysis
   
   ### Existing Components Found:
   - PromptEditor.tsx - Full-featured prompt editing interface
   - Prompt library APIs at /api/platform/ai-management/prompts
   - Existing validation and variable handling
   
   ### Integration Approach:
   - Embed PromptEditor within ConsolidatedSettingsTab
   - Maintain existing prompt library functionality
   - Add inline testing capabilities to prompt editor
   - Preserve existing version history and templates
   ```

**Files to Review:**
- `components/ai-management/PromptEditor.tsx`
- `app/api/platform/ai-management/prompts/route.ts`
- Existing prompt library components

**Acceptance Criteria:**
- [ ] Document existing prompt management capabilities
- [ ] Identify integration points for unified interface
- [ ] Note any API modifications needed
- [ ] Plan for maintaining existing functionality

### Task 5.2: Create Prompt Management Section
**Duration:** 4 hours  
**Priority:** High  
**Complexity:** Medium

**Objective:** Integrate existing prompt management into unified settings interface

**Implementation Steps:**
1. **Create PromptManagementSection component:**
   ```typescript
   // components/platform/ai-management/unified/sections/PromptManagementSection.tsx
   import { PromptEditor } from '@/components/ai-management/PromptEditor';
   import { useQuery, useMutation } from '@tanstack/react-query';
   
   interface PromptManagementSectionProps {
     featureId: string;
   }
   
   interface PromptData {
     id: string;
     name: string;
     content: string;
     variables: PromptVariable[];
     version: number;
     isActive: boolean;
     created_at: string;
     updated_at: string;
   }
   
   export function PromptManagementSection({ featureId }: PromptManagementSectionProps) {
     const [selectedPromptId, setSelectedPromptId] = useState<string | null>(null);
     const [showEditor, setShowEditor] = useState(false);
     const [showTesting, setShowTesting] = useState(false);
   
     // Fetch prompts for this feature
     const { data: prompts, isLoading } = useQuery({
       queryKey: ['feature-prompts', featureId],
       queryFn: async () => {
         const response = await fetch(
           `/api/platform/ai-management/prompts?feature_id=${featureId}&active_only=true`
         );
         if (!response.ok) throw new Error('Failed to fetch prompts');
         const result = await response.json();
         return result.data as PromptData[];
       },
     });
   
     // Fetch prompt templates
     const { data: templates } = useQuery({
       queryKey: ['prompt-templates'],
       queryFn: async () => {
         const response = await fetch('/api/platform/ai-management/prompts/templates');
         if (!response.ok) throw new Error('Failed to fetch templates');
         const result = await response.json();
         return result.data as PromptTemplate[];
       },
     });
     
     const selectedPrompt = prompts?.find(p => p.id === selectedPromptId);
   
     return (
       <div className="space-y-6">
         {/* Prompt List */}
         <Card>
           <CardHeader>
             <div className="flex items-center justify-between">
               <div>
                 <CardTitle>Active Prompts</CardTitle>
                 <CardDescription>
                   Manage prompts and templates for this feature
                 </CardDescription>
               </div>
               <Button onClick={() => setShowEditor(true)}>
                 <Plus className="h-4 w-4 mr-2" />
                 Create Prompt
               </Button>
             </div>
           </CardHeader>
           <CardContent>
             {isLoading ? (
               <PromptListSkeleton />
             ) : prompts && prompts.length > 0 ? (
               <div className="space-y-3">
                 {prompts.map((prompt) => (
                   <PromptListItem
                     key={prompt.id}
                     prompt={prompt}
                     isSelected={selectedPromptId === prompt.id}
                     onSelect={() => setSelectedPromptId(prompt.id)}
                     onEdit={() => {
                       setSelectedPromptId(prompt.id);
                       setShowEditor(true);
                     }}
                     onTest={() => {
                       setSelectedPromptId(prompt.id);
                       setShowTesting(true);
                     }}
                   />
                 ))}
               </div>
             ) : (
               <EmptyPromptState onCreateFirst={() => setShowEditor(true)} />
             )}
           </CardContent>
         </Card>
   
         {/* Inline Prompt Editor */}
         {showEditor && (
           <Card>
             <CardHeader>
               <div className="flex items-center justify-between">
                 <CardTitle>
                   {selectedPrompt ? 'Edit Prompt' : 'Create New Prompt'}
                 </CardTitle>
                 <Button
                   variant="ghost"
                   size="sm"
                   onClick={() => setShowEditor(false)}
                 >
                   <X className="h-4 w-4" />
                 </Button>
               </div>
             </CardHeader>
             <CardContent>
               <PromptEditor
                 prompt={selectedPrompt}
                 isOpen={showEditor}
                 onClose={() => setShowEditor(false)}
                 mode={selectedPrompt ? 'edit' : 'create'}
                 organizationId={undefined} // Will be inferred from context
               />
             </CardContent>
           </Card>
         )}
         
         {/* Prompt Testing Interface */}
         {showTesting && selectedPrompt && (
           <Card>
             <CardHeader>
               <div className="flex items-center justify-between">
                 <CardTitle>Test Prompt: {selectedPrompt.name}</CardTitle>
                 <Button
                   variant="ghost"
                   size="sm"
                   onClick={() => setShowTesting(false)}
                 >
                   <X className="h-4 w-4" />
                 </Button>
               </div>
             </CardHeader>
             <CardContent>
               <PromptTestingInterface
                 featureId={featureId}
                 promptId={selectedPrompt.id}
                 prompt={selectedPrompt}
                 onTestComplete={(result) => {
                   toast.success('Prompt test completed');
                 }}
               />
             </CardContent>
           </Card>
         )}
       </div>
     );
   }
   ```

2. **Create PromptListItem component:**
   ```typescript
   // components/platform/ai-management/unified/sections/PromptListItem.tsx
   interface PromptListItemProps {
     prompt: PromptData;
     isSelected: boolean;
     onSelect: () => void;
     onEdit: () => void;
     onTest: () => void;
   }
   
   export function PromptListItem({
     prompt,
     isSelected,
     onSelect,
     onEdit,
     onTest
   }: PromptListItemProps) {
     return (
       <div
         className={`p-4 border rounded-lg cursor-pointer transition-colors ${
           isSelected ? 'border-primary bg-primary/5' : 'hover:bg-gray-50'
         }`}
         onClick={onSelect}
       >
         <div className="flex items-start justify-between">
           <div className="space-y-1 flex-1">
             <div className="flex items-center gap-2">
               <h4 className="font-medium">{prompt.name}</h4>
               {prompt.isActive && (
                 <Badge variant="secondary" className="text-xs">
                   Active
                 </Badge>
               )}
               <Badge variant="outline" className="text-xs">
                 v{prompt.version}
               </Badge>
             </div>
             <p className="text-sm text-muted-foreground line-clamp-2">
               {prompt.content.substring(0, 100)}...
             </p>
             <div className="flex items-center gap-4 text-xs text-muted-foreground">
               <span>{prompt.variables.length} variables</span>
               <span>Updated {new Date(prompt.updated_at).toLocaleDateString()}</span>
             </div>
           </div>
           
           <div className="flex items-center gap-2 ml-4">
             <Button
               variant="ghost"
               size="sm"
               onClick={(e) => {
                 e.stopPropagation();
                 onTest();
               }}
             >
               <TestTube className="h-4 w-4" />
             </Button>
             <Button
               variant="ghost"
               size="sm"
               onClick={(e) => {
                 e.stopPropagation();
                 onEdit();
               }}
             >
               <Edit className="h-4 w-4" />
             </Button>
           </div>
         </div>
       </div>
     );
   }
   ```

**Files to Create:**
- `components/platform/ai-management/unified/sections/PromptManagementSection.tsx`
- `components/platform/ai-management/unified/sections/PromptListItem.tsx`

**Acceptance Criteria:**
- [ ] List of active prompts for the feature
- [ ] Inline prompt editor using existing PromptEditor component
- [ ] Create new prompt functionality
- [ ] Edit existing prompt functionality
- [ ] Integration maintains existing prompt library features

### Task 5.3: Create Prompt Testing Interface
**Duration:** 2 hours  
**Priority:** Medium  
**Complexity:** Medium

**Objective:** Add prompt testing capabilities similar to model testing

**Implementation Steps:**
1. **Create PromptTestingInterface component:**
   ```typescript
   // components/platform/ai-management/unified/testing/PromptTestingInterface.tsx
   interface PromptTestingInterfaceProps {
     featureId: string;
     promptId: string;
     prompt: PromptData;
     onTestComplete?: (result: TestResult) => void;
   }
   
   export function PromptTestingInterface({
     featureId,
     promptId,
     prompt,
     onTestComplete
   }: PromptTestingInterfaceProps) {
     const [variableValues, setVariableValues] = useState<Record<string, string>>({});
     const [isExpanded, setIsExpanded] = useState(false);
     
     const testPromptMutation = useMutation({
       mutationFn: async (variables: Record<string, string>) => {
         const response = await fetch(`/api/platform/ai-management/features/${featureId}/test`, {
           method: 'POST',
           headers: { 'Content-Type': 'application/json' },
           body: JSON.stringify({
             type: 'prompt',
             promptId,
             variables
           })
         });
         
         if (!response.ok) throw new Error('Prompt test failed');
         return response.json();
       },
       onSuccess: (data) => {
         onTestComplete?.(data.data);
         setIsExpanded(true);
       }
     });
   
     const handleTest = () => {
       // Validate required variables
       const missingVariables = prompt.variables
         .filter(v => v.required && !variableValues[v.name])
         .map(v => v.name);
       
       if (missingVariables.length > 0) {
         toast.error(`Missing required variables: ${missingVariables.join(', ')}`);
         return;
       }
       
       testPromptMutation.mutate(variableValues);
     };
   
     return (
       <div className="space-y-4">
         {/* Variable Inputs */}
         <div className="space-y-4">
           <h4 className="font-medium">Prompt Variables</h4>
           {prompt.variables.length > 0 ? (
             <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
               {prompt.variables.map((variable) => (
                 <div key={variable.name} className="space-y-2">
                   <Label htmlFor={variable.name}>
                     {variable.name}
                     {variable.required && <span className="text-red-500 ml-1">*</span>}
                   </Label>
                   <div className="space-y-1">
                     {variable.type === 'select' ? (
                       <Select
                         value={variableValues[variable.name] || ''}
                         onValueChange={(value) =>
                           setVariableValues(prev => ({ ...prev, [variable.name]: value }))
                         }
                       >
                         <SelectTrigger>
                           <SelectValue placeholder={`Select ${variable.name}`} />
                         </SelectTrigger>
                         <SelectContent>
                           {variable.options?.map((option) => (
                             <SelectItem key={option} value={option}>
                               {option}
                             </SelectItem>
                           ))}
                         </SelectContent>
                       </Select>
                     ) : variable.type === 'text' ? (
                       <Textarea
                         id={variable.name}
                         placeholder={variable.description || `Enter ${variable.name}`}
                         value={variableValues[variable.name] || variable.default || ''}
                         onChange={(e) =>
                           setVariableValues(prev => ({ ...prev, [variable.name]: e.target.value }))
                         }
                         rows={2}
                       />
                     ) : (
                       <Input
                         id={variable.name}
                         type={variable.type === 'number' ? 'number' : 'text'}
                         placeholder={variable.description || `Enter ${variable.name}`}
                         value={variableValues[variable.name] || variable.default || ''}
                         onChange={(e) =>
                           setVariableValues(prev => ({ ...prev, [variable.name]: e.target.value }))
                         }
                       />
                     )}
                     {variable.description && (
                       <p className="text-xs text-muted-foreground">{variable.description}</p>
                     )}
                   </div>
                 </div>
               ))}
             </div>
           ) : (
             <p className="text-sm text-muted-foreground">
               This prompt has no variables to configure.
             </p>
           )}
           
           <div className="flex justify-end">
             <Button
               onClick={handleTest}
               disabled={testPromptMutation.isPending}
             >
               {testPromptMutation.isPending ? (
                 <>
                   <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                   Testing Prompt...
                 </>
               ) : (
                 <>
                   <Play className="h-4 w-4 mr-2" />
                   Test Prompt
                 </>
               )}
             </Button>
           </div>
         </div>
         
         {/* Test Results */}
         {testPromptMutation.data && (
           <TestResultsDisplay
             result={testPromptMutation.data.data}
             isExpanded={isExpanded}
             onToggleExpanded={() => setIsExpanded(!isExpanded)}
           />
         )}
         
         {testPromptMutation.error && (
           <Alert variant="destructive">
             <AlertTriangle className="h-4 w-4" />
             <AlertDescription>
               Prompt test failed: {testPromptMutation.error.message}
             </AlertDescription>
           </Alert>
         )}
       </div>
     );
   }
   ```

**Files to Create:**
- `components/platform/ai-management/unified/testing/PromptTestingInterface.tsx`

**Acceptance Criteria:**
- [ ] Variable input forms with proper validation
- [ ] Support for different variable types (text, number, select)
- [ ] Required variable validation before test execution
- [ ] Test execution with variable substitution
- [ ] Results display using shared TestResultsDisplay component

---

## Day 6: Test History and Management

### Task 6.1: Create Test History Interface
**Duration:** 3 hours  
**Priority:** Medium  
**Complexity:** Medium

**Objective:** Provide interface for viewing and managing test history

**Implementation Steps:**
1. **Create TestHistorySection component:**
   ```typescript
   // components/platform/ai-management/unified/sections/TestHistorySection.tsx
   interface TestHistorySectionProps {
     featureId: string;
   }
   
   export function TestHistorySection({ featureId }: TestHistorySectionProps) {
     const [selectedTestIds, setSelectedTestIds] = useState<Set<string>>(new Set());
     const [filterType, setFilterType] = useState<'all' | 'model' | 'prompt'>('all');
     const [filterStatus, setFilterStatus] = useState<'all' | 'success' | 'error'>('all');
   
     const { data: testHistory, isLoading } = useQuery({
       queryKey: ['test-history', featureId, filterType, filterStatus],
       queryFn: async () => {
         const params = new URLSearchParams();
         if (filterType !== 'all') params.append('type', filterType);
         if (filterStatus !== 'all') params.append('status', filterStatus);
         
         const response = await fetch(
           `/api/platform/ai-management/features/${featureId}/test/history?${params}`
         );
         if (!response.ok) throw new Error('Failed to fetch test history');
         return response.json();
       }
     });
   
     const deleteTestsMutation = useMutation({
       mutationFn: async (testIds: string[]) => {
         const response = await fetch(
           `/api/platform/ai-management/features/${featureId}/test/batch-delete`,
           {
             method: 'DELETE',
             headers: { 'Content-Type': 'application/json' },
             body: JSON.stringify({ testIds })
           }
         );
         if (!response.ok) throw new Error('Failed to delete tests');
         return response.json();
       },
       onSuccess: () => {
         setSelectedTestIds(new Set());
         toast.success('Tests deleted successfully');
         // Refetch history
       }
     });
   
     return (
       <Card>
         <CardHeader>
           <div className="flex items-center justify-between">
             <div>
               <CardTitle>Test History</CardTitle>
               <CardDescription>
                 View and manage previous test executions
               </CardDescription>
             </div>
             
             <div className="flex items-center gap-2">
               {/* Filters */}
               <Select value={filterType} onValueChange={setFilterType}>
                 <SelectTrigger className="w-32">
                   <SelectValue />
                 </SelectTrigger>
                 <SelectContent>
                   <SelectItem value="all">All Types</SelectItem>
                   <SelectItem value="model">Model Tests</SelectItem>
                   <SelectItem value="prompt">Prompt Tests</SelectItem>
                 </SelectContent>
               </Select>
               
               <Select value={filterStatus} onValueChange={setFilterStatus}>
                 <SelectTrigger className="w-32">
                   <SelectValue />
                 </SelectTrigger>
                 <SelectContent>
                   <SelectItem value="all">All Status</SelectItem>
                   <SelectItem value="success">Success</SelectItem>
                   <SelectItem value="error">Error</SelectItem>
                 </SelectContent>
               </Select>
               
               {selectedTestIds.size > 0 && (
                 <Button
                   variant="destructive"
                   size="sm"
                   onClick={() => deleteTestsMutation.mutate(Array.from(selectedTestIds))}
                   disabled={deleteTestsMutation.isPending}
                 >
                   <Trash2 className="h-4 w-4 mr-2" />
                   Delete ({selectedTestIds.size})
                 </Button>
               )}
             </div>
           </div>
         </CardHeader>
         
         <CardContent>
           {isLoading ? (
             <TestHistorySkeleton />
           ) : testHistory?.data?.length > 0 ? (
             <div className="space-y-2">
               {testHistory.data.map((test: TestResult) => (
                 <TestHistoryItem
                   key={test.id}
                   test={test}
                   isSelected={selectedTestIds.has(test.id)}
                   onSelect={(selected) => {
                     const newSet = new Set(selectedTestIds);
                     if (selected) {
                       newSet.add(test.id);
                     } else {
                       newSet.delete(test.id);
                     }
                     setSelectedTestIds(newSet);
                   }}
                 />
               ))}
             </div>
           ) : (
             <div className="text-center py-8">
               <TestTube className="h-12 w-12 text-gray-400 mx-auto mb-4" />
               <h3 className="font-medium text-gray-900 mb-2">No Test History</h3>
               <p className="text-sm text-gray-600">
                 Run some tests to see results here
               </p>
             </div>
           )}
         </CardContent>
       </Card>
     );
   }
   ```

2. **Create TestHistoryItem component:**
   ```typescript
   // components/platform/ai-management/unified/sections/TestHistoryItem.tsx
   interface TestHistoryItemProps {
     test: TestResult;
     isSelected: boolean;
     onSelect: (selected: boolean) => void;
   }
   
   export function TestHistoryItem({ test, isSelected, onSelect }: TestHistoryItemProps) {
     const [showDetails, setShowDetails] = useState(false);
     
     return (
       <div className="border rounded-lg p-4 space-y-3">
         <div className="flex items-center justify-between">
           <div className="flex items-center gap-3">
             <Checkbox
               checked={isSelected}
               onCheckedChange={onSelect}
             />
             
             <div className="flex items-center gap-2">
               <Badge variant={test.testType === 'model' ? 'default' : 'secondary'}>
                 {test.testType}
               </Badge>
               <Badge variant={
                 test.status === 'success' ? 'secondary' :
                 test.status === 'error' ? 'destructive' : 'outline'
               }>
                 {test.status}
               </Badge>
             </div>
             
             <div className="space-y-1">
               <p className="text-sm font-medium">
                 {new Date(test.timestamp).toLocaleString()}
               </p>
               <div className="flex items-center gap-4 text-xs text-muted-foreground">
                 <span>{test.output.processingTime}ms</span>
                 <span>${test.output.cost.toFixed(4)}</span>
                 {test.output.confidence && (
                   <span>{(test.output.confidence * 100).toFixed(1)}% confidence</span>
                 )}
               </div>
             </div>
           </div>
           
           <Button
             variant="ghost"
             size="sm"
             onClick={() => setShowDetails(!showDetails)}
           >
             {showDetails ? 'Hide' : 'View'} Details
           </Button>
         </div>
         
         {showDetails && (
           <div className="border-t pt-3">
             <TestResultsDisplay
               result={test}
               isExpanded={true}
               onToggleExpanded={() => {}}
             />
           </div>
         )}
       </div>
     );
   }
   ```

**Files to Create:**
- `components/platform/ai-management/unified/sections/TestHistorySection.tsx`
- `components/platform/ai-management/unified/sections/TestHistoryItem.tsx`

**Acceptance Criteria:**
- [ ] List of all test executions with timestamps
- [ ] Filter by test type (model/prompt) and status
- [ ] Bulk selection and deletion of test results
- [ ] Expandable details for each test result
- [ ] Pagination for large test histories

### Task 6.2: Integrate Testing into ConsolidatedSettingsTab
**Duration:** 2 hours  
**Priority:** High  
**Complexity:** Low

**Objective:** Add testing tab to the consolidated settings interface

**Implementation Steps:**
1. **Update ConsolidatedSettingsTab with testing:**
   ```typescript
   // Update existing ConsolidatedSettingsTab.tsx
   export function ConsolidatedSettingsTab({ featureId, feature }: ConsolidatedSettingsTabProps) {
     return (
       <div className="space-y-6">
         <div>
           <h2 className="text-xl font-semibold">Feature Configuration</h2>
           <p className="text-sm text-muted-foreground">
             Manage all settings for {feature?.display_name} in one place
           </p>
         </div>
         
         <Tabs defaultValue="models" className="space-y-6">
           <TabsList className="grid w-full grid-cols-5">
             <TabsTrigger value="models">Models</TabsTrigger>
             <TabsTrigger value="prompts">Prompts</TabsTrigger>
             <TabsTrigger value="testing">Testing</TabsTrigger>
             <TabsTrigger value="limits">Limits</TabsTrigger>
             <TabsTrigger value="monitoring">Monitoring</TabsTrigger>
           </TabsList>
           
           <TabsContent value="models" className="space-y-4">
             <ModelAssignmentSection featureId={featureId} />
           </TabsContent>
           
           <TabsContent value="prompts" className="space-y-4">
             <PromptManagementSection featureId={featureId} />
           </TabsContent>
           
           <TabsContent value="testing" className="space-y-4">
             <TestHistorySection featureId={featureId} />
           </TabsContent>
           
           <TabsContent value="limits" className="space-y-4">
             <RateLimitsSection featureId={featureId} />
           </TabsContent>
           
           <TabsContent value="monitoring" className="space-y-4">
             <MonitoringConfigSection featureId={featureId} />
           </TabsContent>
         </Tabs>
       </div>
     );
   }
   ```

**Files to Modify:**
- `components/platform/ai-management/unified/ConsolidatedSettingsTab.tsx`

**Acceptance Criteria:**
- [ ] Testing tab added to consolidated settings
- [ ] TestHistorySection integrated and functional
- [ ] Tab navigation works smoothly
- [ ] Consistent styling with other tabs

### Task 6.3: Add Testing Service Error Handling
**Duration:** 1 hour  
**Priority:** Medium  
**Complexity:** Low

**Objective:** Improve error handling and validation for testing service

**Implementation Steps:**
1. **Enhance testing service with better error handling:**
   ```typescript
   // Update lib/services/ai-testing/testing-service.ts
   export class AITestingService {
     async executeTest(featureId: string, input: TestInput): Promise<TestResult> {
       // Enhanced input validation
       this.validateTestInput(input);
       
       // Check feature permissions
       await this.validateFeatureAccess(featureId);
       
       // Create sandbox with proper error handling
       let sandboxId: string | null = null;
       
       try {
         sandboxId = await this.createSandbox();
         const result = await this.executeSafeTest(sandboxId, input);
         await this.saveTestResult(featureId, result);
         return result;
       } catch (error) {
         // Log error details for debugging
         console.error('Test execution failed:', error);
         
         // Return structured error result
         return {
           id: `failed-${Date.now()}`,
           featureId,
           testType: input.type,
           input,
           output: {
             response: null,
             processingTime: 0,
             cost: 0,
             metadata: {}
           },
           timestamp: new Date(),
           status: 'error',
           error: error instanceof Error ? error.message : 'Unknown error'
         };
       } finally {
         // Always cleanup sandbox
         if (sandboxId) {
           await this.destroySandbox(sandboxId).catch(console.error);
         }
       }
     }
     
     private validateTestInput(input: TestInput): void {
       if (!input.type || !['model', 'prompt'].includes(input.type)) {
         throw new Error('Invalid test type');
       }
       
       if (!input.content) {
         throw new Error('Test content is required');
       }
       
       if (input.type === 'model' && !input.modelId) {
         throw new Error('Model ID is required for model tests');
       }
       
       if (input.type === 'prompt' && !input.promptId) {
         throw new Error('Prompt ID is required for prompt tests');
       }
     }
     
     private async validateFeatureAccess(featureId: string): Promise<void> {
       // Check if feature exists and user has access
       const response = await fetch(`/api/platform/ai-management/features/${featureId}`);
       if (!response.ok) {
         throw new Error('Feature not found or access denied');
       }
     }
   }
   ```

**Files to Modify:**
- `lib/services/ai-testing/testing-service.ts`

**Acceptance Criteria:**
- [ ] Comprehensive input validation
- [ ] Proper error responses for UI consumption
- [ ] Sandbox cleanup guaranteed even on errors
- [ ] Feature access validation
- [ ] Detailed error logging for debugging

---

## Integration and Testing

### API Endpoints Summary
**New endpoints created:**
- `POST /api/platform/ai-management/features/{id}/test` - Execute test
- `GET /api/platform/ai-management/features/{id}/test/history` - Get test history
- `DELETE /api/platform/ai-management/features/{id}/test/batch-delete` - Delete tests

### Database Changes
**New tables:**
- `ai_test_results` - Store test execution results and history

### Testing Requirements
1. **Unit Testing:**
   ```bash
   # Test testing service logic
   npm test -- --testPathPattern="testing-service"
   
   # Test UI components
   npm test -- --testPathPattern="testing.*test"
   ```

2. **Integration Testing:**
   ```bash
   # Test API endpoints
   npm test -- --testPathPattern="api.*test.*route"
   
   # Test database operations
   npm test -- --testPathPattern="database.*test"
   ```

3. **Manual Testing Checklist:**
   - [ ] Model testing with text input works
   - [ ] Model testing with image upload works (vision models)
   - [ ] Prompt testing with variable substitution works
   - [ ] Test results display correctly
   - [ ] Test history filtering and deletion works
   - [ ] Error handling for failed tests works
   - [ ] Sandbox isolation prevents system interference

### Performance Considerations
- Test execution timeout limits (30 seconds)
- Resource limits for sandbox environments
- Test result cleanup after 30 days
- Efficient querying for test history with pagination

---

## Handoff Requirements

### Documentation for Next Phase
1. **Testing Infrastructure Map:**
   - Document testing service architecture
   - API endpoint specifications
   - Security model for test execution
   - Sandbox environment capabilities

2. **Component Integration:**
   - How testing interfaces integrate with settings tabs
   - Shared component patterns (TestResultsDisplay)
   - State management for test execution

3. **Database Schema:**
   - Test results table structure
   - Indexing strategy for performance
   - Data retention policies

### Files Created Summary
**New Components:**
- `components/platform/ai-management/unified/sections/ModelAssignmentSection.tsx`
- `components/platform/ai-management/unified/sections/PromptManagementSection.tsx`
- `components/platform/ai-management/unified/sections/TestHistorySection.tsx`
- `components/platform/ai-management/unified/testing/ModelTestingInterface.tsx`
- `components/platform/ai-management/unified/testing/PromptTestingInterface.tsx`
- `components/platform/ai-management/unified/testing/TestResultsDisplay.tsx`

**New Services:**
- `lib/services/ai-testing/testing-service.ts`

**New API Routes:**
- `app/api/platform/ai-management/features/[id]/test/route.ts`
- `app/api/platform/ai-management/features/[id]/test/history/route.ts`

### Success Criteria for Phase 2
- [ ] Model and prompt testing capabilities embedded in settings
- [ ] Test execution works with proper sandboxing
- [ ] Test results are persisted and displayable
- [ ] Test history management is functional
- [ ] Existing prompt management integrated seamlessly
- [ ] All testing features work within unified interface
- [ ] Performance remains acceptable (tests complete within 30 seconds)

**Phase 2 Completion enables:**
- Phase 3 real-time features with testing integration
- Advanced test comparison and analytics
- Automated testing workflows and CI/CD integration