PS C:\Users\Tom\dev\minerva> npm run validate:quick

> machine-safety-photo-organizer@0.1.0 validate:quick
> node scripts/maintenance/validate-quick.js


⚡ QUICK PROJECT VALIDATION
Running essential checks on entire codebase...
==================================================

📁 Session logs: C:\Users\Tom\dev\minerva\logs\validate-quick-2025-08-12_04-49-07

🎨 Code Quality Checks

Checking code formatting on all files...
✅ Checking code formatting on all files passed (0.12s)

Running ESLint on all files...
✅ Running ESLint on all files passed (0.13s)

Full TypeScript type checking...
✅ Full TypeScript type checking passed (0.12s)

📦 Dependencies

✅ Checking dependency integrity passed (2.38s)

==================================================
⚡ QUICK VALIDATION SUMMARY
==================================================
✅ Code Formatting (All Files)
✅ ESLint (All Files)
✅ TypeScript (Full)
✅ Dependencies Sync

⏱️  Quick validation time: 2.75s
📊 Results: 4 passed, 0 failed

📋 Summary report: C:\Users\Tom\dev\minerva\logs\validate-quick-2025-08-12_04-49-07\summary.md

 🎉 ALL 4 QUICK CHECKS PASSED! 🎉 
✨ Core code quality is validated!
💡 For full validation (with tests & build), run: npm run validate:all
PS C:\Users\Tom\dev\minerva> npm run validate:all

> machine-safety-photo-organizer@0.1.0 validate:all
> node scripts/maintenance/validate-all.js


🚀 COMPREHENSIVE PROJECT VALIDATION
Running complete validation on entire codebase...
============================================================

📁 Session logs: C:\Users\Tom\dev\minerva\logs\validate-all-2025-08-12_04-49-32

📋 Environment Check

Checking Node.js and npm versions...
✅ Checking Node.js and npm versions passed (0.54s)
v24.2.0
10.5.2

Verifying dependencies (install if needed)...
✅ Verifying dependencies (install if needed) passed (2.43s)
machine-safety-photo-organizer@0.1.0 C:\Users\Tom\dev\minerva
├── @emnapi/core@1.4.3 extraneous
├── @emnapi/runtime@1.4.3 extraneous
├── @emnapi/wasi-threads@1.0.2 extraneous
├── @eslint/eslintrc@3.3.1
├── @google-cloud/vision@5.2.0
├── @google/generative-ai@0.24.1
├── @monaco-editor/react@4.7.0
├── @napi-rs/wasm-runtime@0.2.11 extraneous
├── @playwright/test@1.53.2
├── @radix-ui/react-alert-dialog@1.1.14
├── @radix-ui/react-avatar@1.1.10
├── @radix-ui/react-checkbox@1.3.2
├── @radix-ui/react-collapsible@1.1.11
├── @radix-ui/react-dialog@1.1.14
├── @radix-ui/react-dropdown-menu@2.1.15
├── @radix-ui/react-label@2.1.7
├── @radix-ui/react-navigation-menu@1.2.13
├── @radix-ui/react-popover@1.1.14
├── @radix-ui/react-progress@1.1.7
├── @radix-ui/react-radio-group@1.3.7
├── @radix-ui/react-scroll-area@1.2.9
├── @radix-ui/react-select@2.2.5
├── @radix-ui/react-separator@1.1.7
├── @radix-ui/react-slider@1.3.5
├── @radix-ui/react-slot@1.2.3
├── @radix-ui/react-switch@1.2.5
├── @radix-ui/react-tabs@1.1.12
├── @radix-ui/react-tooltip@1.2.7
├── @sentry/nextjs@9.38.0
├── @supabase/auth-helpers-nextjs@0.10.0
├── @supabase/ssr@0.6.1
├── @supabase/supabase-js@2.50.2
├── @tailwindcss/postcss@4.1.11
├── @tanstack/react-query-devtools@5.81.5
├── @tanstack/react-query@5.81.5
├── @testing-library/jest-dom@6.6.3
├── @testing-library/react@16.3.0
├── @testing-library/user-event@14.6.1
├── @tybys/wasm-util@0.9.0 extraneous
├── @types/dotenv@6.1.1
├── @types/jest-axe@3.5.9
├── @types/jest@30.0.0
├── @types/jszip@3.4.1
├── @types/node@20.19.4
├── @types/react-dom@19.1.6
├── @types/react@19.1.8
├── @types/shimmer@1.2.0 extraneous
├── @typescript-eslint/eslint-plugin@8.39.1
├── @typescript-eslint/parser@8.39.1
├── @vercel/analytics@1.5.0
├── @vercel/speed-insights@1.2.0
├── @vitejs/plugin-react@4.6.0
├── @vitest/coverage-v8@3.2.4
├── @vitest/ui@3.2.4
├── c8@10.1.3
├── clarifai@2.9.1
├── class-variance-authority@0.7.1
├── clsx@2.1.1
├── cmdk@1.1.1
├── csv-parse@6.0.0
├── date-fns@4.1.0
├── dequal@2.0.3 extraneous
├── docx@9.5.1
├── dotenv@17.0.1
├── eastasianwidth@0.2.0 extraneous
├── eslint-config-next@15.3.4
├── eslint-config-prettier@10.1.5
├── eslint-plugin-prettier@5.5.1
├── eslint-plugin-react-hooks@5.2.0
├── eslint-plugin-react@7.37.5
├── eslint-plugin-simple-import-sort@12.1.1
├── eslint-plugin-unused-imports@4.1.4
├── eslint@9.30.1
├── exceljs@4.4.0
├── exifr@7.1.3
├── fs-minipass@2.1.0 extraneous
├── happy-dom@18.0.1
├── husky@9.1.7
├── jest-axe@9.0.0
├── jest-environment-jsdom@30.0.2
├── jest@30.0.3
├── jsdom@26.1.0
├── jsonwebtoken@9.0.2
├── jspdf-autotable@5.0.2
├── jspdf@3.0.1
├── jszip@3.10.1
├── kill-port@2.0.1
├── lint-staged@16.1.2
├── lucide-react@0.525.0
├── msw@2.10.2
├── next-themes@0.4.6
├── next@15.3.4
├── node-mocks-http@1.17.2
├── playwright@1.53.2
├── posthog-js@1.256.1
├── posthog-node@5.1.1
├── prettier@3.6.2
├── psl@1.15.0 extraneous
├── querystringify@2.2.0 extraneous
├── react-day-picker@9.7.0
├── react-dom@19.1.0
├── react@19.1.0
├── recharts@3.0.2
├── requires-port@1.0.0 extraneous
├── shimmer@1.2.1 extraneous
├── sonner@2.0.5
├── sprintf-js@1.0.3 extraneous
├── supabase@2.31.4
├── tailwind-merge@3.3.1
├── tailwindcss@4.1.11
├── ts-jest@29.4.0
├── tsx@4.20.3
├── tw-animate-css@1.3.4
├── typescript@5.9.2
├── undici@7.11.0 overridden
├── universalify@0.2.0 extraneous
├── url-parse@1.5.10 extraneous
├── vercel@44.4.0
├── vitest@3.2.4
├── zod@3.25.67
└── zustand@5.0.6

