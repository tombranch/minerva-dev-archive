# Phase 2: shadcn/ui Component Stories Reference
**Complete Implementation Guide for Foundation Components**  
**Estimated Time per Component:** 15-20 minutes  
**Total Phase 2 Time:** 4-6 hours

## Component Priority Matrix

### Tier 1: Essential Components (High Priority)
**Target Time:** 2.5 hours | 9 components

| Component | Usage in Minerva | Complexity | Time Est. |
|-----------|------------------|------------|-----------|
| `Button` | Primary actions, forms, navigation | Medium | 20 min |
| `Input` | Search, forms, filters | Medium | 20 min |
| `Card` | Photo containers, dashboards | Low | 15 min |
| `Badge` | Status indicators, tags | Low | 15 min |
| `Avatar` | User profiles, organization | Low | 15 min |
| `Dialog` | Modals, confirmations | High | 25 min |
| `Alert` | Notifications, feedback | Medium | 15 min |
| `Select` | Filters, dropdowns | Medium | 20 min |
| `Checkbox` | Bulk operations, forms | Low | 15 min |

### Tier 2: Interface Components (Medium Priority)
**Target Time:** 1.5 hours | 6 components

| Component | Usage in Minerva | Complexity | Time Est. |
|-----------|------------------|------------|-----------|
| `Tabs` | Navigation, organization | Medium | 20 min |
| `Table` | Data display, reports | High | 25 min |
| `Progress` | Upload, processing | Low | 10 min |
| `Tooltip` | Help text, information | Low | 10 min |
| `Dropdown Menu` | Actions, context menus | Medium | 15 min |
| `Sheet` | Mobile navigation, panels | Medium | 20 min |

### Tier 3: Specialized Components (Lower Priority)
**Target Time:** 45 minutes | 5 components

| Component | Usage in Minerva | Complexity | Time Est. |
|-----------|------------------|------------|-----------|
| `Calendar` | Date filters, reports | High | 15 min |
| `Command` | Search, quick actions | Medium | 10 min |
| `Navigation Menu` | Site navigation | Medium | 10 min |
| `Slider` | Density controls, filters | Low | 5 min |
| `Switch` | Settings, toggles | Low | 5 min |

## Detailed Implementation Guide

### Tier 1 Components

#### 1. Button Component (`components/ui/button.stories.tsx`)

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { fn } from '@storybook/test';
import { Button } from './button';
import { 
  Download, ArrowRight, Loader2, Heart, Share, Settings,
  Upload, Camera, Search, Filter, Plus, Trash2 
} from 'lucide-react';

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: `
Primary button component used throughout Minerva for actions, navigation, and form submissions. 
Built with Radix UI and supports all standard button functionality with consistent styling.

**Common Use Cases in Minerva:**
- Photo upload actions
- Form submissions  
- Navigation between views
- Bulk operations on photos
- AI processing triggers
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: { type: 'select' },
      options: ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link'],
      description: 'Visual style variant',
      table: {
        type: { summary: 'string' },
        defaultValue: { summary: 'default' },
      },
    },
    size: {
      control: { type: 'select' },
      options: ['default', 'sm', 'lg', 'icon'],
      description: 'Button size',
      table: {
        type: { summary: 'string' },
        defaultValue: { summary: 'default' },
      },
    },
    disabled: {
      control: 'boolean',
      description: 'Disable button interaction',
    },
    asChild: {
      control: 'boolean',
      description: 'Render as child component (for links)',
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

export const AllVariants: Story = {
  render: () => (
    <div className="grid grid-cols-3 gap-4">
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
        story: 'All available button variants used throughout the Minerva interface.',
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
  parameters: {
    docs: {
      description: {
        story: 'Button sizes for different contexts. Icon size is commonly used for action buttons.',
      },
    },
  },
};

export const MinervaActionButtons: Story = {
  render: () => (
    <div className="space-y-4">
      <div className="flex gap-2">
        <Button>
          <Upload className="mr-2 h-4 w-4" />
          Upload Photos
        </Button>
        <Button variant="outline">
          <Camera className="mr-2 h-4 w-4" />
          Capture
        </Button>
        <Button variant="secondary">
          <Search className="mr-2 h-4 w-4" />
          Search
        </Button>
      </div>
      <div className="flex gap-2">
        <Button size="sm">
          <Filter className="mr-2 h-4 w-4" />
          Filter
        </Button>
        <Button size="sm" variant="outline">
          <Plus className="mr-2 h-4 w-4" />
          Add Tag
        </Button>
        <Button size="sm" variant="destructive">
          <Trash2 className="mr-2 h-4 w-4" />
          Delete
        </Button>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Common button patterns used throughout the Minerva photo management interface.',
      },
    },
  },
};

export const LoadingStates: Story = {
  render: () => (
    <div className="flex gap-4">
      <Button disabled>
        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
        Uploading...
      </Button>
      <Button variant="outline" disabled>
        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
        Processing
      </Button>
      <Button variant="secondary" disabled>
        <Loader2 className="mr-2 h-4 w-4 animate-spin" />
        Analyzing
      </Button>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Loading states for async operations like photo uploads and AI processing.',
      },
    },
  },
};

export const Interactive: Story = {
  args: {
    children: 'Click to Test',
    onClick: fn(),
  },
  parameters: {
    docs: {
      description: {
        story: 'Interactive button with click handler. Check the Actions panel below to see click events.',
      },
    },
  },
};
```

