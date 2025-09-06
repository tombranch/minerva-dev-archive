# Phase 4: Modal System Standardization Implementation Plan

**Duration:** 2 weeks  
**Priority:** High  
**Agent Assignment:** Frontend Component Specialist  
**Dependencies:** Phase 3 (Form System)  

## Overview

Consolidate scattered modal and dialog patterns into a unified, reusable modal system. This phase addresses duplication in modal structures, confirmation dialogs, modal state management, and interaction patterns.

## Current State Analysis

### Files to Consolidate
- `components/ui/dialog.tsx` (129 lines) - Base dialog component
- `components/photos/bulk-operations-modal.tsx` (400+ lines) - Complex modal
- `components/photos/ai-results-modal.tsx` (500+ lines) - Data display modal
- `components/photos/photo-detail-modal.tsx` (800+ lines) - Full-screen modal
- `components/platform/ai-management/unified/ActionConfirmationDialog.tsx` (266 lines) - Confirmation dialog
- `components/platform/ai-management/BulkActionToolbar.tsx` (partial) - Alert dialogs

### Duplication Issues
1. Modal structure patterns repeated in 6+ components
2. Confirmation dialog logic duplicated
3. Modal state management inconsistent
4. Close/escape handling patterns repeated
5. Loading states in modals implemented differently
6. Form integration patterns scattered

## Implementation Tasks

### Task 1: Create Unified Modal System
**File:** `components/ui/modal/unified-modal.tsx`
**Estimated Time:** 4 days

```typescript
// Comprehensive modal system
export interface ModalConfig {
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl' | 'full'
  type?: 'dialog' | 'drawer' | 'fullscreen' | 'overlay'
  closable?: boolean
  closeOnOverlayClick?: boolean
  closeOnEscape?: boolean
  showCloseButton?: boolean
  persistent?: boolean
  centered?: boolean
  scrollable?: boolean
  animation?: 'fade' | 'slide' | 'scale' | 'none'
}

export interface ModalState {
  isOpen: boolean
  isLoading: boolean
  error: string | null
  data: any
}

export interface ModalActions {
  open: (data?: any) => void
  close: () => void
  setLoading: (loading: boolean) => void
  setError: (error: string | null) => void
  setData: (data: any) => void
}

// Base modal hook
export function useModal(initialState?: Partial<ModalState>): ModalState & ModalActions {
  const [state, setState] = useState<ModalState>({
    isOpen: false,
    isLoading: false,
    error: null,
    data: null,
    ...initialState
  })

  const open = useCallback((data?: any) => {
    setState(prev => ({ ...prev, isOpen: true, data, error: null }))
  }, [])

  const close = useCallback(() => {
    setState(prev => ({ ...prev, isOpen: false, error: null }))
  }, [])

  const setLoading = useCallback((loading: boolean) => {
    setState(prev => ({ ...prev, isLoading: loading }))
  }, [])

  const setError = useCallback((error: string | null) => {
    setState(prev => ({ ...prev, error, isLoading: false }))
  }, [])

  const setData = useCallback((data: any) => {
    setState(prev => ({ ...prev, data }))
  }, [])

  return { ...state, open, close, setLoading, setError, setData }
}

// Unified modal component
export interface UnifiedModalProps {
  modal: ReturnType<typeof useModal>
  config?: ModalConfig
  title?: string
  description?: string
  children: React.ReactNode
  footer?: React.ReactNode
  onClose?: () => void
  className?: string
}

export function UnifiedModal({
  modal,
  config = {},
  title,
  description,
  children,
  footer,
  onClose,
  className
}: UnifiedModalProps) {
  const {
    size = 'md',
    type = 'dialog',
    closable = true,
    closeOnOverlayClick = true,
    closeOnEscape = true,
    showCloseButton = true,
    persistent = false,
    centered = true,
    scrollable = true,
    animation = 'fade'
  } = config

  // Handle close events
  const handleClose = useCallback(() => {
    if (!persistent && closable) {
      onClose?.()
      modal.close()
    }
  }, [persistent, closable, onClose, modal])

  // Keyboard handling
  useEffect(() => {
    if (!modal.isOpen || !closeOnEscape) return

    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === 'Escape') {
        handleClose()
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [modal.isOpen, closeOnEscape, handleClose])

  // Size classes
  const sizeClasses = {
    xs: 'max-w-xs',
    sm: 'max-w-sm',
    md: 'max-w-md',
    lg: 'max-w-lg',
    xl: 'max-w-xl',
    full: 'max-w-full h-full'
  }

  // Type-specific rendering
  if (type === 'fullscreen') {
    return (
      <Dialog open={modal.isOpen} onOpenChange={closable ? handleClose : undefined}>
        <DialogContent 
          className={cn('w-screen h-screen max-w-none p-0', className)}
          showCloseButton={false}
        >
          <FullscreenModalContent
            title={title}
            description={description}
            onClose={showCloseButton ? handleClose : undefined}
            isLoading={modal.isLoading}
            error={modal.error}
          >
            {children}
          </FullscreenModalContent>
          {footer}
        </DialogContent>
      </Dialog>
    )
  }

  if (type === 'drawer') {
    return (
      <Sheet open={modal.isOpen} onOpenChange={closable ? handleClose : undefined}>
        <SheetContent className={cn('flex flex-col', className)}>
          <DrawerModalContent
            title={title}
            description={description}
            onClose={showCloseButton ? handleClose : undefined}
            isLoading={modal.isLoading}
            error={modal.error}
          >
            {children}
          </DrawerModalContent>
          {footer && <SheetFooter>{footer}</SheetFooter>}
        </SheetContent>
      </Sheet>
    )
  }

  // Default dialog modal
  return (
    <Dialog open={modal.isOpen} onOpenChange={closable ? handleClose : undefined}>
      <DialogContent 
        className={cn(
          sizeClasses[size],
          scrollable && 'max-h-[90vh] overflow-y-auto',
          className
        )}
        showCloseButton={showCloseButton && closable}
        onPointerDownOutside={closeOnOverlayClick ? undefined : (e) => e.preventDefault()}
      >
        <DialogModalContent
          title={title}
          description={description}
          isLoading={modal.isLoading}
          error={modal.error}
        >
          {children}
        </DialogModalContent>
        {footer && <DialogFooter>{footer}</DialogFooter>}
      </DialogContent>
    </Dialog>
  )
}
```

