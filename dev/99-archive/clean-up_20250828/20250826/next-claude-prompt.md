# Next Claude Instance Prompt

Complete Phase 5C test suite fixes. Current status: 67 tests passing, 26 failing.

**Task**: Fix remaining test failures to achieve 100% test pass rate.

**Reference Document**: Read the comprehensive implementation plan at:
`C:\Users\Tom\dev\minerva\dev\03-in-progress\clean-up\20250826\phase-5c-remaining-test-fixes.md`

**Main Issues to Fix**:
1. Security contract test failures (XSS, SQL injection prevention)
2. E2E test timeouts and authentication setup
3. Request validation and rate limiting mocks

**Quick Start**:
1. Run `npm test` to see current failures
2. Follow the detailed plan in the reference document
3. Focus on security mock validations in `tests/api-contracts/test-utils.ts`
4. Fix E2E authentication setup in `e2e/ai-management-complete-flows.spec.ts`

**Success Criteria**: All tests passing with `npm test && npm run test:e2e`

**Timeline**: ~7 hours estimated in the plan