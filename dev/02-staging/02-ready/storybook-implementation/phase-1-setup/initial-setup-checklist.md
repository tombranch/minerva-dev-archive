# Phase 1: Initial Setup Checklist
**Phase:** Core Storybook Setup  
**Estimated Time:** 6-8 hours  
**Prerequisites:** Duplicated-code Phase 1-2 completed

## Pre-Setup Verification

### Environment Check
- [ ] **Node.js Version**: ≥18.17.0 (check with `node --version`)
- [ ] **npm Version**: ≥9.0.0 (check with `npm --version`)
- [ ] **Next.js Version**: 15.3.4 (verify in package.json)
- [ ] **TypeScript**: Latest version installed
- [ ] **Git Branch**: Create new branch `storybook-implementation`

### Project State Check
- [ ] **Duplicated-code cleanup**: Phase 1-2 authentication & form consolidation completed
- [ ] **Build Status**: `npm run build` passes without errors
- [ ] **Test Status**: `npm test` passes without critical failures
- [ ] **Lint Status**: `npm run lint` passes without errors
- [ ] **TypeScript**: `npx tsc --noEmit` passes without errors

## Installation Phase (45-60 minutes)

### Step 1: Core Dependencies
```bash
# Install core Storybook packages
npm install --save-dev @storybook/nextjs@latest
npm install --save-dev @storybook/addon-essentials@latest
npm install --save-dev @storybook/addon-a11y@latest
npm install --save-dev @storybook/addon-viewport@latest
npm install --save-dev @storybook/addon-docs@latest
npm install --save-dev @storybook/addon-controls@latest
```

**Verification Checkpoints:**
- [ ] All packages installed without peer dependency warnings
- [ ] `npm list | grep storybook` shows all expected packages
- [ ] No security vulnerabilities reported (`npm audit`)

### Step 2: Testing Dependencies (Future Phases)
```bash
# Install testing utilities for Phase 4
npm install --save-dev @storybook/test@latest
npm install --save-dev @storybook/testing-react@latest
```

**Verification Checkpoints:**
- [ ] Testing packages installed successfully
- [ ] No version conflicts reported

## Configuration Phase (2-3 hours)

### Step 3: Create Storybook Configuration Files

#### Create `.storybook/main.ts`
- [ ] **File Created**: `.storybook/main.ts` exists
- [ ] **Content Check**: Contains Next.js 15 framework configuration
- [ ] **Stories Path**: Includes `../components/**/*.stories.*` pattern
- [ ] **Addons Listed**: All required addons included in configuration
- [ ] **TypeScript Config**: reactDocgen set to 'react-docgen-typescript'
- [ ] **App Router Support**: experimentalRSC feature enabled

#### Create `.storybook/preview.ts`
- [ ] **File Created**: `.storybook/preview.ts` exists
- [ ] **CSS Import**: `../app/globals.css` imported correctly
- [ ] **App Router Config**: `nextjs.appDirectory: true` set
- [ ] **Viewport Config**: Mobile, tablet, desktop viewports defined
- [ ] **A11y Config**: Accessibility addon configured
- [ ] **Theme Support**: Light/dark theme globals configured

#### Create `.storybook/tsconfig.json`
- [ ] **File Created**: `.storybook/tsconfig.json` exists
- [ ] **Extends Main**: Extends `../tsconfig.json`
- [ ] **Include Paths**: All relevant directories included
- [ ] **Exclude Paths**: node_modules and build directories excluded

### Step 4: Update Project Configuration

#### Update `tailwind.config.js`
- [ ] **Storybook Path Added**: `./.storybook/**/*.{js,ts,jsx,tsx}` included in content array
- [ ] **Existing Paths**: All existing paths preserved
- [ ] **Syntax Check**: Valid JavaScript/TypeScript syntax

#### Update `package.json`
- [ ] **Scripts Added**: `storybook`, `storybook:build`, `storybook:serve` scripts added
- [ ] **Existing Scripts**: All existing scripts preserved
- [ ] **Valid JSON**: No syntax errors in package.json

#### Update `.gitignore`
- [ ] **Build Directory**: `storybook-static/` added to .gitignore
- [ ] **Existing Entries**: All existing entries preserved

## Validation Phase (1-2 hours)

### Step 5: TypeScript Validation
```bash
# Check main project TypeScript
npx tsc --noEmit

# Check Storybook TypeScript
npx tsc --noEmit --project .storybook/tsconfig.json
```

**Verification Checkpoints:**
- [ ] No TypeScript errors in main project
- [ ] No TypeScript errors in Storybook configuration
- [ ] Path resolution working correctly
- [ ] Import statements resolve properly

### Step 6: Initial Storybook Launch
```bash
# Start Storybook
npm run storybook
```