**Implementation Steps:**
1. Create base modal hook with state management
2. Implement UnifiedModal component with multiple types
3. Add keyboard and accessibility handling
4. Create size and animation variants
5. Implement error and loading states
6. Add comprehensive TypeScript support

### Task 2: Create Specialized Modal Types
**File:** `components/ui/modal/modal-types.tsx`
**Estimated Time:** 3 days

```typescript
// Confirmation Modal
export interface ConfirmationModalProps {
  modal: ReturnType<typeof useModal>
  title: string
  message: string
  confirmText?: string
  cancelText?: string
  variant?: 'default' | 'destructive' | 'warning'
  onConfirm: () => Promise<void> | void
  onCancel?: () => void
  icon?: React.ComponentType<{ className?: string }>
}

export function ConfirmationModal({
  modal,
  title,
  message,
  confirmText = 'Confirm',
  cancelText = 'Cancel',
  variant = 'default',
  onConfirm,
  onCancel,
  icon: Icon
}: ConfirmationModalProps) {
  const handleConfirm = async () => {
    try {
      modal.setLoading(true)
      await onConfirm()
      modal.close()
    } catch (error) {
      modal.setError(error instanceof Error ? error.message : 'Action failed')
    } finally {
      modal.setLoading(false)
    }
  }

  const handleCancel = () => {
    onCancel?.()
    modal.close()
  }

  const variantStyles = {
    default: 'text-primary',
    destructive: 'text-destructive',
    warning: 'text-warning'
  }

  return (
    <UnifiedModal
      modal={modal}
      config={{ size: 'sm', closeOnOverlayClick: false }}
      title={title}
      footer={
        <div className="flex gap-2 justify-end">
          <Button variant="outline" onClick={handleCancel} disabled={modal.isLoading}>
            {cancelText}
          </Button>
          <Button 
            variant={variant === 'destructive' ? 'destructive' : 'default'}
            onClick={handleConfirm}
            disabled={modal.isLoading}
          >
            {modal.isLoading ? (
              <>
                <LoadingSpinner size="sm" className="mr-2" />
                Processing...
              </>
            ) : (
              confirmText
            )}
          </Button>
        </div>
      }
    >
      <div className="flex items-start gap-3">
        {Icon && (
          <div className={cn('mt-1', variantStyles[variant])}>
            <Icon className="h-5 w-5" />
          </div>
        )}
        <div className="flex-1">
          <p className="text-sm text-muted-foreground">{message}</p>
          {modal.error && (
            <Alert variant="destructive" className="mt-3">
              <AlertDescription>{modal.error}</AlertDescription>
            </Alert>
          )}
        </div>
      </div>
    </UnifiedModal>
  )
}

// Form Modal
export interface FormModalProps<T> {
  modal: ReturnType<typeof useModal>
  title: string
  description?: string
  form: ReturnType<typeof useUnifiedForm<T>>
  submitText?: string
  cancelText?: string
  onSubmit?: (data: T) => Promise<void> | void
  onCancel?: () => void
  children: React.ReactNode
}

export function FormModal<T>({
  modal,
  title,
  description,
  form,
  submitText = 'Save',
  cancelText = 'Cancel',
  onSubmit,
  onCancel,
  children
}: FormModalProps<T>) {
  const handleSubmit = async () => {
    try {
      modal.setLoading(true)
      const isValid = await form.validate()
      if (!isValid) return
      
      await onSubmit?.(form.values)
      modal.close()
    } catch (error) {
      modal.setError(error instanceof Error ? error.message : 'Save failed')
    } finally {
      modal.setLoading(false)
    }
  }

  const handleCancel = () => {
    onCancel?.()
    modal.close()
  }

  return (
    <UnifiedModal
      modal={modal}
      config={{ size: 'md' }}
      title={title}
      description={description}
      footer={
        <div className="flex gap-2 justify-end">
          <Button variant="outline" onClick={handleCancel} disabled={modal.isLoading}>
            {cancelText}
          </Button>
          <Button onClick={handleSubmit} disabled={modal.isLoading || !form.isValid}>
            {modal.isLoading ? (
              <>
                <LoadingSpinner size="sm" className="mr-2" />
                Saving...
              </>
            ) : (
              submitText
            )}
          </Button>
        </div>
      }
    >
      <Form form={form}>
        {children}
        {modal.error && (
          <Alert variant="destructive">
            <AlertDescription>{modal.error}</AlertDescription>
          </Alert>
        )}
      </Form>
    </UnifiedModal>
  )
}

// Data Display Modal
export interface DataDisplayModalProps {
  modal: ReturnType<typeof useModal>
  title: string
  description?: string
  data: any
  loading?: boolean
  error?: string | null
  onRefresh?: () => Promise<void> | void
  children: (data: any) => React.ReactNode
}

export function DataDisplayModal({
  modal,
  title,
  description,
  data,
  loading,
  error,
  onRefresh,
  children
}: DataDisplayModalProps) {
  const handleRefresh = async () => {
    if (!onRefresh) return
    
    try {
      modal.setLoading(true)
      await onRefresh()
    } catch (error) {
      modal.setError(error instanceof Error ? error.message : 'Refresh failed')
    } finally {
      modal.setLoading(false)
    }
  }

  return (
    <UnifiedModal
      modal={modal}
      config={{ size: 'lg', scrollable: true }}
      title={title}
      description={description}
      footer={
        onRefresh && (
          <Button variant="outline" onClick={handleRefresh} disabled={modal.isLoading}>
            {modal.isLoading ? (
              <>
                <LoadingSpinner size="sm" className="mr-2" />
                Refreshing...
              </>
            ) : (
              <>
                <RefreshCw className="h-4 w-4 mr-2" />
                Refresh
              </>
            )}
          </Button>
        )
      }
    >
      {loading || modal.isLoading ? (
        <div className="flex items-center justify-center py-8">
          <LoadingSpinner size="lg" />
        </div>
      ) : error || modal.error ? (
        <div className="py-8">
          <Alert variant="destructive">
            <AlertTriangle className="h-4 w-4" />
            <AlertTitle>Error</AlertTitle>
            <AlertDescription>{error || modal.error}</AlertDescription>
          </Alert>
        </div>
      ) : (
        children(data || modal.data)
      )}
    </UnifiedModal>
  )
}

// Image Gallery Modal
export interface ImageGalleryModalProps {
  modal: ReturnType<typeof useModal>
  images: Array<{ id: string; url: string; alt: string }>
  currentIndex: number
  onIndexChange: (index: number) => void
  onClose?: () => void
}

export function ImageGalleryModal({
  modal,
  images,
  currentIndex,
  onIndexChange,
  onClose
}: ImageGalleryModalProps) {
  const handlePrevious = () => {
    onIndexChange(currentIndex > 0 ? currentIndex - 1 : images.length - 1)
  }

  const handleNext = () => {
    onIndexChange(currentIndex < images.length - 1 ? currentIndex + 1 : 0)
  }

  // Keyboard navigation
  useEffect(() => {
    if (!modal.isOpen) return

    const handleKeyDown = (e: KeyboardEvent) => {
      switch (e.key) {
        case 'ArrowLeft':
          handlePrevious()
          break
        case 'ArrowRight':
          handleNext()
          break
      }
    }

    document.addEventListener('keydown', handleKeyDown)
    return () => document.removeEventListener('keydown', handleKeyDown)
  }, [modal.isOpen, currentIndex])

  return (
    <UnifiedModal
      modal={modal}
      config={{ 
        type: 'fullscreen', 
        closeOnOverlayClick: true,
        animation: 'fade'
      }}
      onClose={onClose}
    >
      <div className="relative w-full h-full flex items-center justify-center bg-black">
        {/* Image */}
        <img
          src={images[currentIndex]?.url}
          alt={images[currentIndex]?.alt}
          className="max-w-full max-h-full object-contain"
        />

        {/* Navigation */}
        <Button
          variant="ghost"
          size="icon"
          className="absolute left-4 top-1/2 -translate-y-1/2 text-white hover:bg-white/20"
          onClick={handlePrevious}
        >
          <ChevronLeft className="h-6 w-6" />
        </Button>

        <Button
          variant="ghost"
          size="icon"
          className="absolute right-4 top-1/2 -translate-y-1/2 text-white hover:bg-white/20"
          onClick={handleNext}
        >
          <ChevronRight className="h-6 w-6" />
        </Button>

        {/* Counter */}
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-black/50 text-white px-3 py-1 rounded">
          {currentIndex + 1} of {images.length}
        </div>
      </div>
    </UnifiedModal>
  )
}
```

