# Phase 2: Foundation Stories Implementation
**Estimated Time:** 4-6 hours  
**Prerequisites:** Phase 1 (Core Setup) completed successfully  
**Status:** Ready for Implementation

## Overview

Phase 2 focuses on creating comprehensive documentation for the foundational UI components that form the basis of the Minerva design system. This phase establishes the component library documentation that will serve as the foundation for all subsequent feature-specific components.

## Objectives

### Primary Goals
- ✅ Document all shadcn/ui components with interactive examples
- ✅ Create design system token documentation
- ✅ Establish component API documentation patterns
- ✅ Set up theme switching and responsive testing
- ✅ Create comprehensive variant and size demonstrations

### Success Criteria
- All 20+ shadcn/ui components documented with stories
- Interactive controls for all component props
- Comprehensive variant demonstrations
- Theme switching works correctly for all components
- Responsive design validation for mobile/tablet/desktop
- Auto-generated documentation includes proper descriptions

## Scope Analysis

Based on the Minerva components directory, the following shadcn/ui components need documentation:

### Core UI Components (Priority 1)
- ✅ `button.tsx` - Multiple variants, sizes, states
- ✅ `input.tsx` - Text input with validation states
- ✅ `label.tsx` - Form labels with required/optional states
- ✅ `card.tsx` - Content containers with headers/footers
- ✅ `badge.tsx` - Status indicators and labels
- ✅ `avatar.tsx` - User profile images and placeholders
- ✅ `dialog.tsx` - Modal dialogs and confirmations
- ✅ `alert.tsx` - Success, warning, error notifications
- ✅ `select.tsx` - Dropdown selections with options
- ✅ `checkbox.tsx` - Form checkboxes with states

### Advanced UI Components (Priority 2)
- ✅ `dropdown-menu.tsx` - Context menus and actions
- ✅ `tabs.tsx` - Content organization and navigation
- ✅ `table.tsx` - Data display and sorting
- ✅ `progress.tsx` - Loading and progress indicators
- ✅ `tooltip.tsx` - Contextual information overlays
- ✅ `calendar.tsx` - Date selection interface
- ✅ `popover.tsx` - Floating content containers
- ✅ `sheet.tsx` - Slide-out panels and drawers
- ✅ `scroll-area.tsx` - Custom scrollable containers
- ✅ `separator.tsx` - Visual content dividers

### Specialized Components (Priority 3)
- ✅ `command.tsx` - Command palette interface
- ✅ `navigation-menu.tsx` - Site navigation components
- ✅ `collapsible.tsx` - Expandable content sections
- ✅ `radio-group.tsx` - Single-selection form controls
- ✅ `slider.tsx` - Range input controls
- ✅ `switch.tsx` - Toggle controls
- ✅ `textarea.tsx` - Multi-line text input

## Implementation Strategy

### Story Development Pattern

Each component story will follow this consistent structure:

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { ComponentName } from './component-name';

const meta: Meta<typeof ComponentName> = {
  title: 'UI/ComponentName',
  component: ComponentName,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'Component description with usage guidance.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    // Comprehensive prop controls
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

// Standard story variants:
export const Default: Story = { /* ... */ };
export const Variants: Story = { /* ... */ };
export const Sizes: Story = { /* ... */ };
export const States: Story = { /* ... */ };
export const Interactive: Story = { /* ... */ };
```

## Phase 2 Implementation Steps

### Step 1: Core UI Components (2.5 hours)

#### Button Component Stories Enhancement
Expand the existing button story created in Phase 1:

**File:** `components/ui/button.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { fn } from '@storybook/test';
import { Button } from './button';
import { 
  Download, 
  ArrowRight, 
  Loader2, 
  Heart, 
  Share,
  Settings 
} from 'lucide-react';

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A versatile button component built with Radix UI and Tailwind CSS. Supports multiple variants, sizes, and states for different use cases throughout the Minerva application.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: { type: 'select' },
      options: ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link'],
      description: 'Visual style variant of the button',
    },
    size: {
      control: { type: 'select' },
      options: ['default', 'sm', 'lg', 'icon'],
      description: 'Size of the button',
    },
    disabled: {
      control: 'boolean',
      description: 'Whether the button is disabled',
    },
    asChild: {
      control: 'boolean',
      description: 'Render as child component',
    },
  },
  args: {
    onClick: fn(),
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    children: 'Default Button',
  },
};

export const Variants: Story = {
  render: () => (
    <div className="flex flex-wrap gap-4">
      <Button variant="default">Default</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="destructive">Destructive</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="link">Link</Button>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Different visual variants available for buttons.',
      },
    },
  },
};

