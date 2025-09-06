# Phase 1: Core Storybook Setup
**Estimated Time:** 6-8 hours  
**Prerequisites:** Duplicated-code Phase 1-2 completed  
**Status:** Ready for Implementation

## Overview

Phase 1 establishes the foundational Storybook configuration for the Minerva project, ensuring compatibility with Next.js 15, TypeScript strict mode, and the existing tech stack. This phase creates the infrastructure needed for all subsequent component documentation and testing.

## Objectives

### Primary Goals
- ✅ Install and configure Storybook for Next.js 15 with App Router
- ✅ Set up TypeScript integration with strict mode compliance
- ✅ Configure Tailwind CSS v4.1.11 and shadcn/ui support
- ✅ Install essential addons for development workflow
- ✅ Validate setup with basic component story

### Success Criteria
- Storybook runs successfully on `localhost:6006`
- Next.js 15 App Router components render correctly
- TypeScript strict mode passes without errors
- Tailwind CSS styles apply correctly in Storybook
- Basic shadcn/ui component displays with interactive controls

## Implementation Steps

### Step 1: Dependency Installation (45 minutes)

#### Core Storybook Dependencies
```bash
npm install --save-dev @storybook/nextjs @storybook/react-vite
npm install --save-dev @storybook/addon-essentials
npm install --save-dev @storybook/addon-a11y
npm install --save-dev @storybook/addon-viewport
npm install --save-dev @storybook/addon-docs
```

#### TypeScript Support
```bash
npm install --save-dev @storybook/addon-controls
npm install --save-dev @storybook/test
```

#### Testing Integration (for future phases)
```bash
npm install --save-dev @storybook/testing-react
```

### Step 2: Storybook Configuration (2 hours)

#### Create `.storybook/main.ts`
```typescript
import type { StorybookConfig } from '@storybook/nextjs';
import path from 'path';

const config: StorybookConfig = {
  stories: [
    '../components/**/*.stories.@(js|jsx|ts|tsx|mdx)',
    '../app/**/*.stories.@(js|jsx|ts|tsx|mdx)',
  ],
  addons: [
    '@storybook/addon-essentials',
    '@storybook/addon-a11y',
    '@storybook/addon-viewport',
    '@storybook/addon-docs',
    '@storybook/addon-controls',
  ],
  framework: {
    name: '@storybook/nextjs',
    options: {
      nextConfigPath: path.resolve(__dirname, '../next.config.js'),
    },
  },
  typescript: {
    check: false,
    reactDocgen: 'react-docgen-typescript',
    reactDocgenTypescriptOptions: {
      shouldExtractLiteralValuesFromEnum: true,
      propFilter: (prop) => (prop.parent ? !/node_modules/.test(prop.parent.fileName) : true),
    },
  },
  staticDirs: ['../public'],
  features: {
    experimentalRSC: true, // Next.js 15 App Router support
  },
};

export default config;
```

#### Create `.storybook/preview.ts`
```typescript
import type { Preview } from '@storybook/react';
import '../app/globals.css'; // Import Tailwind CSS

const preview: Preview = {
  parameters: {
    nextjs: {
      appDirectory: true, // Enable App Router support
    },
    actions: { argTypesRegex: '^on[A-Z].*' },
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/,
      },
    },
    docs: {
      autodocs: 'tag',
    },
    viewport: {
      viewports: {
        mobile: {
          name: 'Mobile',
          styles: {
            width: '375px',
            height: '667px',
          },
        },
        tablet: {
          name: 'Tablet',
          styles: {
            width: '768px',
            height: '1024px',
          },
        },
        desktop: {
          name: 'Desktop',
          styles: {
            width: '1440px',
            height: '900px',
          },
        },
      },
    },
  },
  globalTypes: {
    theme: {
      description: 'Global theme for components',
      defaultValue: 'light',
      toolbar: {
        title: 'Theme',
        icon: 'paintbrush',
        items: ['light', 'dark'],
        dynamicTitle: true,
      },
    },
  },
};

export default preview;
```

### Step 3: TypeScript Configuration (1 hour)

#### Update `tsconfig.json` for Storybook
Ensure paths are configured correctly:
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./"],
      "@/components/*": ["./components/*"],
      "@/lib/*": ["./lib/*"],
      "@/app/*": ["./app/*"]
    }
  },
  "include": [
    ".storybook/**/*",
    "components/**/*",
    "app/**/*"
  ]
}
```

#### Create `.storybook/tsconfig.json`
```json
{
  "extends": "../tsconfig.json",
  "compilerOptions": {
    "allowJs": true,
    "checkJs": false,
    "resolveJsonModule": true
  },
  "include": [
    "../components/**/*",
    "../app/**/*",
    "../lib/**/*",
    "./**/*"
  ],
  "exclude": [
    "../node_modules"
  ]
}
```

### Step 4: Tailwind CSS Integration (1.5 hours)

#### Verify Tailwind Configuration
Ensure `tailwind.config.js` includes Storybook paths:
```javascript
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './.storybook/**/*.{js,ts,jsx,tsx}', // Add this line
  ],
  // ... rest of config
};
```

#### Create Storybook CSS wrapper
Create `.storybook/preview-head.html`:
```html
<style>
  /* Ensure Tailwind CSS works correctly in Storybook */
  body {
    margin: 0;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
  }
