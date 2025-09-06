# Phase 2: Design System Documentation
**Component:** Foundation Design System  
**Format:** MDX Stories for comprehensive design token documentation  
**Estimated Time:** 1 hour

## Overview

This phase creates comprehensive design system documentation that serves as the foundation for all component development in Minerva. The design system establishes consistent visual language, interaction patterns, and implementation guidelines.

## Design System Files Structure

### Create these MDX documentation files:

```
components/design-system/
├── design-tokens.stories.mdx           # Color, typography, spacing tokens
├── component-patterns.stories.mdx      # Common UI patterns and layouts  
├── accessibility-guidelines.stories.mdx # A11y standards and examples
├── responsive-design.stories.mdx       # Breakpoints and responsive patterns
└── theme-system.stories.mdx           # Light/dark theme implementation
```

## Implementation Guide

### 1. Design Tokens Documentation

**File:** `components/design-system/design-tokens.stories.mdx`

```mdx
import { Meta, ColorPalette, ColorItem, Typeset, IconGallery } from '@storybook/blocks';

<Meta title="Design System/Design Tokens" />

# Minerva Design System Tokens

The Minerva design system uses a comprehensive set of design tokens to ensure consistency across 
the machine safety photo organizer interface. These tokens are built on Tailwind CSS v4 and 
optimized for industrial applications.

## Color System

### Brand Colors

Our brand colors reflect the industrial safety focus while maintaining approachability for daily use.

<ColorPalette>
  <ColorItem
    title="Primary"
    subtitle="Main brand and action color"
    colors={{
      'Primary 50': 'hsl(var(--primary)/0.05)',
      'Primary 100': 'hsl(var(--primary)/0.1)', 
      'Primary 500': 'hsl(var(--primary))',
      'Primary 600': 'hsl(var(--primary)/0.9)',
      'Primary 900': 'hsl(var(--primary)/0.8)',
    }}
  />
  <ColorItem
    title="Secondary"
    subtitle="Supporting actions and backgrounds"
    colors={{
      'Secondary 50': 'hsl(var(--secondary)/0.05)',
      'Secondary 100': 'hsl(var(--secondary)/0.1)',
      'Secondary 500': 'hsl(var(--secondary))',
      'Secondary 600': 'hsl(var(--secondary)/0.9)', 
      'Secondary 900': 'hsl(var(--secondary)/0.8)',
    }}
  />
</ColorPalette>

### Semantic Colors

Safety-focused semantic colors for clear communication of status and actions.

<ColorPalette>
  <ColorItem
    title="Success"
    subtitle="Safe conditions, successful operations"
    colors={{
      'Success Light': '#22c55e',
      'Success': '#16a34a', 
      'Success Dark': '#15803d',
    }}
  />
  <ColorItem
    title="Warning"  
    subtitle="Caution states, attention needed"
    colors={{
      'Warning Light': '#f59e0b',
      'Warning': '#d97706',
      'Warning Dark': '#b45309',
    }}
  />
  <ColorItem
    title="Danger"
    subtitle="Unsafe conditions, critical errors"
    colors={{
      'Danger Light': '#ef4444',
      'Danger': '#dc2626', 
      'Danger Dark': '#b91c1c',
    }}
  />
</ColorPalette>

### Neutral Colors

Carefully balanced neutrals for text, backgrounds, and UI elements.

<ColorPalette>
  <ColorItem
    title="Backgrounds"
    subtitle="Primary background colors"
    colors={{
      'Background': 'hsl(var(--background))',
      'Card': 'hsl(var(--card))',
      'Popover': 'hsl(var(--popover))',
      'Muted': 'hsl(var(--muted))',
    }}
  />
  <ColorItem
    title="Foregrounds" 
    subtitle="Text and icon colors"
    colors={{
      'Foreground': 'hsl(var(--foreground))',
      'Card Foreground': 'hsl(var(--card-foreground))',
      'Popover Foreground': 'hsl(var(--popover-foreground))',
      'Muted Foreground': 'hsl(var(--muted-foreground))',
    }}
  />
</ColorPalette>

## Typography System

### Font Families

```css
/* Primary Interface Font */
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;

