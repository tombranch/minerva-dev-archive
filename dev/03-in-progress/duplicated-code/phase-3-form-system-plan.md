# Phase 3: Form System Consolidation Implementation Plan

**Duration:** 2 weeks  
**Priority:** High  
**Agent Assignment:** Frontend UI/UX Specialist  
**Dependencies:** Phase 1 (Authentication Service)  

## Overview

Consolidate scattered form validation patterns into a unified, reusable form system. This phase addresses duplication in form validation, error handling, field components, and form state management.

## Current State Analysis

### Files to Consolidate
- `hooks/use-form-validation.ts` (146 lines) - Generic validation hook
- `components/auth/auth-form.tsx` (200+ lines) - Auth form with custom validation
- `components/ui/form-field.tsx` (61 lines) - Form field wrapper
- `components/ui/input.tsx` - Input component
- `components/ui/password-input.tsx` - Password input
- `components/ui/textarea.tsx` - Textarea component
- `lib/validation-schemas.ts` (400+ lines) - Zod schemas

### Duplication Issues
1. Field-level validation patterns repeated in 8+ components
2. Error state management duplicated across forms
3. Touch/blur handling implemented inconsistently
4. Schema validation scattered instead of centralized
5. Form submission patterns repeated

## Implementation Tasks

### Task 1: Create Unified Form Hook
**File:** `hooks/use-unified-form.ts`
**Estimated Time:** 3 days

```typescript
// Comprehensive form management hook
export interface UnifiedFormConfig<T> {
  schema: ZodSchema<T>
  defaultValues?: Partial<T>
  mode?: 'onChange' | 'onBlur' | 'onSubmit' | 'all'
  reValidateMode?: 'onChange' | 'onBlur' | 'onSubmit'
  onSubmit: (data: T) => Promise<void> | void
  onError?: (errors: FormErrors<T>) => void
  resetOnSubmit?: boolean
  validateOnMount?: boolean
}

export interface FormState<T> {
  values: T
  errors: FormErrors<T>
  touched: Record<keyof T, boolean>
  isSubmitting: boolean
  isValid: boolean
  isDirty: boolean
  submitCount: number
}

export interface FormActions<T> {
  setValue: <K extends keyof T>(field: K, value: T[K]) => void
  setValues: (values: Partial<T>) => void
  setError: <K extends keyof T>(field: K, error: string) => void
  clearError: <K extends keyof T>(field: K) => void
  clearErrors: () => void
  setTouched: <K extends keyof T>(field: K, touched?: boolean) => void
  reset: (values?: Partial<T>) => void
  submit: () => Promise<void>
  validate: () => Promise<boolean>
  validateField: <K extends keyof T>(field: K) => Promise<boolean>
}

export function useUnifiedForm<T extends Record<string, any>>(
  config: UnifiedFormConfig<T>
): FormState<T> & FormActions<T> {
  // Implementation with comprehensive form management
  const [state, setState] = useState<FormState<T>>({
    values: { ...config.defaultValues } as T,
    errors: {},
    touched: {},
    isSubmitting: false,
    isValid: false,
    isDirty: false,
    submitCount: 0
  })

  // Field-level validation
  const validateField = useCallback(async <K extends keyof T>(field: K): Promise<boolean> => {
    try {
      const fieldSchema = config.schema.shape[field] as ZodSchema
      await fieldSchema.parseAsync(state.values[field])
      
      setState(prev => ({
        ...prev,
        errors: { ...prev.errors, [field]: undefined }
      }))
      return true
    } catch (error) {
      if (error instanceof ZodError) {
        setState(prev => ({
          ...prev,
          errors: { ...prev.errors, [field]: error.errors[0]?.message }
        }))
      }
      return false
    }
  }, [config.schema, state.values])

  // Form-level validation
  const validate = useCallback(async (): Promise<boolean> => {
    try {
      await config.schema.parseAsync(state.values)
      setState(prev => ({ ...prev, errors: {}, isValid: true }))
      return true
    } catch (error) {
      if (error instanceof ZodError) {
        const errors = error.errors.reduce((acc, err) => {
          const field = err.path[0] as keyof T
          acc[field] = err.message
          return acc
        }, {} as FormErrors<T>)
        
        setState(prev => ({ ...prev, errors, isValid: false }))
      }
      return false
    }
  }, [config.schema, state.values])

  // Form submission
  const submit = useCallback(async () => {
    setState(prev => ({ ...prev, isSubmitting: true, submitCount: prev.submitCount + 1 }))
    
    try {
      const isValid = await validate()
      if (!isValid) return
      
      await config.onSubmit(state.values)
      
      if (config.resetOnSubmit) {
        setState(prev => ({
          ...prev,
          values: { ...config.defaultValues } as T,
          errors: {},
          touched: {},
          isDirty: false
        }))
      }
    } catch (error) {
      config.onError?.(error instanceof Error ? { form: error.message } : { form: 'Submission failed' })
    } finally {
      setState(prev => ({ ...prev, isSubmitting: false }))
    }
  }, [config, state.values, validate])

  return {
    ...state,
    setValue,
    setValues,
    setError,
    clearError,
    clearErrors,
    setTouched,
    reset,
    submit,
    validate,
    validateField
  }
}
```