#### 2. Input Component (`components/ui/input.stories.tsx`)

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { Input } from './input';
import { Label } from './label';
import { Search, Eye, EyeOff, Mail, Lock, User, Hash, MapPin } from 'lucide-react';
import { useState } from 'react';

const meta: Meta<typeof Input> = {
  title: 'UI/Input',
  component: Input,
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        component: `
Text input component for forms, search, and data entry throughout Minerva. 
Supports validation states, icons, and various input types.

**Common Use Cases:**
- Photo search and filtering
- Form inputs (login, registration, settings)
- Project and site creation
- Tag management
- AI prompt inputs
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="w-80">
        <Story />
      </div>
    ),
  ],
  argTypes: {
    type: {
      control: { type: 'select' },
      options: ['text', 'email', 'password', 'search', 'number', 'tel', 'url'],
      description: 'Input type for validation and keyboard',
    },
    placeholder: {
      control: 'text',
      description: 'Placeholder text',
    },
    disabled: {
      control: 'boolean',
      description: 'Disable input',
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

export const MinervaSearchInputs: Story = {
  render: () => (
    <div className="space-y-4">
      <div>
        <Label>Photo Search</Label>
        <div className="relative">
          <Search className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input placeholder="Search photos by tags, location, or content..." className="pl-10" />
        </div>
      </div>
      <div>
        <Label>Project Filter</Label>
        <div className="relative">
          <Hash className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input placeholder="Filter by project name..." className="pl-10" />
        </div>
      </div>
      <div>
        <Label>Location Search</Label>
        <div className="relative">
          <MapPin className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input placeholder="Search by location or site..." className="pl-10" />
        </div>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Search input patterns commonly used in Minerva for filtering and finding content.',
      },
    },
  },
};

export const FormInputs: Story = {
  render: () => (
    <div className="space-y-4">
      <div>
        <Label htmlFor="email">Email Address</Label>
        <div className="relative">
          <Mail className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input id="email" type="email" placeholder="user@company.com" className="pl-10" />
        </div>
      </div>
      <div>
        <Label htmlFor="password">Password</Label>
        <div className="relative">
          <Lock className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input id="password" type="password" placeholder="Enter password" className="pl-10" />
        </div>
      </div>
      <div>
        <Label htmlFor="name">Full Name</Label>
        <div className="relative">
          <User className="absolute left-3 top-3 h-4 w-4 text-muted-foreground" />
          <Input id="name" placeholder="John Smith" className="pl-10" />
        </div>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Form input patterns for user registration, login, and profile management.',
      },
    },
  },
};

export const ValidationStates: Story = {
  render: () => (
    <div className="space-y-4">
      <div>
        <Label>Valid Input</Label>
        <Input 
          placeholder="Valid input" 
          className="border-green-500 focus-visible:ring-green-500" 
        />
        <p className="text-sm text-green-600 mt-1">Input is valid</p>
      </div>
      <div>
        <Label>Error Input</Label>
        <Input 
          placeholder="Invalid input" 
          className="border-destructive focus-visible:ring-destructive" 
        />
        <p className="text-sm text-destructive mt-1">This field is required</p>
      </div>
      <div>
        <Label>Warning Input</Label>
        <Input 
          placeholder="Warning input" 
          className="border-yellow-500 focus-visible:ring-yellow-500" 
        />
        <p className="text-sm text-yellow-600 mt-1">This value should be verified</p>
      </div>
      <div>
        <Label>Disabled Input</Label>
        <Input placeholder="Disabled input" disabled />
        <p className="text-sm text-muted-foreground mt-1">This field is not editable</p>
      </div>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Different validation states for form feedback and user guidance.',
      },
    },
  },
};

export const InteractiveValidation: Story = {
  render: () => {
    const [email, setEmail] = useState('');
    const [error, setError] = useState('');
    
    const validateEmail = (value: string) => {
      if (!value) {
        setError('Email is required');
      } else if (!value.includes('@')) {
        setError('Please enter a valid email address');
      } else if (!value.includes('.')) {
        setError('Email must include a domain');
      } else {
        setError('');
      }
    };
    
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
      const value = e.target.value;
      setEmail(value);
      validateEmail(value);
    };
    
    return (
      <div className="space-y-2">
        <Label htmlFor="email-validation">Email Address *</Label>
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
        {email && !error && (
          <p className="text-sm text-green-600">Email format is valid</p>
        )}
      </div>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Real-time validation example showing error states and success feedback.',
      },
    },
  },
};
```

#### 3. Card Component (`components/ui/card.stories.tsx`)

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from './card';
import { Button } from './button';
import { Badge } from './badge';
import { Avatar, AvatarFallback, AvatarImage } from './avatar';
import { CalendarDays, MapPin, Camera, Upload, Users, BarChart3 } from 'lucide-react';

const meta: Meta<typeof Card> = {
  title: 'UI/Card',
  component: Card,
  parameters: {
    layout: 'padded',
    docs: {
      description: {
        component: `
Card component for organizing content into distinct sections. Used extensively in Minerva 
for photo displays, project summaries, user profiles, and dashboard widgets.

**Components:**
- Card: Root container
- CardHeader: Title and description area  
- CardContent: Main content area
- CardFooter: Action buttons and metadata
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="max-w-md">
        <Story />
      </div>
    ),
  ],
};

export default meta;
type Story = StoryObj<typeof meta>;

export const Default: Story = {
  render: () => (
    <Card>
      <CardHeader>
        <CardTitle>Card Title</CardTitle>
        <CardDescription>Card description goes here</CardDescription>
      </CardHeader>
      <CardContent>
        <p>Card content area with main information.</p>
      </CardContent>
      <CardFooter>
        <Button>Action</Button>
      </CardFooter>
    </Card>
  ),
};

export const PhotoProjectCard: Story = {
  render: () => (
    <Card>
      <CardHeader>
        <div className="flex justify-between items-start">
          <div>
            <CardTitle>Conveyor Safety Inspection</CardTitle>
            <CardDescription>Manufacturing Floor - Building A</CardDescription>
          </div>
          <Badge variant="secondary">Active</Badge>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-3">
          <div className="flex items-center text-sm text-muted-foreground">
            <Camera className="mr-2 h-4 w-4" />
            247 photos
          </div>
          <div className="flex items-center text-sm text-muted-foreground">
            <MapPin className="mr-2 h-4 w-4" />
            Site: Main Production
          </div>
          <div className="flex items-center text-sm text-muted-foreground">
            <CalendarDays className="mr-2 h-4 w-4" />
            Last updated: 2 hours ago
          </div>
        </div>
      </CardContent>
      <CardFooter className="flex justify-between">
        <Button variant="outline" size="sm">View Photos</Button>
        <Button size="sm">
          <Upload className="mr-2 h-4 w-4" />
          Upload
        </Button>
      </CardFooter>
    </Card>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Photo project card showing project information, statistics, and available actions.',
      },
    },
  },
};

export const UserProfileCard: Story = {
  render: () => (
    <Card>
      <CardHeader>
        <div className="flex items-center space-x-4">
          <Avatar>
            <AvatarImage src="/placeholder-avatar.jpg" />
            <AvatarFallback>JS</AvatarFallback>
          </Avatar>
          <div>
            <CardTitle>John Smith</CardTitle>
            <CardDescription>Safety Engineer</CardDescription>
          </div>
        </div>
      </CardHeader>
      <CardContent>
        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">Projects</span>
            <span className="font-medium">12</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">Photos Uploaded</span>
            <span className="font-medium">1,247</span>
          </div>
          <div className="flex justify-between text-sm">
            <span className="text-muted-foreground">Last Active</span>
            <span className="font-medium">2 hours ago</span>
          </div>
        </div>
      </CardContent>
      <CardFooter>
        <Button variant="outline" className="w-full">View Profile</Button>
      </CardFooter>
    </Card>
  ),
  parameters: {
    docs: {
      description: {
        story: 'User profile card displaying user information, activity metrics, and profile actions.',
      },
    },
  },
};

export const DashboardMetricCard: Story = {
  render: () => (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium">Total Photos</CardTitle>
        <BarChart3 className="h-4 w-4 text-muted-foreground" />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold">12,847</div>
        <p className="text-xs text-muted-foreground">
          +12% from last month
        </p>
      </CardContent>
    </Card>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Dashboard metric card for displaying key performance indicators and statistics.',
      },
    },
  },
};

export const CardVariations: Story = {
  render: () => (
    <div className="grid gap-4 md:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Simple Card</CardTitle>
        </CardHeader>
        <CardContent>
          <p>Basic card with header and content.</p>
        </CardContent>
      </Card>
      
      <Card>
        <CardContent className="pt-6">
          <p>Card with content only, no header.</p>
        </CardContent>
      </Card>
      
      <Card>
        <CardHeader>
          <CardTitle>Card with Footer</CardTitle>
          <CardDescription>Description text here</CardDescription>
        </CardHeader>
        <CardContent>
          <p>Content with action buttons in footer.</p>
        </CardContent>
        <CardFooter>
          <Button variant="outline" size="sm">Cancel</Button>
          <Button size="sm">Save</Button>
        </CardFooter>
      </Card>
      
      <Card className="border-dashed">
        <CardContent className="flex flex-col items-center justify-center pt-6 pb-6">
          <Upload className="h-8 w-8 text-muted-foreground mb-2" />
          <p className="text-sm text-muted-foreground text-center">
            Drag & drop files here or click to upload
          </p>
        </CardContent>
      </Card>
    </div>
  ),
  parameters: {
    docs: {
      description: {
        story: 'Various card layouts and styles used throughout the Minerva interface.',
      },
    },
  },
};
```

## Implementation Timeline

### Day 1 (2.5 hours) - Tier 1 Essential Components
- **Hour 1**: Button, Input components with comprehensive stories
- **Hour 1.5**: Card, Badge, Avatar components with Minerva-specific examples
- **Hour 2**: Dialog, Alert, Select, Checkbox components

### Day 2 (1.5 hours) - Tier 2 Interface Components  
- **Hour 1**: Tabs, Table, Progress components
- **Hour 0.5**: Tooltip, Dropdown Menu, Sheet components

### Day 3 (45 minutes) - Tier 3 Specialized Components
- **30 minutes**: Calendar, Command, Navigation Menu components
- **15 minutes**: Slider, Switch components and final testing

## Quality Checklist

For each component story:
- [ ] **Multiple Variants**: Show all available props and states
- [ ] **Minerva Context**: Include realistic use cases from the application
- [ ] **Interactive Controls**: All props have appropriate controls
- [ ] **Documentation**: Clear descriptions and usage guidance
- [ ] **Accessibility**: No violations in A11y addon
- [ ] **Responsive**: Works on mobile, tablet, desktop viewports
- [ ] **Theme Support**: Works with light and dark themes

## Testing Strategy

### Visual Regression
- Take screenshots of all stories in multiple viewports
- Test theme switching for each component
- Verify consistent styling across components

### Interaction Testing
- Test all interactive controls
- Verify click handlers and form inputs work
- Validate keyboard navigation support

### Documentation Quality
- Ensure autodocs generate correctly
- Verify code examples are accurate
- Check that descriptions are helpful and complete

---

**Next Phase**: After completing all Tier 1-3 components, proceed to Phase 3 for feature-specific component stories.