**Verification Checkpoints:**
- [ ] **Startup**: Storybook starts without errors
- [ ] **URL Access**: `http://localhost:6006` loads successfully
- [ ] **Empty State**: Welcome screen or empty state displays
- [ ] **Console**: No JavaScript errors in browser console
- [ ] **Addons**: All addons appear in addon panel

### Step 7: Create Validation Story

#### Create `components/ui/button.stories.tsx`
- [ ] **File Created**: Story file exists with correct naming convention
- [ ] **Imports**: Correct imports for Meta, StoryObj, and Button component
- [ ] **Meta Configuration**: Proper meta configuration with title and component
- [ ] **Story Exports**: Multiple story variants exported
- [ ] **TypeScript**: Story file passes TypeScript checks

**Test Story Content:**
```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { Button } from './button';

const meta: Meta<typeof Button> = {
  title: 'UI/Button',
  component: Button,
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
  argTypes: {
    variant: {
      control: { type: 'select' },
      options: ['default', 'destructive', 'outline', 'secondary', 'ghost', 'link'],
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
```

### Step 8: Comprehensive Testing

#### Functional Testing
- [ ] **Story Loads**: Button story appears in sidebar navigation
- [ ] **Component Renders**: Button component displays correctly
- [ ] **Controls Work**: Variant control changes button appearance
- [ ] **Responsive**: Viewport addon switches work correctly
- [ ] **Accessibility**: A11y addon shows accessibility information
- [ ] **Documentation**: Auto-generated docs display component information

#### Cross-Browser Testing (Optional)
- [ ] **Chrome**: Storybook works correctly in Chrome
- [ ] **Firefox**: Storybook works correctly in Firefox
- [ ] **Safari**: Storybook works correctly in Safari (if on macOS)

#### Performance Check
- [ ] **Load Time**: Initial load completes within 10 seconds
- [ ] **Navigation**: Story navigation is responsive
- [ ] **Memory Usage**: No obvious memory leaks during development

## Build Validation (30 minutes)

### Step 9: Static Build Test
```bash
# Build Storybook static files
npm run storybook:build

# Serve static build
npm run storybook:serve
```

**Verification Checkpoints:**
- [ ] **Build Success**: Build completes without errors
- [ ] **Static Files**: `storybook-static/` directory created
- [ ] **Serve Success**: Static files serve correctly
- [ ] **Functionality**: All features work in static build

## Documentation & Cleanup (30 minutes)

### Step 10: Documentation
- [ ] **Phase 1 Complete**: Mark Phase 1 as completed in project documentation
- [ ] **Issues Log**: Document any issues encountered and solutions
- [ ] **Configuration Notes**: Record any custom configuration decisions
- [ ] **Next Steps**: Prepare notes for Phase 2 implementation

### Step 11: Git Commit
```bash
# Stage changes
git add .

# Commit Phase 1 completion
git commit -m "feat: complete Storybook Phase 1 - core setup and configuration"
```

**Verification Checkpoints:**
- [ ] **All Files Staged**: Configuration files, stories, and documentation committed
- [ ] **Commit Message**: Clear, descriptive commit message
- [ ] **Branch Status**: Working directory clean after commit

## Troubleshooting Quick Reference

### Common Issues & Solutions

#### Storybook Won't Start
- **Check**: Node.js version ≥18.17.0
- **Check**: All dependencies installed (`npm install`)
- **Check**: No port conflicts (kill process on port 6006)
- **Solution**: Clear node_modules and reinstall if needed

#### TypeScript Errors
- **Check**: Path resolution in `.storybook/tsconfig.json`
- **Check**: Import statements in story files
- **Solution**: Verify extends path and include/exclude arrays

#### Tailwind CSS Not Working
- **Check**: CSS import in `.storybook/preview.ts`
- **Check**: Storybook path in `tailwind.config.js`
- **Solution**: Restart Storybook after configuration changes

#### Button Story Not Loading
- **Check**: File naming convention (`.stories.tsx`)
- **Check**: Story file location matches stories pattern in main.ts
- **Check**: Button component import path is correct

## Success Criteria Summary

### Must Pass Before Phase 2
- ✅ Storybook runs successfully on `localhost:6006`
- ✅ Button story displays with all variants
- ✅ Interactive controls work for all props
- ✅ Responsive viewport switching functions
- ✅ Accessibility addon shows component information
- ✅ TypeScript compilation passes without errors
- ✅ Static build completes successfully

### Quality Gates
- ✅ Zero TypeScript errors
- ✅ Zero console errors during runtime
- ✅ All addon panels functional
- ✅ Tailwind CSS styles apply correctly
- ✅ Component documentation auto-generates

---

**Next Phase**: After all checklist items are complete, proceed to Phase 2: Foundation Stories for comprehensive shadcn/ui component documentation.