**Implementation Steps:**
1. Create base form hook structure
2. Implement field-level validation
3. Add form-level validation
4. Implement submission handling
5. Add state management utilities
6. Create comprehensive TypeScript types
7. Write unit tests for all functionality

### Task 2: Create Unified Form Components
**File:** `components/ui/form/index.ts`
**Estimated Time:** 3 days

```typescript
// Form component system
export interface FormProps<T> {
  form: ReturnType<typeof useUnifiedForm<T>>
  onSubmit?: (e: React.FormEvent) => void
  className?: string
  children: React.ReactNode
}

export function Form<T>({ form, onSubmit, className, children }: FormProps<T>) {
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSubmit?.(e) || form.submit()
  }

  return (
    <form onSubmit={handleSubmit} className={cn('space-y-4', className)} noValidate>
      <FormProvider value={form}>
        {children}
      </FormProvider>
    </form>
  )
}

// Field component with automatic validation
export interface FieldProps<T, K extends keyof T> {
  name: K
  label?: string
  description?: string
  required?: boolean
  className?: string
  children: (fieldProps: FieldRenderProps<T[K]>) => React.ReactNode
}

export function Field<T, K extends keyof T>({ 
  name, 
  label, 
  description, 
  required, 
  className, 
  children 
}: FieldProps<T, K>) {
  const form = useFormContext<T>()
  const value = form.values[name]
  const error = form.errors[name]
  const touched = form.touched[name]

  const fieldProps: FieldRenderProps<T[K]> = {
    value,
    onChange: (newValue: T[K]) => {
      form.setValue(name, newValue)
      if (form.mode === 'onChange' || (form.mode === 'all' && touched)) {
        form.validateField(name)
      }
    },
    onBlur: () => {
      form.setTouched(name, true)
      if (form.mode === 'onBlur' || form.mode === 'all') {
        form.validateField(name)
      }
    },
    error: touched ? error : undefined,
    required,
    'aria-invalid': !!error,
    'aria-describedby': error ? `${String(name)}-error` : undefined
  }

  return (
    <FormField
      label={label}
      error={touched ? error : undefined}
      description={description}
      required={required}
      className={className}
    >
      {children(fieldProps)}
    </FormField>
  )
}

// Specialized input components
export function TextInput<T, K extends keyof T>(props: InputFieldProps<T, K>) {
  return (
    <Field {...props}>
      {(fieldProps) => (
        <Input
          type="text"
          value={fieldProps.value || ''}
          onChange={(e) => fieldProps.onChange(e.target.value as T[K])}
          onBlur={fieldProps.onBlur}
          error={fieldProps.error}
          required={fieldProps.required}
          aria-invalid={fieldProps['aria-invalid']}
          aria-describedby={fieldProps['aria-describedby']}
        />
      )}
    </Field>
  )
}

export function PasswordInput<T, K extends keyof T>(props: InputFieldProps<T, K>) {
  return (
    <Field {...props}>
      {(fieldProps) => (
        <PasswordInputComponent
          value={fieldProps.value || ''}
          onChange={(e) => fieldProps.onChange(e.target.value as T[K])}
          onBlur={fieldProps.onBlur}
          error={fieldProps.error}
          required={fieldProps.required}
          aria-invalid={fieldProps['aria-invalid']}
          aria-describedby={fieldProps['aria-describedby']}
        />
      )}
    </Field>
  )
}

export function TextArea<T, K extends keyof T>(props: TextAreaFieldProps<T, K>) {
  return (
    <Field {...props}>
      {(fieldProps) => (
        <Textarea
          value={fieldProps.value || ''}
          onChange={(e) => fieldProps.onChange(e.target.value as T[K])}
          onBlur={fieldProps.onBlur}
          error={fieldProps.error}
          required={fieldProps.required}
          rows={props.rows}
          aria-invalid={fieldProps['aria-invalid']}
          aria-describedby={fieldProps['aria-describedby']}
        />
      )}
    </Field>
  )
}

export function Select<T, K extends keyof T>(props: SelectFieldProps<T, K>) {
  return (
    <Field {...props}>
      {(fieldProps) => (
        <SelectComponent
          value={fieldProps.value}
          onValueChange={fieldProps.onChange}
          onBlur={fieldProps.onBlur}
          error={fieldProps.error}
          required={fieldProps.required}
          aria-invalid={fieldProps['aria-invalid']}
          aria-describedby={fieldProps['aria-describedby']}
        >
          {props.children}
        </SelectComponent>
      )}
    </Field>
  )
}
```