export const Sizes: Story = {
  render: () => (
    <div className="flex items-center gap-4">
      <Button size="sm">Small</Button>
      <Button size="default">Default</Button>
      <Button size="lg">Large</Button>
      <Button size="icon">
        <Settings className="h-4 w-4" />
      </Button>
    </div>
  ),
};

export const WithIcons: Story = {
  render: () => (
    <div className="flex flex-wrap gap-4">
      <Button>
        <Download className="mr-2 h-4 w-4" />
        Download
      </Button>
      <Button variant="outline">
        Continue
        <ArrowRight className="ml-2 h-4 w-4" />
      </Button>
      <Button variant="secondary">
        <Heart className="mr-2 h-4 w-4" />
        Like
      </Button>
      <Button variant="ghost" size="icon">
        <Share className="h-4 w-4" />
      </Button>
    </div>
  ),
};

export const LoadingStates: Story = {
  render: () => (
    <div className="flex gap-4">
      <Button disabled>
        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
        Loading...
      </Button>
      <Button variant="outline" disabled>
        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
        Processing
      </Button>
    </div>
  ),
};

export const States: Story = {
  render: () => (
    <div className="grid grid-cols-3 gap-4">
      <div className="space-y-2">
        <p className="text-sm font-medium">Normal</p>
        <Button>Normal</Button>
        <Button variant="outline">Outline</Button>
        <Button variant="ghost">Ghost</Button>
      </div>
      <div className="space-y-2">
        <p className="text-sm font-medium">Hover (simulate)</p>
        <Button className="hover:opacity-90">Hover</Button>
        <Button variant="outline" className="hover:bg-accent">Outline Hover</Button>
        <Button variant="ghost" className="hover:bg-accent">Ghost Hover</Button>
      </div>
      <div className="space-y-2">
        <p className="text-sm font-medium">Disabled</p>
        <Button disabled>Disabled</Button>
        <Button variant="outline" disabled>Disabled</Button>
        <Button variant="ghost" disabled>Disabled</Button>
      </div>
    </div>
  ),
};

export const Interactive: Story = {
  args: {
    children: 'Click me!',
    onClick: fn(),
  },
  parameters: {
    docs: {
      description: {
        story: 'Interactive button with click handler. Check the Actions panel to see click events.',
      },
    },
  },
};
```

#### Input Component Stories
**File:** `components/ui/input.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { Input } from './input';
import { Label } from './label';
import { Search, Eye, EyeOff, Mail, Lock } from 'lucide-react';
import { useState } from 'react';

const meta: Meta<typeof Input> = {
  title: 'UI/Input',
  component: Input,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'Text input component with support for various types, states, and validation. Used throughout Minerva for form inputs and search functionality.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    type: {
      control: { type: 'select' },
      options: ['text', 'email', 'password', 'search', 'number', 'tel', 'url'],
    },
    placeholder: {
      control: 'text',
    },
    disabled: {
      control: 'boolean',
    },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  args: {
    placeholder: 'Enter text...',
  },
};

export const Types: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <div>
        <Label>Text Input</Label>
        <Input type="text" placeholder="Text input" />
      </div>
      <div>
        <Label>Email Input</Label>
        <Input type="email" placeholder="email@example.com" />
      </div>
      <div>
        <Label>Password Input</Label>
        <Input type="password" placeholder="Password" />
      </div>
      <div>
        <Label>Search Input</Label>
        <Input type="search" placeholder="Search..." />
      </div>
      <div>
        <Label>Number Input</Label>
        <Input type="number" placeholder="123" />
      </div>
    </div>
  ),
};

export const WithIcons: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <div className="relative">
        <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
        <Input placeholder="Search photos..." className="pl-10" />
      </div>
      <div className="relative">
        <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
        <Input type="email" placeholder="Email" className="pl-10" />
      </div>
      <div className="relative">
        <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
        <Input type="password" placeholder="Password" className="pl-10" />
      </div>
    </div>
  ),
};

export const States: Story = {
  render: () => (
    <div className="space-y-4 w-80">
      <div>
        <Label>Normal</Label>
        <Input placeholder="Normal input" />
      </div>
      <div>
        <Label>Focused (simulate)</Label>
        <Input placeholder="Focused input" className="ring-2 ring-ring ring-offset-2" />
      </div>
      <div>
        <Label>Disabled</Label>
        <Input placeholder="Disabled input" disabled />
      </div>
      <div>
        <Label>Error State</Label>
        <Input 
          placeholder="Invalid input" 
          className="border-destructive focus-visible:ring-destructive" 
        />
      </div>
    </div>
  ),
};

