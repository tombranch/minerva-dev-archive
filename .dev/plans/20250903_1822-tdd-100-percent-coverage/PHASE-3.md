# Phase 3: Frontend Component Testing

**Objective**: Achieve 100% React component test coverage using TDD methodology
**Duration**: 5-7 days
**Priority**: 🟡 MEDIUM - UI/UX quality assurance
**Success Criteria**: All 293 components tested, interaction coverage complete, accessibility validated

## 📋 Phase Overview

This is the most comprehensive phase, addressing the current 29% component coverage gap by systematically testing all 293 React components. Using TDD methodology, we'll implement component tests that validate rendering, user interactions, state management, accessibility, and edge cases. This phase will establish a robust frontend testing culture and ensure UI reliability.

## 🎯 Phase Objectives

1. **Component Coverage** (293 components)
   - Test all components systematically
   - Validate props and state management
   - Test user interactions
   - Verify edge cases and error states

2. **Interaction Testing**
   - Form validation and submission
   - Click handlers and events
   - Keyboard navigation
   - Drag and drop operations

3. **Visual Testing**
   - Responsive design validation
   - Theme switching (light/dark)
   - Loading states
   - Error boundaries

4. **Accessibility Testing**
   - WCAG compliance
   - Keyboard navigation
   - Screen reader compatibility
   - Focus management

## 🔧 Component Testing Strategy

### Component Categories & Priorities

**Priority 1: Core UI Components** (45 components)
```
components/ui/
├── button.tsx
├── input.tsx
├── select.tsx
├── dialog.tsx
├── card.tsx
├── form.tsx
├── table.tsx
├── tabs.tsx
└── ... (37 more)
```

**Priority 2: Feature Components** (85 components)
```
components/
├── photos/ (25 components)
│   ├── photo-grid.tsx
│   ├── photo-card.tsx
│   ├── photo-detail-modal.tsx
│   └── ...
├── upload/ (15 components)
│   ├── upload-dropzone.tsx
│   ├── upload-progress.tsx
│   └── ...
├── auth/ (10 components)
├── organization/ (15 components)
├── ai/ (10 components)
└── platform/ (10 components)
```

**Priority 3: Page Components** (50 components)
```
app/
├── (protected)/
│   ├── dashboard/
│   ├── photos/
│   ├── ai-management/
│   └── ...
└── (auth)/
    ├── login/
    └── signup/
```

**Priority 4: Utility Components** (113 components)
- Layouts, wrappers, providers
- Error boundaries
- Loading states
- Empty states

### TDD Template for Components