**Implementation Steps:**
1. Create ConfirmationModal component
2. Implement FormModal with form integration
3. Create DataDisplayModal for data presentation
4. Implement ImageGalleryModal for photo viewing
5. Add keyboard navigation and accessibility
6. Test all modal types

### Task 3: Create Modal Management System
**File:** `hooks/use-modal-manager.ts`
**Estimated Time:** 2 days

```typescript
// Modal management system for complex modal interactions
export interface ModalManagerConfig {
  maxConcurrent?: number
  stackable?: boolean
  persistentModals?: string[]
}

export interface ManagedModal {
  id: string
  component: React.ComponentType<any>
  props: any
  zIndex: number
  persistent: boolean
}

export function useModalManager(config: ModalManagerConfig = {}) {
  const [modals, setModals] = useState<ManagedModal[]>([])
  const [baseZIndex] = useState(1000)

  const openModal = useCallback((
    id: string,
    component: React.ComponentType<any>,
    props: any = {},
    options: { persistent?: boolean } = {}
  ) => {
    setModals(prev => {
      // Check if modal already exists
      const existingIndex = prev.findIndex(modal => modal.id === id)
      if (existingIndex !== -1) {
        // Update existing modal
        const updated = [...prev]
        updated[existingIndex] = {
          ...updated[existingIndex],
          props: { ...updated[existingIndex].props, ...props }
        }
        return updated
      }

      // Add new modal
      const newModal: ManagedModal = {
        id,
        component,
        props,
        zIndex: baseZIndex + prev.length,
        persistent: options.persistent || config.persistentModals?.includes(id) || false
      }

      return [...prev, newModal]
    })
  }, [baseZIndex, config.persistentModals])

  const closeModal = useCallback((id: string) => {
    setModals(prev => prev.filter(modal => modal.id !== id))
  }, [])

  const closeAllModals = useCallback((force = false) => {
    setModals(prev => force ? [] : prev.filter(modal => modal.persistent))
  }, [])

  const isModalOpen = useCallback((id: string) => {
    return modals.some(modal => modal.id === id)
  }, [modals])

  const getTopModal = useCallback(() => {
    return modals[modals.length - 1] || null
  }, [modals])

  return {
    modals,
    openModal,
    closeModal,
    closeAllModals,
    isModalOpen,
    getTopModal,
    modalCount: modals.length
  }
}

// Modal provider for global modal management
export function ModalProvider({ children }: { children: React.ReactNode }) {
  const modalManager = useModalManager()

  return (
    <ModalManagerContext.Provider value={modalManager}>
      {children}
      {modalManager.modals.map(modal => {
        const ModalComponent = modal.component
        return (
          <div key={modal.id} style={{ zIndex: modal.zIndex }}>
            <ModalComponent
              {...modal.props}
              onClose={() => modalManager.closeModal(modal.id)}
            />
          </div>
        )
      })}
    </ModalManagerContext.Provider>
  )
}
```

