# Phase 4: Component Type Safety

## Objective
Fix all TypeScript errors in React components, focusing on prop types, event handlers, and component interfaces.

## Files to Fix (Priority Order)

### AI Settings Components
1. **components/ai/settings/ProviderConfiguration.tsx** (25 errors)
   - Fix provider type definitions
   - Fix configuration prop types
   - Add proper event handler types

2. **components/ai/settings/QualityControls.tsx** (24 errors)
   - Fix control prop types
   - Fix state type definitions
   - Add validation type guards

3. **components/ai/settings/ProcessingRules.tsx** (19 errors)
   - Fix rule type definitions
   - Fix array method types

4. **components/ai/monitoring/ProviderHealth.tsx** (22 errors)
   - Fix health data types
   - Fix metric display types

### Platform Management Components
1. **components/platform/ai-management/unified/FeatureSidebar.tsx** (19 errors)
   - Fix sidebar prop types
   - Fix navigation types

2. **components/platform/ai-management/unified/RateLimitingSection.tsx** (11 errors)
   - Fix rate limit configuration types
   - Fix input handler types

3. **components/platform/organization-management.tsx** (11 errors)
   - Fix organization data types
   - Fix form submission types

4. **components/platform/cross-org-user-management.tsx** (11 errors)
   - Fix user management types
   - Fix permission types

## Common Component Fixes

### 1. Fix Component Props Interface
```typescript
// Before
function Component(props) { // Missing type
  return <div>{props.title}</div>
}

// After
interface ComponentProps {
  title: string
  onAction?: () => void
  data: DataType
}

function Component({ title, onAction, data }: ComponentProps) {
  return <div>{title}</div>
}
```

### 2. Fix Event Handler Types
```typescript
// Before
const handleClick = (e) => { // Implicit any
  console.log(e.target.value)
}

// After
const handleClick = (e: React.MouseEvent<HTMLButtonElement>) => {
  const target = e.target as HTMLButtonElement
  console.log(target.value)
}

// For form events
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault()
  // handle form
}

// For input changes
const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
  setValue(e.target.value)
}
```

### 3. Fix State Types
```typescript
// Before
const [data, setData] = useState() // Type undefined

// After
const [data, setData] = useState<DataType | null>(null)
// OR with initial value
const [data, setData] = useState<DataType>({
  // initial shape
})
```

### 4. Fix Array Method Types
```typescript
// Before
items.map(item => ...) // item implicitly any

// After
items.map((item: ItemType) => ...)
// OR ensure items is typed
const items: ItemType[] = getData()
items.map(item => ...) // item is now ItemType
```

### 5. Fix Ref Types
```typescript
// Before
const ref = useRef() // Type undefined

// After
const ref = useRef<HTMLDivElement>(null)
// For input refs
const inputRef = useRef<HTMLInputElement>(null)
```

## Component Type Templates

### Base Component Props
```typescript
// components/types/common.ts
export interface BaseComponentProps {
  className?: string
  children?: React.ReactNode
  disabled?: boolean
  loading?: boolean
}

// Extend for specific components
export interface ButtonProps extends BaseComponentProps {
  onClick?: (e: React.MouseEvent<HTMLButtonElement>) => void
  variant?: 'primary' | 'secondary' | 'danger'
  size?: 'sm' | 'md' | 'lg'
}
```

### Form Component Types
```typescript
// components/types/forms.ts
export interface FormData {
  [key: string]: string | number | boolean
}

export interface FormProps<T = FormData> {
  initialValues?: Partial<T>
  onSubmit: (values: T) => void | Promise<void>
  validation?: (values: T) => Record<string, string>
}

export interface InputProps {
  name: string
  value: string | number
  onChange: (value: string | number) => void
  error?: string
  label?: string
  type?: 'text' | 'number' | 'email' | 'password'
}
```

### Provider Configuration Types
```typescript
// lib/types/ai/provider.ts
export interface ProviderConfig {
  id: string
  name: string
  type: 'google' | 'clarifai' | 'gemini'
  enabled: boolean
  apiKey?: string
  settings: {
    maxRetries: number
    timeout: number
    rateLimit: {
      requests: number
      period: number
    }
  }
}

export interface ProviderHealth {
  status: 'healthy' | 'degraded' | 'down'
  latency: number
  errorRate: number
  lastChecked: Date
}
```

## Validation Commands
After fixing all files in this phase, run:
```bash
npm run lint -- components/
npm run build
npm test -- components/
```

## Success Criteria
- All component TypeScript errors resolved
- Props properly typed for all components
- Event handlers have explicit types
- State and refs properly typed
- No implicit any types in components

## Notes for Agent
- Create shared prop type definitions
- Use React.FC sparingly (prefer explicit return types)
- Ensure all event handlers are properly typed
- Add JSDoc comments for complex prop types
- Consider using discriminated unions for variant props
- Test components still render correctly after fixes