export const ValidationExample: Story = {
  render: () => {
    const [email, setEmail] = useState('');
    const [error, setError] = useState('');
    
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      const value = e.target.value;
      setEmail(value);
      
      if (value && !value.includes('@')) {
        setError('Please enter a valid email address');
      } else {
        setError('');
      }
    };
    
    return (
      <div className="space-y-2 w-80">
        <Label htmlFor="email-validation">Email Address</Label>
        <Input
          id="email-validation"
          type="email"
          placeholder="Enter your email"
          value={email}
          onChange={handleChange}
          className={error ? 'border-destructive focus-visible:ring-destructive' : ''}
        />
        {error && (
          <p className="text-sm text-destructive">{error}</p>
        )}
      </div>
    );
  },
};
```

Continue with Card, Badge, and Avatar components following the same comprehensive pattern...

### Step 2: Advanced UI Components (1.5 hours)

Focus on more complex interactive components like Dialog, Select, Dropdown Menu, and Tabs.

### Step 3: Theme and Design System Documentation (1 hour)

Create comprehensive design system documentation:

**File:** `components/design-system/design-tokens.stories.mdx`

```mdx
import { Meta } from '@storybook/blocks';

<Meta title="Design System/Design Tokens" />

# Design Tokens

The Minerva design system uses a comprehensive set of design tokens for consistent styling across the application.

## Colors

### Brand Colors
- Primary: Used for main actions and brand elements
- Secondary: Supporting actions and backgrounds
- Accent: Highlights and special elements

### Semantic Colors
- Success: Positive feedback and success states
- Warning: Caution and warning states  
- Destructive: Error states and dangerous actions
- Muted: Secondary text and subtle elements

## Typography

### Font Families
- Sans: Primary interface font
- Mono: Code and data display

### Font Sizes
- xs: 12px - Small labels and captions
- sm: 14px - Secondary text
- base: 16px - Body text
- lg: 18px - Large body text
- xl: 20px - Small headings
- 2xl: 24px - Medium headings
- 3xl: 30px - Large headings

## Spacing

Based on 4px base unit:
- 1: 4px
- 2: 8px  
- 3: 12px
- 4: 16px
- 5: 20px
- 6: 24px
- 8: 32px
- 10: 40px
- 12: 48px
- 16: 64px

## Component Patterns

### Interactive States
- Default: Base component state
- Hover: Mouse hover feedback
- Focus: Keyboard focus indicator
- Active: Pressed/selected state
- Disabled: Non-interactive state
```

## Testing & Validation Strategy

### Visual Testing Checklist
For each component story:
- [ ] **Responsive Design**: Test on mobile, tablet, desktop viewports
- [ ] **Theme Switching**: Verify light/dark theme compatibility
- [ ] **Interactive States**: Test hover, focus, active, disabled states
- [ ] **Accessibility**: No A11y violations in addon panel
- [ ] **Documentation**: Auto-generated docs are comprehensive

### Cross-Browser Validation
- [ ] **Chrome**: All stories render correctly
- [ ] **Firefox**: All stories render correctly  
- [ ] **Safari**: All stories render correctly (if available)

### Performance Considerations
- [ ] **Load Time**: Stories load within 2 seconds
- [ ] **Interaction**: Controls respond immediately
- [ ] **Memory**: No memory leaks during development

## Deliverables

### Story Files
- ✅ 10+ comprehensive component stories with multiple variants
- ✅ Interactive controls for all component props
- ✅ Comprehensive state demonstrations
- ✅ Usage examples and best practices

### Documentation
- ✅ Design system token documentation
- ✅ Component API documentation via autodocs
- ✅ Usage guidelines and best practices
- ✅ Theme and responsive design patterns

### Quality Assurance
- ✅ Zero TypeScript errors
- ✅ Zero accessibility violations
- ✅ Consistent documentation patterns
- ✅ Comprehensive visual testing

## Next Steps

After Phase 2 completion:

1. **Validate Foundation**: Ensure all shadcn/ui components work correctly
2. **Team Review**: Demo comprehensive component library to team
3. **Design Review**: Validate design system documentation with design team
4. **Begin Phase 3**: Start creating stories for feature-specific components

---

**Note**: Phase 2 establishes the foundation component library that will be referenced throughout the application. Invest time in creating comprehensive, high-quality stories that will serve as the reference implementation for all components.