```typescript
// tests/components/[component-name].test.tsx
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { axe, toHaveNoViolations } from 'vitest-axe'

expect.extend(toHaveNoViolations)

describe('[ComponentName] - TDD Implementation', () => {
  const user = userEvent.setup()
  
  describe('Rendering', () => {
    // RED: Test component renders with required props
    it('should render with required props', () => {
      render(<Component requiredProp="value" />)
      expect(screen.getByRole('button')).toBeInTheDocument()
    })
    
    it('should render with optional props', () => {
      render(<Component 
        requiredProp="value"
        optionalProp="optional"
        variant="primary"
      />)
      expect(screen.getByText('optional')).toBeInTheDocument()
    })
    
    it('should handle conditional rendering', () => {
      const { rerender } = render(<Component show={false} />)
      expect(screen.queryByRole('dialog')).not.toBeInTheDocument()
      
      rerender(<Component show={true} />)
      expect(screen.getByRole('dialog')).toBeInTheDocument()
    })
  })
  
  describe('Interactions', () => {
    it('should handle click events', async () => {
      const handleClick = vi.fn()
      render(<Component onClick={handleClick} />)
      
      await user.click(screen.getByRole('button'))
      expect(handleClick).toHaveBeenCalledOnce()
    })
    
    it('should handle form submission', async () => {
      const handleSubmit = vi.fn()
      render(<FormComponent onSubmit={handleSubmit} />)
      
      await user.type(screen.getByLabelText('Name'), 'Test User')
      await user.click(screen.getByRole('button', { name: 'Submit' }))
      
      expect(handleSubmit).toHaveBeenCalledWith({
        name: 'Test User'
      })
    })
    
    it('should handle keyboard navigation', async () => {
      render(<Component />)
      const button = screen.getByRole('button')
      
      await user.tab()
      expect(button).toHaveFocus()
      
      await user.keyboard('{Enter}')
      // Verify Enter key behavior
    })
  })
  
  describe('State Management', () => {
    it('should update state correctly', async () => {
      render(<StatefulComponent />)
      
      expect(screen.getByText('Count: 0')).toBeInTheDocument()
      
      await user.click(screen.getByRole('button', { name: 'Increment' }))
      expect(screen.getByText('Count: 1')).toBeInTheDocument()
    })
    
    it('should sync with external store', async () => {
      const { result } = renderHook(() => useStore())
      render(<ConnectedComponent />)
      
      act(() => {
        result.current.updateValue('new value')
      })
      
      await waitFor(() => {
        expect(screen.getByText('new value')).toBeInTheDocument()
      })
    })
  })
  
  describe('Error Handling', () => {
    it('should display error states', () => {
      render(<Component error="Something went wrong" />)
      expect(screen.getByRole('alert')).toHaveTextContent('Something went wrong')
    })
    
    it('should handle loading states', () => {
      render(<Component loading={true} />)
      expect(screen.getByRole('progressbar')).toBeInTheDocument()
    })
    
    it('should handle empty states', () => {
      render(<Component data={[]} />)
      expect(screen.getByText('No data available')).toBeInTheDocument()
    })
  })
  
  describe('Accessibility', () => {
    it('should have no accessibility violations', async () => {
      const { container } = render(<Component />)
      const results = await axe(container)
      expect(results).toHaveNoViolations()
    })
    
    it('should have proper ARIA labels', () => {
      render(<Component />)
      expect(screen.getByRole('button')).toHaveAttribute('aria-label')
      expect(screen.getByRole('navigation')).toHaveAttribute('aria-label', 'Main navigation')
    })
    
    it('should manage focus correctly', async () => {
      render(<ModalComponent open={true} />)
      
      // Focus should be trapped in modal
      const closeButton = screen.getByRole('button', { name: 'Close' })
      expect(closeButton).toHaveFocus()
    })
  })
  
  describe('Responsive Design', () => {
    it('should render mobile layout', () => {
      window.innerWidth = 375
      render(<Component />)
      
      expect(screen.getByTestId('mobile-menu')).toBeInTheDocument()
      expect(screen.queryByTestId('desktop-menu')).not.toBeInTheDocument()
    })
    
    it('should render desktop layout', () => {
      window.innerWidth = 1920
      render(<Component />)
      
      expect(screen.getByTestId('desktop-menu')).toBeInTheDocument()
      expect(screen.queryByTestId('mobile-menu')).not.toBeInTheDocument()
    })
  })
})
```

## 📦 Component Testing Implementation

### Task 1: Core UI Components (45 components)

```typescript
// tests/components/ui/button.test.tsx
describe('Button Component - TDD', () => {
  it('should render all variants', () => {
    const variants = ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link']
    
    variants.forEach(variant => {
      const { container } = render(<Button variant={variant}>Test</Button>)
      expect(container.firstChild).toHaveClass(`variant-${variant}`)
    })
  })
  
  it('should handle disabled state', async () => {
    const handleClick = vi.fn()
    render(<Button disabled onClick={handleClick}>Disabled</Button>)
    
    const button = screen.getByRole('button')
    expect(button).toBeDisabled()
    
    await user.click(button)
    expect(handleClick).not.toHaveBeenCalled()
  })
  
  it('should show loading state', () => {
    render(<Button loading>Loading</Button>)
    
    expect(screen.getByRole('button')).toHaveAttribute('aria-busy', 'true')
    expect(screen.getByTestId('spinner')).toBeInTheDocument()
  })
})
```

### Task 2: Photo Components (25 components)

```typescript
// tests/components/photos/photo-grid.test.tsx
describe('PhotoGrid Component - TDD', () => {
  const mockPhotos = [
    { _id: '1', title: 'Photo 1', url: '/photo1.jpg', tags: ['safety'] },
    { _id: '2', title: 'Photo 2', url: '/photo2.jpg', tags: ['hazard'] }
  ]
  
  it('should render photo grid with items', () => {
    render(<PhotoGrid photos={mockPhotos} />)
    
    expect(screen.getAllByRole('img')).toHaveLength(2)
    expect(screen.getByAltText('Photo 1')).toBeInTheDocument()
  })
  
  it('should handle photo selection', async () => {
    const onSelect = vi.fn()
    render(<PhotoGrid photos={mockPhotos} onSelect={onSelect} />)
    
    await user.click(screen.getByAltText('Photo 1'))
    expect(onSelect).toHaveBeenCalledWith(mockPhotos[0])
  })
  
  it('should support multi-select mode', async () => {
    const onMultiSelect = vi.fn()
    render(<PhotoGrid 
      photos={mockPhotos} 
      multiSelect 
      onMultiSelect={onMultiSelect}
    />)
    
    await user.click(screen.getByAltText('Photo 1'))
    await user.click(screen.getByAltText('Photo 2'))
    
    expect(onMultiSelect).toHaveBeenCalledWith([
      mockPhotos[0]._id,
      mockPhotos[1]._id
    ])
  })
  
  it('should lazy load images', () => {
    render(<PhotoGrid photos={mockPhotos} lazyLoad />)
    
    const images = screen.getAllByRole('img')
    images.forEach(img => {
      expect(img).toHaveAttribute('loading', 'lazy')
    })
  })
})
```