**Implementation Steps:**
1. Create Form wrapper component
2. Implement Field component with render props
3. Create specialized input components
4. Add form context for state sharing
5. Implement accessibility features
6. Add comprehensive TypeScript support

### Task 3: Create Form Validation Schemas
**File:** `lib/forms/validation-schemas.ts`
**Estimated Time:** 2 days

```typescript
// Centralized validation schemas for forms
export const FormSchemas = {
  // Authentication forms
  signIn: z.object({
    email: z.string().email('Please enter a valid email address'),
    password: z.string().min(1, 'Password is required')
  }),

  signUp: z.object({
    email: z.string().email('Please enter a valid email address'),
    password: z.string()
      .min(8, 'Password must be at least 8 characters')
      .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
      .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
      .regex(/\d/, 'Password must contain at least one number')
      .regex(/[!@#$%^&*(),.?":{}|<>]/, 'Password must contain at least one special character'),
    confirmPassword: z.string(),
    firstName: z.string().min(1, 'First name is required').max(50).optional(),
    lastName: z.string().min(1, 'Last name is required').max(50).optional()
  }).refine(data => data.password === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"]
  }),

  resetPassword: z.object({
    email: z.string().email('Please enter a valid email address')
  }),

  updatePassword: z.object({
    currentPassword: z.string().min(1, 'Current password is required'),
    newPassword: z.string()
      .min(8, 'Password must be at least 8 characters')
      .regex(/[A-Z]/, 'Password must contain at least one uppercase letter')
      .regex(/[a-z]/, 'Password must contain at least one lowercase letter')
      .regex(/\d/, 'Password must contain at least one number'),
    confirmPassword: z.string()
  }).refine(data => data.newPassword === data.confirmPassword, {
    message: "Passwords don't match",
    path: ["confirmPassword"]
  }),

  // User management forms
  userCreate: z.object({
    email: z.string().email('Please enter a valid email address'),
    firstName: z.string().min(1, 'First name is required').max(50),
    lastName: z.string().min(1, 'Last name is required').max(50),
    role: z.enum(['engineer', 'admin', 'platform_admin'])
  }),

  userUpdate: z.object({
    firstName: z.string().min(1, 'First name is required').max(50),
    lastName: z.string().min(1, 'Last name is required').max(50),
    role: z.enum(['engineer', 'admin', 'platform_admin']).optional()
  }),

  // Project forms
  projectCreate: z.object({
    name: z.string().min(1, 'Project name is required').max(100),
    description: z.string().max(500).optional(),
    siteId: z.string().min(1, 'Site is required')
  }),

  // Organization forms
  organizationCreate: z.object({
    name: z.string().min(1, 'Organization name is required').max(100),
    slug: z.string()
      .min(3, 'Slug must be at least 3 characters')
      .max(50, 'Slug must be less than 50 characters')
      .regex(/^[a-z0-9]+(?:-[a-z0-9]+)*$/, 'Slug must be lowercase alphanumeric with hyphens')
  })
}

// Form type inference
export type SignInFormData = z.infer<typeof FormSchemas.signIn>
export type SignUpFormData = z.infer<typeof FormSchemas.signUp>
export type ResetPasswordFormData = z.infer<typeof FormSchemas.resetPassword>
export type UpdatePasswordFormData = z.infer<typeof FormSchemas.updatePassword>
export type UserCreateFormData = z.infer<typeof FormSchemas.userCreate>
export type UserUpdateFormData = z.infer<typeof FormSchemas.userUpdate>
export type ProjectCreateFormData = z.infer<typeof FormSchemas.projectCreate>
export type OrganizationCreateFormData = z.infer<typeof FormSchemas.organizationCreate>
```