**Implementation Steps:**
1. Create modal manager hook
2. Implement modal stacking and z-index management
3. Add persistent modal support
4. Create modal provider for global management
5. Add modal lifecycle management
6. Test concurrent modal scenarios

## Testing Requirements

### Unit Tests
- Modal hook functionality
- Modal component behavior
- Keyboard navigation
- Accessibility features

### Integration Tests
- Modal stacking behavior
- Form integration in modals
- Data loading in modals
- Modal manager functionality

### E2E Tests
- Complete modal workflows
- Keyboard navigation
- Mobile modal behavior
- Performance with multiple modals

## Success Criteria

### Code Quality
- [ ] All modals use unified modal system
- [ ] No duplicated modal structure code
- [ ] Consistent modal behavior across application
- [ ] Comprehensive accessibility support

### User Experience
- [ ] Consistent modal interactions
- [ ] Proper keyboard navigation
- [ ] Mobile-responsive modal behavior
- [ ] Smooth animations and transitions

### Developer Experience
- [ ] Easy to create new modals
- [ ] Type-safe modal props
- [ ] Reusable modal patterns
- [ ] Clear modal management

## Deliverables

1. **Unified Modal System** - Complete modal framework
2. **Specialized Modal Types** - Confirmation, form, data, gallery modals
3. **Modal Manager** - Global modal management system
4. **Migrated Modals** - All existing modals using new system
5. **Accessibility Features** - Full keyboard and screen reader support
6. **Comprehensive Tests** - Unit, integration, and E2E tests
7. **Documentation** - Usage guides and examples
8. **Performance Optimization** - Optimized rendering and animations

---

**Phase Owner:** Frontend Component Specialist Agent  
**Review Required:** Senior Frontend Developer + Accessibility Review  
**Next Phase:** Phase 5 - Data Fetching Standardization