### Task 3: Upload Components (15 components)

```typescript
// tests/components/upload/upload-dropzone.test.tsx
describe('UploadDropzone Component - TDD', () => {
  it('should accept file drops', async () => {
    const onDrop = vi.fn()
    render(<UploadDropzone onDrop={onDrop} />)
    
    const dropzone = screen.getByTestId('dropzone')
    const file = new File(['test'], 'test.jpg', { type: 'image/jpeg' })
    
    await user.upload(dropzone, file)
    
    expect(onDrop).toHaveBeenCalledWith([file])
  })
  
  it('should validate file types', async () => {
    const onError = vi.fn()
    render(<UploadDropzone 
      accept={['image/jpeg', 'image/png']}
      onError={onError}
    />)
    
    const file = new File(['test'], 'test.pdf', { type: 'application/pdf' })
    await user.upload(screen.getByTestId('dropzone'), file)
    
    expect(onError).toHaveBeenCalledWith('Invalid file type')
  })
  
  it('should show drag over state', async () => {
    render(<UploadDropzone />)
    const dropzone = screen.getByTestId('dropzone')
    
    fireEvent.dragEnter(dropzone)
    expect(dropzone).toHaveClass('drag-over')
    
    fireEvent.dragLeave(dropzone)
    expect(dropzone).not.toHaveClass('drag-over')
  })
})
```

### Task 4: Form Components

```typescript
// tests/components/forms/photo-upload-form.test.tsx
describe('PhotoUploadForm - TDD', () => {
  it('should validate required fields', async () => {
    render(<PhotoUploadForm />)
    
    await user.click(screen.getByRole('button', { name: 'Upload' }))
    
    expect(screen.getByText('Title is required')).toBeInTheDocument()
    expect(screen.getByText('Please select a file')).toBeInTheDocument()
  })
  
  it('should submit form with valid data', async () => {
    const onSubmit = vi.fn()
    render(<PhotoUploadForm onSubmit={onSubmit} />)
    
    await user.type(screen.getByLabelText('Title'), 'Test Photo')
    await user.type(screen.getByLabelText('Description'), 'Test description')
    await user.selectOptions(screen.getByLabelText('Category'), 'safety')
    
    const file = new File(['test'], 'test.jpg', { type: 'image/jpeg' })
    await user.upload(screen.getByLabelText('File'), file)
    
    await user.click(screen.getByRole('button', { name: 'Upload' }))
    
    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        title: 'Test Photo',
        description: 'Test description',
        category: 'safety',
        file: file
      })
    })
  })
})
```

### Task 5: Complex Component Interactions

