# Phase 1: Dependencies and Configuration Details
**Phase:** Core Storybook Setup  
**Updated:** 2025-08-17  
**Next.js Version:** 15.3.4  
**Storybook Version:** 8.x

## Dependency Installation Guide

### Core Storybook Dependencies

#### Essential Packages
```bash
# Core Storybook framework for Next.js
npm install --save-dev @storybook/nextjs@latest

# Essential addons bundle (controls, actions, docs, backgrounds, viewport, etc.)
npm install --save-dev @storybook/addon-essentials@latest

# Accessibility testing addon
npm install --save-dev @storybook/addon-a11y@latest

# Viewport addon for responsive testing
npm install --save-dev @storybook/addon-viewport@latest

# Documentation addon
npm install --save-dev @storybook/addon-docs@latest

# Controls addon for interactive prop editing
npm install --save-dev @storybook/addon-controls@latest
```

#### Testing Integration (Future Phases)
```bash
# Testing utilities for portable stories
npm install --save-dev @storybook/test@latest

# React testing utilities (for Phase 4)
npm install --save-dev @storybook/testing-react@latest
```

### Verification Commands

#### Check Installed Versions
```bash
npm list @storybook/nextjs
npm list @storybook/addon-essentials
npm list @storybook/addon-a11y
```

#### Expected Version Output
```
├── @storybook/nextjs@8.x.x
├── @storybook/addon-essentials@8.x.x
├── @storybook/addon-a11y@8.x.x
```

## Configuration Files

### 1. Main Configuration (`.storybook/main.ts`)

```typescript
import type { StorybookConfig } from '@storybook/nextjs';
import path from 'path';

const config: StorybookConfig = {
  // Story file patterns - covering both components and app directories
  stories: [
    '../components/**/*.stories.@(js|jsx|ts|tsx|mdx)',
    '../app/**/*.stories.@(js|jsx|ts|tsx|mdx)',
  ],
  
  // Essential addons for Minerva development workflow
  addons: [
    '@storybook/addon-essentials',    // Controls, actions, docs, backgrounds, etc.
    '@storybook/addon-a11y',          // Accessibility testing integration
    '@storybook/addon-viewport',      // Responsive design testing
    '@storybook/addon-docs',          // Auto-generated documentation
    '@storybook/addon-controls',      // Interactive prop controls
  ],
  
  // Next.js 15 framework configuration
  framework: {
    name: '@storybook/nextjs',
    options: {
      nextConfigPath: path.resolve(__dirname, '../next.config.js'),
      // Image optimization settings for Next.js Image component
      image: {
        loading: 'eager', // For Storybook development
      },
    },
  },
  
  // TypeScript configuration
  typescript: {
    check: false, // Disable type checking during development for speed
    reactDocgen: 'react-docgen-typescript',
    reactDocgenTypescriptOptions: {
      shouldExtractLiteralValuesFromEnum: true,
      // Filter out node_modules props for cleaner documentation
      propFilter: (prop) => (prop.parent ? !/node_modules/.test(prop.parent.fileName) : true),
    },
  },
  
  // Static file serving (for images, fonts, etc.)
  staticDirs: ['../public'],
  
  // Next.js 15 App Router experimental features
  features: {
    experimentalRSC: true, // React Server Components support
  },
  
  // Build optimization
  core: {
    disableTelemetry: true, // Optional: disable telemetry for privacy
  },
  
  // Documentation settings
  docs: {
    autodocs: 'tag', // Generate docs for stories tagged with 'autodocs'
  },
};

export default config;
```

### 2. Preview Configuration (`.storybook/preview.ts`)

```typescript
import type { Preview } from '@storybook/react';
import { withThemeFromJSXProvider } from '@storybook/addon-themes';

// Import global styles
import '../app/globals.css'; // Tailwind CSS and global styles

const preview: Preview = {
  // Global parameters for all stories
  parameters: {
    // Next.js 15 App Router configuration
    nextjs: {
      appDirectory: true, // Enable App Router support
      navigation: {
        pathname: '/', // Default pathname for navigation hooks
      },
    },
    
    // Action addon configuration
    actions: { 
      argTypesRegex: '^on[A-Z].*' // Auto-detect action props
    },
    
    // Controls addon configuration
    controls: {
      matchers: {
        color: /(background|color)$/i,
        date: /Date$/,
      },
      expanded: true, // Show all controls by default
    },
    
    // Documentation configuration
    docs: {
      autodocs: 'tag',
      toc: true, // Table of contents in docs
    },
    
    // Accessibility addon configuration
    a11y: {
      config: {
        rules: [
          {
            // Disable color contrast checking for development (can be enabled in CI)
            id: 'color-contrast',
            enabled: false,
          },
        ],
      },
    },
    
    // Viewport addon configuration for Minerva's responsive design
    viewport: {
      viewports: {
        mobile: {
          name: 'Mobile (375px)',
          styles: {
            width: '375px',
            height: '667px',
          },
        },
        tablet: {
          name: 'Tablet (768px)',
          styles: {
            width: '768px',
            height: '1024px',
          },
        },
        desktop: {
          name: 'Desktop (1440px)',
          styles: {
            width: '1440px',
            height: '900px',
          },
        },
        wide: {
          name: 'Wide Desktop (1920px)',
          styles: {
            width: '1920px',
            height: '1080px',
          },
        },
      },
      defaultViewport: 'desktop',
    },
    
    // Background addon configuration
    backgrounds: {
      default: 'light',
      values: [
        {
          name: 'light',
          value: '#ffffff',
        },
        {
          name: 'dark',
          value: '#1a1a1a',
        },
        {
          name: 'gray',
          value: '#f5f5f5',
        },
      ],
    },
  },
  
  // Global types for toolbar controls
  globalTypes: {
    theme: {
      description: 'Global theme for components',
      defaultValue: 'light',
      toolbar: {
        title: 'Theme',
        icon: 'paintbrush',
        items: [
          { value: 'light', title: 'Light' },
          { value: 'dark', title: 'Dark' },
        ],
        dynamicTitle: true,
      },
    },
  },
  
  // Global decorators
  decorators: [
    // Theme provider decorator (will be enhanced in Phase 2)
    (Story, context) => {
      const theme = context.globals.theme || 'light';
      
      return (
        <div className={theme === 'dark' ? 'dark' : ''}>
          <div className="min-h-screen bg-background text-foreground">
            <Story />
          </div>
        </div>
      );
    },
  ],
};

export default preview;
```