/* Monospace Font (for data/code) */
font-family: ui-monospace, SFMono-Regular, "SF Mono", Monaco, Consolas, monospace;
```

### Type Scale

<Typeset
  fontFamily="-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
  fontSizes={[
    '12px (xs) - Labels, captions, fine print',
    '14px (sm) - Secondary text, metadata', 
    '16px (base) - Body text, form inputs',
    '18px (lg) - Large body text, important info',
    '20px (xl) - Small headings, card titles',
    '24px (2xl) - Section headings',
    '30px (3xl) - Page headings', 
    '36px (4xl) - Hero headings',
  ]}
  fontWeight={400}
  sampleText="Minerva Machine Safety Photo Organizer"
/>

### Font Weights

- **400 (Normal)**: Body text, descriptions, labels
- **500 (Medium)**: Emphasized text, button text
- **600 (Semibold)**: Headings, card titles, important labels
- **700 (Bold)**: Primary headings, critical information

## Spacing System

Based on 4px base unit for consistent spacing and rhythm.

```
1 = 4px    - Fine spacing, icon margins
2 = 8px    - Small gaps, tight spacing  
3 = 12px   - Medium-small spacing
4 = 16px   - Standard spacing, padding
5 = 20px   - Medium spacing
6 = 24px   - Large spacing, section gaps
8 = 32px   - Extra large spacing
10 = 40px  - Section spacing
12 = 48px  - Large section spacing
16 = 64px  - Major layout spacing
20 = 80px  - Hero spacing
24 = 96px  - Extra large layout spacing
```

### Common Spacing Patterns

- **Component Padding**: 16px (space-4)
- **Card Padding**: 24px (space-6) 
- **Section Gaps**: 32px (space-8)
- **Page Margins**: 40px (space-10)
- **Element Margins**: 8px (space-2) to 16px (space-4)

## Sizing System

### Component Sizes

```
xs = 20px   - Extra small buttons, icons
sm = 24px   - Small buttons, compact UI
md = 32px   - Default button size
lg = 40px   - Large buttons, important actions  
xl = 48px   - Extra large buttons, hero CTAs
```

### Icon Sizes

```
3 = 12px    - Tiny icons, indicators
4 = 16px    - Standard icons (most common)
5 = 20px    - Medium icons  
6 = 24px    - Large icons
8 = 32px    - Extra large icons
10 = 40px   - Hero icons
```

## Border Radius

Consistent border radius for different component types:

```
none = 0px      - Sharp corners, data tables
sm = 2px        - Subtle rounding, small elements
md = 6px        - Standard components (default)
lg = 8px        - Cards, dialogs
xl = 12px       - Large containers
2xl = 16px      - Hero sections, major containers
full = 50%      - Pills, avatars, circular elements
```

## Shadows

Elevation system for depth and hierarchy:

```
sm: 0 1px 2px 0 rgb(0 0 0 / 0.05)              - Subtle elevation
md: 0 4px 6px -1px rgb(0 0 0 / 0.1)            - Standard elevation  
lg: 0 10px 15px -3px rgb(0 0 0 / 0.1)          - Prominent elevation
xl: 0 20px 25px -5px rgb(0 0 0 / 0.1)          - High elevation
2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25)       - Maximum elevation
```

## Animation & Transitions

### Duration

```
75ms    - Micro-interactions, hover states
150ms   - Standard transitions (default)
300ms   - Complex state changes
500ms   - Page transitions, large animations
700ms   - Hero animations, emphasis
```

### Easing

```
ease-linear     - Progress indicators
ease-in         - Exit animations  
ease-out        - Enter animations (default)
ease-in-out     - Complex transitions
```

## Usage Guidelines

### Color Usage

1. **Primary Color**: Use for main actions, links, and brand elements
2. **Secondary Color**: Use for supporting actions and backgrounds
3. **Success**: Safe conditions, completed actions, success states
4. **Warning**: Caution states, attention needed, non-critical issues  
5. **Danger**: Unsafe conditions, errors, destructive actions

### Typography Usage

1. **Headings**: Use semibold (600) weight for clear hierarchy
2. **Body Text**: Use normal (400) weight for readability
3. **Emphasis**: Use medium (500) weight for importance
4. **Labels**: Use normal (400) weight, small size (14px)

### Spacing Usage

1. **Consistent Rhythm**: Use spacing scale consistently
2. **Component Padding**: Standard 16px for most components
3. **Visual Grouping**: Use spacing to create clear content groups
4. **Breathing Room**: Ensure adequate spacing for industrial use

---

## Implementation in Code

### CSS Custom Properties

```css
:root {
  /* Brand Colors */
  --primary: 222.2 84% 4.9%;
  --primary-foreground: 210 40% 98%;
  
  /* Semantic Colors */
  --success: 142.1 76.2% 36.3%;
  --warning: 32.2 94.6% 43.7%;
  --destructive: 0 84.2% 60.2%;
  
  /* Typography */
  --font-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, Monaco, Consolas, monospace;
  
  /* Spacing (multiplied by 4px) */
  --spacing-1: 0.25rem;  /* 4px */
  --spacing-2: 0.5rem;   /* 8px */
  --spacing-4: 1rem;     /* 16px */
  --spacing-6: 1.5rem;   /* 24px */
}
```

### Tailwind Configuration

```javascript
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: 'hsl(var(--primary))',
        'primary-foreground': 'hsl(var(--primary-foreground))',
        success: 'hsl(var(--success))',
        warning: 'hsl(var(--warning))', 
        destructive: 'hsl(var(--destructive))',
      },
      fontFamily: {
        sans: 'var(--font-sans)',
        mono: 'var(--font-mono)',
      },
      spacing: {
        '1': 'var(--spacing-1)',
        '2': 'var(--spacing-2)', 
        '4': 'var(--spacing-4)',
        '6': 'var(--spacing-6)',
      },
    },
  },
};
```
```