**Implementation Steps:**
1. Consolidate existing validation schemas
2. Create comprehensive form schemas
3. Add proper error messages
4. Implement complex validation rules
5. Add TypeScript type inference
6. Test all validation scenarios

### Task 4: Refactor Authentication Forms
**Files:** `components/auth/auth-form.tsx`, auth pages
**Estimated Time:** 2 days

```typescript
// Refactored authentication form using unified system
export function AuthForm({ type }: { type: 'login' | 'signup' }) {
  const router = useRouter()
  const { signIn, signUp } = useAuth()

  const form = useUnifiedForm({
    schema: type === 'login' ? FormSchemas.signIn : FormSchemas.signUp,
    mode: 'onBlur',
    onSubmit: async (data) => {
      if (type === 'login') {
        const result = await signIn(data.email, data.password)
        if (result.success) {
          router.push('/photos')
        } else {
          form.setError('form', result.error || 'Sign in failed')
        }
      } else {
        const result = await signUp(data.email, data.password, {
          firstName: data.firstName,
          lastName: data.lastName
        })
        if (result.success) {
          router.push('/verify-email')
        } else {
          form.setError('form', result.error || 'Sign up failed')
        }
      }
    }
  })

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader>
        <CardTitle>{type === 'login' ? 'Sign In' : 'Create Account'}</CardTitle>
        <CardDescription>
          {type === 'login' 
            ? 'Enter your email and password to access your account'
            : 'Enter your information to create a new account'
          }
        </CardDescription>
      </CardHeader>
      <CardContent>
        <Form form={form}>
          <TextInput name="email" label="Email" type="email" required />
          <PasswordInput name="password" label="Password" required />
          
          {type === 'signup' && (
            <>
              <PasswordInput name="confirmPassword" label="Confirm Password" required />
              <TextInput name="firstName" label="First Name" />
              <TextInput name="lastName" label="Last Name" />
            </>
          )}

          {form.errors.form && (
            <Alert variant="destructive">
              <AlertDescription>{form.errors.form}</AlertDescription>
            </Alert>
          )}

          <Button type="submit" className="w-full" disabled={form.isSubmitting}>
            {form.isSubmitting ? (
              <>
                <LoadingSpinner size="sm" className="mr-2" />
                {type === 'login' ? 'Signing in...' : 'Creating account...'}
              </>
            ) : (
              type === 'login' ? 'Sign In' : 'Create Account'
            )}
          </Button>
        </Form>
      </CardContent>
    </Card>
  )
}
```