</style>
```

### Step 5: Package.json Scripts (30 minutes)

Add Storybook scripts to `package.json`:
```json
{
  "scripts": {
    "storybook": "storybook dev -p 6006",
    "storybook:build": "storybook build",
    "storybook:serve": "npx http-server storybook-static",
    "storybook:test": "test-storybook"
  }
}
```

### Step 6: Initial Validation Story (1 hour)

Create a test story to validate setup:

#### Create `components/ui/button.stories.tsx`
```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './button';

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: 'A versatile button component built with shadcn/ui and Tailwind CSS.',
      },
    },
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: { type: 'select' },
      options: ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link'],
    },
    size: {
      control: { type: 'select' },
      options: ['default', 'sm', 'lg', 'icon'],
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
    children: 'Button',
  },
};

export const Secondary: Story = {
  args: {
    variant: 'secondary',
    children: 'Secondary',
  },
};

export const Destructive: Story = {
  args: {
    variant: 'destructive',
    children: 'Destructive',
  },
};

export const Outline: Story = {
  args: {
    variant: 'outline',
    children: 'Outline',
  },
};

export const Sizes: Story = {
  render: () => (
    <div className="flex items-center gap-4">
      <Button size="sm">Small</Button>
      <Button size="default">Default</Button>
      <Button size="lg">Large</Button>
    </div>
  ),
};

export const AllVariants: Story = {
  render: () => (
    <div className="grid grid-cols-2 gap-4 max-w-md">
      <Button variant="default">Default</Button>
      <Button variant="secondary">Secondary</Button>
      <Button variant="destructive">Destructive</Button>
      <Button variant="outline">Outline</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="link">Link</Button>
    </div>
  ),
};
```

## Testing & Validation

### Functional Tests
1. **Start Storybook**: `npm run storybook`
2. **Verify Launch**: Navigate to `http://localhost:6006`
3. **Test Button Story**: Verify Button component renders with all variants
4. **Test Controls**: Interactive controls work for variant/size props
5. **Test Responsive**: Viewport addon switches between mobile/tablet/desktop
6. **Test Accessibility**: A11y addon shows no violations

### TypeScript Validation
```bash
# Run TypeScript check
npx tsc --noEmit

# Verify no Storybook-related type errors
npx tsc --noEmit --project .storybook/tsconfig.json
```

### Build Validation
```bash
# Test Storybook build
npm run storybook:build

# Verify static build works
npm run storybook:serve
```

## Troubleshooting

### Common Issues

#### Next.js 15 App Router Compatibility
- **Issue**: Components don't render correctly
- **Solution**: Ensure `nextjs.appDirectory: true` in preview.ts
- **Validation**: Test with a component that uses Next.js hooks

#### Tailwind CSS Not Working
- **Issue**: Styles not applying in Storybook
- **Solution**: Verify CSS import in preview.ts and Tailwind paths
- **Validation**: Check computed styles in browser dev tools

#### TypeScript Errors
- **Issue**: Path resolution or type errors
- **Solution**: Update tsconfig paths and ensure proper imports
- **Validation**: Run `npx tsc --noEmit` successfully

#### shadcn/ui Components Issues
- **Issue**: Components missing styles or functionality
- **Solution**: Ensure all dependencies are installed and CSS is imported
- **Validation**: Test Button component with all variants

## Deliverables

### Configuration Files
- ✅ `.storybook/main.ts` - Core Storybook configuration
- ✅ `.storybook/preview.ts` - Preview settings and global parameters
- ✅ `.storybook/tsconfig.json` - TypeScript configuration for Storybook
- ✅ Updated `package.json` with Storybook scripts

### Test Files
- ✅ `components/ui/button.stories.tsx` - Validation story
- ✅ Working Storybook instance on `localhost:6006`

### Documentation
- ✅ Setup validation checklist
- ✅ Troubleshooting guide
- ✅ Next phase preparation notes

## Next Steps

After Phase 1 completion:

1. **Validate Setup**: Ensure all tests pass and Storybook runs smoothly
2. **Team Review**: Demo basic setup to team for feedback
3. **Begin Phase 2**: Start creating foundation stories for shadcn/ui components
4. **Documentation**: Update this plan with any learnings or modifications

---

**Note**: This phase establishes the foundation for all subsequent Storybook development. Take time to ensure everything works correctly before proceeding to Phase 2.