### 2. Component Patterns Documentation

**File:** `components/design-system/component-patterns.stories.mdx`

```mdx
import { Meta } from '@storybook/blocks';
import { Button } from '../ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '../ui/card';
import { Input } from '../ui/input';
import { Label } from '../ui/label';
import { Badge } from '../ui/badge';

<Meta title="Design System/Component Patterns" />

# Component Patterns

Common UI patterns and layouts used throughout the Minerva application for consistency and efficiency.

## Form Patterns

### Basic Form Layout

Standard form layout with proper spacing and labeling:

<div className="w-full max-w-md space-y-4 p-4 border rounded-lg">
  <div>
    <Label htmlFor="email">Email Address</Label>
    <Input id="email" type="email" placeholder="user@company.com" />
  </div>
  <div>
    <Label htmlFor="password">Password</Label>  
    <Input id="password" type="password" placeholder="Enter password" />
  </div>
  <Button className="w-full">Sign In</Button>
</div>

### Form with Validation

Form showing validation states and error messaging:

<div className="w-full max-w-md space-y-4 p-4 border rounded-lg">
  <div>
    <Label htmlFor="email-error">Email Address *</Label>
    <Input 
      id="email-error" 
      type="email" 
      placeholder="user@company.com"
      className="border-destructive focus-visible:ring-destructive" 
    />
    <p className="text-sm text-destructive mt-1">Please enter a valid email address</p>
  </div>
  <div>
    <Label htmlFor="password-success">Password *</Label>  
    <Input 
      id="password-success" 
      type="password" 
      placeholder="Enter password"
      className="border-green-500 focus-visible:ring-green-500"
    />
    <p className="text-sm text-green-600 mt-1">Password meets requirements</p>
  </div>
  <Button className="w-full">Sign In</Button>
</div>

## Card Layouts

### Information Card

Standard information display pattern:

<Card className="w-full max-w-md">
  <CardHeader>
    <div className="flex justify-between items-start">
      <CardTitle>Conveyor Safety Inspection</CardTitle>
      <Badge>Active</Badge>
    </div>
  </CardHeader>
  <CardContent>
    <div className="space-y-2 text-sm">
      <div className="flex justify-between">
        <span className="text-muted-foreground">Photos</span>
        <span className="font-medium">247</span>
      </div>
      <div className="flex justify-between">
        <span className="text-muted-foreground">Location</span>
        <span className="font-medium">Building A</span>
      </div>
      <div className="flex justify-between">
        <span className="text-muted-foreground">Last Updated</span>
        <span className="font-medium">2 hours ago</span>
      </div>
    </div>
  </CardContent>
</Card>

### Action Card

Card with action buttons and clear call-to-action:

<Card className="w-full max-w-md">
  <CardContent className="pt-6">
    <div className="text-center space-y-4">
      <div className="w-12 h-12 bg-primary/10 rounded-lg flex items-center justify-center mx-auto">
        <svg className="w-6 h-6 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
        </svg>
      </div>
      <div>
        <h3 className="font-semibold">Create New Project</h3>
        <p className="text-sm text-muted-foreground">Start organizing your safety photos</p>
      </div>
      <Button className="w-full">Get Started</Button>
    </div>
  </CardContent>
</Card>

## Button Groups

### Primary Actions

Main action patterns with clear hierarchy:

<div className="flex gap-2">
  <Button>Primary Action</Button>
  <Button variant="outline">Secondary</Button>
  <Button variant="ghost">Tertiary</Button>
</div>

### Destructive Actions

Dangerous actions with appropriate styling:

<div className="flex gap-2">
  <Button variant="outline">Cancel</Button>
  <Button variant="destructive">Delete Project</Button>
</div>

## Status Indicators

### Badge Patterns

Common badge usage for status indication:

<div className="flex gap-2 flex-wrap">
  <Badge>Default</Badge>
  <Badge variant="secondary">Draft</Badge>
  <Badge variant="outline">Pending</Badge>
  <Badge variant="destructive">Error</Badge>
  <Badge className="bg-green-100 text-green-800 hover:bg-green-200">Success</Badge>
  <Badge className="bg-yellow-100 text-yellow-800 hover:bg-yellow-200">Warning</Badge>
</div>

## Loading States

### Button Loading

Loading states for async actions:

<div className="flex gap-2">
  <Button disabled>
    <svg className="animate-spin -ml-1 mr-3 h-4 w-4" fill="none" viewBox="0 0 24 24">
      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
    Uploading...
  </Button>
  <Button variant="outline" disabled>
    <svg className="animate-spin -ml-1 mr-3 h-4 w-4" fill="none" viewBox="0 0 24 24">
      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
    Processing
  </Button>
</div>

## Layout Patterns

### Two-Column Layout

Standard two-column information layout:

<div className="grid md:grid-cols-2 gap-4 p-4 border rounded-lg">
  <div>
    <h4 className="font-semibold mb-2">Project Details</h4>
    <div className="space-y-1 text-sm">
      <div>Name: Safety Inspection</div>
      <div>Type: Manufacturing</div>
      <div>Status: Active</div>
    </div>
  </div>
  <div>
    <h4 className="font-semibold mb-2">Statistics</h4>
    <div className="space-y-1 text-sm">
      <div>Photos: 247</div>
      <div>Contributors: 3</div>
      <div>Last Update: 2h ago</div>
    </div>
  </div>
</div>

### Three-Column Stats

Dashboard statistics pattern:

<div className="grid grid-cols-3 gap-4">
  <div className="text-center p-4 border rounded-lg">
    <div className="text-2xl font-bold">247</div>
    <div className="text-sm text-muted-foreground">Photos</div>
  </div>
  <div className="text-center p-4 border rounded-lg">
    <div className="text-2xl font-bold">12</div>
    <div className="text-sm text-muted-foreground">Projects</div>
  </div>
  <div className="text-center p-4 border rounded-lg">
    <div className="text-2xl font-bold">3</div>
    <div className="text-sm text-muted-foreground">Users</div>
  </div>
</div>

## Usage Guidelines

### When to Use Each Pattern

1. **Form Patterns**: Use for data input, settings, and user registration
2. **Card Layouts**: Use for displaying grouped information and actions
3. **Button Groups**: Use for related actions with clear hierarchy
4. **Status Indicators**: Use for communicating state and progress
5. **Loading States**: Use during async operations and data fetching
6. **Layout Patterns**: Use for organizing complex information displays

### Consistency Rules

1. **Spacing**: Use consistent spacing scale across all patterns
2. **Typography**: Follow type hierarchy for all text elements
3. **Colors**: Use semantic colors appropriately for state communication
4. **Actions**: Place primary actions prominently, secondary actions subtly
5. **Feedback**: Provide clear visual feedback for all interactive elements
```