### 3. TypeScript Configuration (`.storybook/tsconfig.json`)

```json
{
  "extends": "../tsconfig.json",
  "compilerOptions": {
    "allowJs": true,
    "checkJs": false,
    "allowSyntheticDefaultImports": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "skipLibCheck": true
  },
  "include": [
    "../components/**/*",
    "../app/**/*",
    "../lib/**/*",
    "../stores/**/*",
    "../types/**/*",
    "./**/*"
  ],
  "exclude": [
    "../node_modules",
    "../.next",
    "../out"
  ]
}
```

### 4. Updated Tailwind Configuration

Add Storybook paths to `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './.storybook/**/*.{js,ts,jsx,tsx}', // Add this line for Storybook
  ],
  theme: {
    extend: {
      // Existing theme configuration
    },
  },
  plugins: [
    // Existing plugins
  ],
};
```

### 5. Package.json Script Updates

Add these scripts to `package.json`:

```json
{
  "scripts": {
    "storybook": "storybook dev -p 6006",
    "storybook:build": "storybook build",
    "storybook:serve": "npx serve storybook-static",
    "storybook:test": "test-storybook",
    "storybook:chromatic": "chromatic --exit-zero-on-changes",
    "build:storybook": "npm run storybook:build"
  }
}
```

## Environment Configuration

### 1. Environment Variables

Create `.env.local` entries for Storybook (if needed):

```bash
# Storybook specific environment variables
STORYBOOK_THEME=light
STORYBOOK_VIEWPORT=desktop

# Next.js environment variables (already existing)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_DEFAULT_KEY=your_key
```

### 2. Git Configuration

Update `.gitignore` to include Storybook build files:

```gitignore
# Storybook
storybook-static/
.storybook/manager-head.html
```

## Validation Checklist

### Installation Verification

```bash
# 1. Verify all packages installed
npm list | grep storybook

# 2. Check for peer dependency warnings
npm install --dry-run

# 3. Verify TypeScript compilation
npx tsc --noEmit --project .storybook/tsconfig.json

# 4. Start Storybook
npm run storybook
```

### Runtime Verification

- [ ] Storybook starts without errors on `http://localhost:6006`
- [ ] Navigation sidebar appears with empty state
- [ ] Viewport addon shows mobile/tablet/desktop options
- [ ] A11y addon panel is available
- [ ] Controls addon panel is available
- [ ] Theme switcher appears in toolbar
- [ ] No console errors in browser dev tools

### Configuration Verification

- [ ] TypeScript strict mode passes without errors
- [ ] Tailwind CSS classes apply correctly
- [ ] Next.js Image component works (test in Phase 2)
- [ ] shadcn/ui components render correctly (test in Phase 2)
- [ ] App Router hooks work correctly (test in Phase 2)

## Common Configuration Issues

### Next.js 15 Compatibility

**Issue**: App Router components don't render
```typescript
// Solution: Ensure appDirectory is enabled
parameters: {
  nextjs: {
    appDirectory: true,
  },
}
```

**Issue**: Navigation hooks fail
```typescript
// Solution: Provide navigation context
parameters: {
  nextjs: {
    navigation: {
      pathname: '/',
      query: {},
    },
  },
}
```

### Tailwind CSS Issues

**Issue**: Styles not applying
```javascript
// Solution: Update tailwind.config.js paths
content: [
  './.storybook/**/*.{js,ts,jsx,tsx}',
  // ... other paths
],
```

**Issue**: CSS custom properties not working
```css
/* Solution: Import CSS in preview.ts */
import '../app/globals.css';
```

### TypeScript Issues

**Issue**: Path resolution errors
```json
// Solution: Update .storybook/tsconfig.json paths
{
  "compilerOptions": {
    "baseUrl": "..",
    "paths": {
      "@/*": ["./"],
      "@/components/*": ["./components/*"]
    }
  }
}
```

---

**Next Phase**: After successful Phase 1 completion, proceed to Phase 2: Foundation Stories for shadcn/ui components.