🎨 Code Quality Checks

Checking code formatting on all files...
✅ Checking code formatting on all files passed (0.12s)

Running ESLint on all files...
✅ Running ESLint on all files passed (0.12s)

Full TypeScript type checking...
✅ Full TypeScript type checking passed (0.12s)

🔒 Security Checks

Running security audit...
✅ Running security audit passed (0.12s)

🧪 Testing

Running unit tests with coverage...
✅ Running unit tests with coverage passed (0.12s)

🏗️  Build Verification
Running full production build (this may take 1-2 minutes)...

Building for production...
✅ Building for production passed (0.12s)

============================================================
🎯 COMPREHENSIVE VALIDATION SUMMARY
============================================================
✅ Dependencies Check
✅ Code Formatting (All Files)
✅ ESLint (All Files)
✅ TypeScript (Full)
✅ Security Audit
✅ Unit Tests

⏱️  Total validation time: 3.69s (0.1 minutes)
📊 Results: 8 passed, 0 failed

📋 Summary report: C:\Users\Tom\dev\minerva\logs\validate-all-2025-08-12_04-49-32\summary.md

 🎉 ALL 8 VALIDATION CHECKS PASSED! 🎉 
✨ Your entire codebase is validated and ready for:
   • Pull Request creation
   • Production deployment
   • Code review
PS C:\Users\Tom\dev\minerva> npm run build

> machine-safety-photo-organizer@0.1.0 build
> next build

'next' is not recognized as an internal or external command,
operable program or batch file.
PS C:\Users\Tom\dev\minerva> npm run build

> machine-safety-photo-organizer@0.1.0 build
> node "node_modules/next/dist/bin/next" build

   ▲ Next.js 15.3.4
   - Environments: .env.local

   Creating an optimized production build ...
 ✓ Compiled successfully in 24.0s

./components/ai/console/testing/RealTimeSystemTester.tsx
250:6  Warning: React Hook useCallback has a missing dependency: 'connectionStatus.subscriptions.length'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps

./components/ai/monitoring/ActivityFeed.tsx
602:33  Warning: Image elements must have an alt prop, either with meaningful text, or an empty string for decorative images.  jsx-a11y/alt-text

./components/ai/monitoring/RealTimeMonitor.tsx
308:33  Warning: Image elements must have an alt prop, either with meaningful text, or an empty string for decorative images.  jsx-a11y/alt-text