### 3. Additional Documentation Files

Create similar comprehensive MDX files for:

- **Accessibility Guidelines**: WCAG compliance, keyboard navigation, screen reader support
- **Responsive Design**: Breakpoint system, mobile-first patterns
- **Theme System**: Dark/light mode implementation, custom theming

## Implementation Checklist

### Documentation Files
- [ ] **Design Tokens**: Colors, typography, spacing, sizing systems
- [ ] **Component Patterns**: Common UI patterns and layouts
- [ ] **Accessibility Guidelines**: A11y standards and implementation
- [ ] **Responsive Design**: Breakpoint and responsive patterns
- [ ] **Theme System**: Light/dark mode and theming guide

### Integration Testing
- [ ] **MDX Rendering**: All MDX files render correctly in Storybook
- [ ] **Code Examples**: All code examples are functional
- [ ] **Color Swatches**: Color palette displays correctly
- [ ] **Typography**: Font specimens display properly
- [ ] **Interactive Examples**: Interactive components work in documentation

### Quality Assurance
- [ ] **Accuracy**: All information matches actual implementation
- [ ] **Completeness**: All design tokens and patterns documented
- [ ] **Clarity**: Documentation is clear and actionable
- [ ] **Examples**: Practical examples for each concept
- [ ] **Updates**: Documentation stays in sync with code changes

---

**Next**: After completing design system documentation, proceed to Phase 3 for feature-specific component stories.