**Implementation Steps:**
1. Refactor auth-form.tsx to use unified form system
2. Update login page component
3. Update signup page component
4. Update password reset forms
5. Test all authentication flows
6. Ensure backward compatibility

### Task 5: Create Form Utilities
**File:** `lib/forms/form-utils.ts`
**Estimated Time:** 1 day

```typescript
// Form utility functions
export class FormUtils {
  // Convert form data to API format
  static toApiFormat<T>(data: T, transformations?: Record<keyof T, (value: any) => any>): any {
    const result = { ...data }
    
    if (transformations) {
      Object.entries(transformations).forEach(([key, transform]) => {
        if (key in result) {
          result[key as keyof T] = transform(result[key as keyof T])
        }
      })
    }
    
    return result
  }

  // Convert API data to form format
  static fromApiFormat<T>(data: any, schema: ZodSchema<T>): Partial<T> {
    try {
      return schema.partial().parse(data)
    } catch {
      return {}
    }
  }

  // Generate form field props
  static getFieldProps<T>(
    form: ReturnType<typeof useUnifiedForm<T>>,
    name: keyof T
  ): FieldRenderProps<T[keyof T]> {
    return {
      value: form.values[name],
      onChange: (value) => form.setValue(name, value),
      onBlur: () => form.setTouched(name, true),
      error: form.touched[name] ? form.errors[name] : undefined,
      'aria-invalid': !!form.errors[name],
      'aria-describedby': form.errors[name] ? `${String(name)}-error` : undefined
    }
  }

  // Form state helpers
  static isDirty<T>(form: ReturnType<typeof useUnifiedForm<T>>): boolean {
    return Object.keys(form.touched).length > 0
  }

  static hasErrors<T>(form: ReturnType<typeof useUnifiedForm<T>>): boolean {
    return Object.values(form.errors).some(error => !!error)
  }

  static getFirstError<T>(form: ReturnType<typeof useUnifiedForm<T>>): string | undefined {
    return Object.values(form.errors).find(error => !!error)
  }
}
```

## Testing Requirements

### Unit Tests
- Form hook functionality (100% coverage)
- Field component behavior
- Validation schema accuracy
- Form utility functions

### Integration Tests
- Complete form submission flows
- Validation error handling
- Field interaction behavior
- Form state management

### Accessibility Tests
- Screen reader compatibility
- Keyboard navigation
- ARIA attribute correctness
- Focus management

## Success Criteria

### Code Quality
- [ ] All forms use unified form system
- [ ] No duplicated validation logic
- [ ] Consistent error handling across forms
- [ ] Comprehensive TypeScript coverage

### User Experience
- [ ] Consistent form behavior across application
- [ ] Improved error messages and validation
- [ ] Better accessibility support
- [ ] Responsive form layouts

### Developer Experience
- [ ] Easy to create new forms
- [ ] Reusable form components
- [ ] Clear validation patterns
- [ ] Good TypeScript inference

## Deliverables

1. **Unified Form Hook** - Complete form management system
2. **Form Components** - Reusable form component library
3. **Validation Schemas** - Centralized validation logic
4. **Refactored Forms** - All forms using new system
5. **Form Utilities** - Helper functions and utilities
6. **Comprehensive Tests** - Full test coverage
7. **Documentation** - Usage guides and examples
8. **Migration Guide** - How to convert existing forms

---

**Phase Owner:** Frontend UI/UX Specialist Agent  
**Review Required:** Senior Frontend Developer + UX Review  
**Next Phase:** Phase 4 - Modal System Standardization