./components/search/EnhancedSearchBar.tsx
266:19  Warning: Image elements must have an alt prop, either with meaningful text, or an empty string for decorative images.  jsx-a11y/alt-text

./lib/ai/feature-migration.ts
335:38  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
336:24  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
339:26  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/ai/prompt-service-server.ts
433:56  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
435:37  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
753:24  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
754:59  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/ai/prompt-service.ts
69:29  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
70:33  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
71:32  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/ai/providers/clarifai.ts
86:53  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
89:24  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
89:49  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
89:83  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
90:37  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
96:36  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
96:61  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
97:37  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
106:41  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
301:27  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
303:91  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/ai/providers/google-vision.ts
147:84  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/contexts/ViewModeContext.tsx
111:36  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/rls-helpers.ts
37:20  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
48:20  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
62:41  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/model-management.ts
610:35  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/overview-service.ts
396:30  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
396:64  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
410:30  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/platform-feature-management.ts
305:34  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/platform-model-management.ts
627:28  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
905:80  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/platform-overview-adapter.ts
159:36  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/platform-overview-service.ts
209:22  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
252:34  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
257:44  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
257:74  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
286:30  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
372:57  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
450:42  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
506:22  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
536:40  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
541:40  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/platform-spending-analytics.ts
44:31  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
68:32  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
72:38  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
89:55  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
337:36  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
376:44  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/prompt-library-service.ts
606:27  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
608:38  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
609:45  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/platform/spending-analytics-service.ts
210:34  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
272:54  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
274:72  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
336:32  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
910:32  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/real-time-service.ts
208:45  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
212:16  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/smart-album-engine.ts
10:27  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
120:55  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
525:57  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/services/smart-album-job-queue.ts
227:75  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
228:76  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
256:58  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
285:68  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./lib/supabase-server.ts
116:42  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
116:50  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
118:26  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./hooks/use-ai-processing-status.ts
159:67  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./hooks/use-drag-selection.ts
129:9  Warning: The 'normalizedRect' conditional could make the dependencies of useCallback Hook (at line 154) change on every render. To fix this, wrap the initialization of 'normalizedRect' in its own useMemo() Hook.  react-hooks/exhaustive-deps

./hooks/use-form-validation.ts
124:6  Warning: React Hook useEffect has a missing dependency: 'debounceTimer'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps

./hooks/use-optimized-real-time-dashboard.ts
140:9  Warning: The 'config' object makes the dependencies of useCallback Hook (at line 459) change on every render. To fix this, wrap the initialization of 'config' in its own useMemo() Hook.  react-hooks/exhaustive-deps
288:52  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
290:54  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
403:48  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
416:48  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
428:48  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
440:48  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
453:48  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any

./hooks/use-user-feedback.ts
66:6  Warning: React Hook useEffect has a missing dependency: 'fetchUserFeedback'. Either include it or remove the dependency array.  react-hooks/exhaustive-deps

./hooks/useBulkOperations.ts
28:9  Warning: The 'service' object construction makes the dependencies of useCallback Hook (at line 89) change on every render. To fix this, wrap the initialization of 'service' in its own useMemo() Hook.  react-hooks/exhaustive-deps
28:9  Warning: The 'service' object construction makes the dependencies of useCallback Hook (at line 214) change on every render. To fix this, wrap the initialization of 'service' in its own useMemo() Hook.  react-hooks/exhaustive-deps

./hooks/useConnection.ts
38:40  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
148:40  Warning: Unexpected any. Specify a different type.  @typescript-eslint/no-explicit-any
176:6  Warning: React Hook useEffect has missing dependencies: 'handleOnlineStatusChange' and 'performStabilityCheck'. Either include them or remove the dependency array.  react-hooks/exhaustive-deps

info  - Need to disable some ESLint rules? Learn more here: https://nextjs.org/docs/app/api-reference/config/eslint#disabling-rules
Failed to compile.

.next/types/app/(auth)/forgot-password/page.ts:3:59
Type error: Could not find a declaration file for module 'next/dist/lib/metadata/types/metadata-interface.js'. 'C:/Users/Tom/dev/minerva/node_modules/next/dist/lib/metadata/types/metadata-interface.js' implicitly has an 'any' type.
  Try `npm i --save-dev @types/next` if it exists or add a new declaration (.d.ts) file containing `declare module 'next/dist/lib/metadata/types/metadata-interface.js';`

  1 | // File: C:\Users\Tom\dev\minerva\app\(auth)\forgot-password\page.tsx
  2 | import * as entry from '../../../../../app/(auth)/forgot-password/page.js'
> 3 | import type { ResolvingMetadata, ResolvingViewport } from 'next/dist/lib/metadata/types/metadata-interface.js'
    |                                                           ^
  4 |
  5 | type TEntry = typeof import('../../../../../app/(auth)/forgot-password/page.js')
  6 |
Next.js build worker exited with code: 1 and signal: null
PS C:\Users\Tom\dev\minerva> 