```typescript
// tests/components/photos/photo-detail-modal.test.tsx
describe('PhotoDetailModal - TDD', () => {
  const mockPhoto = {
    _id: '1',
    title: 'Test Photo',
    description: 'Test description',
    url: '/test.jpg',
    tags: ['safety', 'equipment'],
    aiAnalysis: {
      labels: ['hard hat', 'safety vest'],
      confidence: 0.95
    }
  }
  
  it('should display photo details', () => {
    render(<PhotoDetailModal photo={mockPhoto} open={true} />)
    
    expect(screen.getByText('Test Photo')).toBeInTheDocument()
    expect(screen.getByText('Test description')).toBeInTheDocument()
    expect(screen.getByRole('img')).toHaveAttribute('src', '/test.jpg')
  })
  
  it('should allow editing in edit mode', async () => {
    render(<PhotoDetailModal photo={mockPhoto} open={true} canEdit />)
    
    await user.click(screen.getByRole('button', { name: 'Edit' }))
    
    const titleInput = screen.getByLabelText('Title')
    await user.clear(titleInput)
    await user.type(titleInput, 'Updated Title')
    
    await user.click(screen.getByRole('button', { name: 'Save' }))
    
    expect(screen.getByText('Updated Title')).toBeInTheDocument()
  })
  
  it('should handle image zoom', async () => {
    render(<PhotoDetailModal photo={mockPhoto} open={true} />)
    
    const image = screen.getByRole('img')
    await user.click(image)
    
    expect(screen.getByTestId('zoomed-image')).toBeInTheDocument()
    
    await user.keyboard('{Escape}')
    expect(screen.queryByTestId('zoomed-image')).not.toBeInTheDocument()
  })
  
  it('should navigate between photos', async () => {
    const photos = [mockPhoto, { ...mockPhoto, _id: '2', title: 'Photo 2' }]
    const { rerender } = render(
      <PhotoDetailModal 
        photo={photos[0]} 
        photos={photos}
        currentIndex={0}
        open={true} 
      />
    )
    
    await user.click(screen.getByRole('button', { name: 'Next' }))
    
    rerender(
      <PhotoDetailModal 
        photo={photos[1]} 
        photos={photos}
        currentIndex={1}
        open={true} 
      />
    )
    
    expect(screen.getByText('Photo 2')).toBeInTheDocument()
  })
})
```

## 📊 Testing Metrics & Coverage Goals

### Component Coverage Targets
| Category | Components | Current | Target | Priority |
|----------|------------|---------|---------|----------|
| UI Components | 45 | 5 (11%) | 45 (100%) | P1 |
| Photo Components | 25 | 8 (32%) | 25 (100%) | P1 |
| Upload Components | 15 | 3 (20%) | 15 (100%) | P1 |
| Auth Components | 10 | 2 (20%) | 10 (100%) | P2 |
| Organization | 15 | 0 (0%) | 15 (100%) | P2 |
| AI Components | 10 | 0 (0%) | 10 (100%) | P2 |
| Platform Admin | 10 | 0 (0%) | 10 (100%) | P3 |
| Page Components | 50 | 5 (10%) | 50 (100%) | P3 |
| Utility Components | 113 | 10 (9%) | 113 (100%) | P4 |
| **TOTAL** | **293** | **33 (11%)** | **293 (100%)** | - |

### Test Type Distribution
- **Render Tests**: 100% of components
- **Interaction Tests**: 100% of interactive components
- **State Tests**: 100% of stateful components
- **Accessibility Tests**: 100% of public-facing components
- **Responsive Tests**: 100% of layout components

## ✅ Implementation Checklist

### Day 1-2: Core Components
- [ ] Test all 45 UI components
- [ ] Create reusable test utilities
- [ ] Establish component test patterns
- [ ] Document best practices

### Day 3-4: Feature Components
- [ ] Test photo management components (25)
- [ ] Test upload components (15)
- [ ] Test auth components (10)
- [ ] Test organization components (15)

### Day 5-6: Complex Components
- [ ] Test AI components (10)
- [ ] Test platform admin components (10)
- [ ] Test page components (50)
- [ ] Test modal and dialog components

### Day 7: Integration & Polish
- [ ] Test utility components (113)
- [ ] Visual regression test setup
- [ ] Performance test components
- [ ] Documentation and cleanup

## 🔄 Verification Process

1. **Component Test Coverage**
   ```bash
   pnpm test:coverage components/
   # Expected: >95% coverage for all component files
   ```

2. **Accessibility Validation**
   ```bash
   pnpm test tests/components --grep="accessibility"
   # Expected: All accessibility tests passing
   ```

3. **Interaction Testing**
   ```bash
   pnpm test tests/components --grep="interaction"
   # Expected: All user interaction scenarios covered
   ```

4. **Visual Regression**
   ```bash
   pnpm test:visual
   # Expected: No unintended visual changes
   ```

## 📝 Implementation Notes

### TDD Workflow for Components
1. **RED**: Write test for component behavior
2. **GREEN**: Implement minimal component
3. **REFACTOR**: Optimize and enhance

### Testing Priorities
1. User-facing components first
2. Complex interaction components
3. Form and validation components
4. Layout and utility components

### Common Patterns
- Use Testing Library best practices
- Test user behavior, not implementation
- Mock external dependencies
- Use data-testid sparingly

---

**Phase 3 Status**: 📋 READY (Pending Phase 2 completion)
**Estimated Duration**: 5-7 days
**Dependencies**: Phase 1 & 2 complete
**Next Phase**: PHASE-4.md (Integration & Polish)
**Created**: September 3, 2025 - 18:22 Melbourne Time