# Comprehensive Testing Enhancement Plan

**Document Version:** 1.0  
**Date:** July 14, 2025  
**Objective:** To implement missing tests and close critical gaps in the project's testing strategy, ensuring production-ready quality, security, and reliability.

---

## 1. Overview

This document outlines a phased implementation plan to address the testing gaps identified in the project review. The goal is to build upon the existing strong testing foundation by adding specific, high-value tests that cover security vulnerabilities, user experience edge cases, and performance regressions.

By completing this plan, the project will have a comprehensive test suite that provides maximum confidence for the MVP launch and future development.

## 2. Implementation Phases

The work is divided into three logical phases, which can be executed in order of priority:

*   **Phase 1: Security & Authorization (Critical Priority):** Focuses on closing critical security gaps in permissions and data access.
*   **Phase 2: User Experience & Failure States (High Priority):** Ensures the application is robust and handles errors gracefully from the user's perspective.
*   **Phase 3: Performance & Advanced Scenarios (Medium Priority):** Establishes baselines to prevent performance regressions and tests complex E2E failure modes.

---

## 3. Phase 1: Security & Authorization Tests

**Goal:** Verify that all authentication and authorization rules, especially Row Level Security (RLS), are working correctly to prevent unauthorized data access.

### Task 1.1: Implement Role-Based Access Control (RBAC) Integration Tests

*   **Description:** Create tests to ensure that users with specific roles can only access the resources and perform the actions permitted for that role.
*   **Files to Create/Modify:**
    *   `__tests__/integration/security/rbac.test.ts` (new file)
    *   `__tests__/__mocks__/handlers.ts` (add mock API handlers)
*   **Tools Required:** Vitest, Mock Service Worker (MSW)
*   **Key Scenarios to Test:**
    *   An `engineer` user attempts to access an admin-only API endpoint (e.g., `/api/admin/users`) and receives a `403 Forbidden` error.
    *   An `admin` user successfully accesses an admin-only API endpoint.
    *   An unauthenticated user is redirected from a protected client-side route to the login page.
    *   An `engineer` user does not see admin-only UI elements (e.g., the "Admin Dashboard" link).

### Task 1.2: Implement Cross-Organization Data Access Tests

*   **Description:** These are the most critical security tests. They must prove that a user from one organization cannot view, modify, or delete data belonging to another organization.
*   **Files to Create/Modify:**
    *   `__tests__/integration/security/rls.test.ts` (new file)
    *   `test/setup.ts` (to seed data for multiple organizations)
*   **Tools Required:** Vitest, Supabase Test Client
*   **Key Scenarios to Test:**
    *   **Setup:** Create `User A` in `Organization A` and `User B` in `Organization B`. Create `Photo A` belonging to `Organization A`.
    *   **Test:** As `User B`, attempt to fetch `Photo A` directly via its ID from the `/api/photos/[id]` endpoint. Verify the API returns a `404 Not Found` or `403 Forbidden` error.
    *   **Test:** As `User B`, attempt to update the metadata for `Photo A`. Verify the operation fails with a `403` or `404` error.
    *   **Test:** As `User B`, call the `/api/photos` list endpoint. Verify that `Photo A` is not present in the response.

---

## 4. Phase 2: User Experience & Failure State Tests

**Goal:** Ensure the application provides a robust and informative user experience, especially when things go wrong.

### Task 2.1: Implement Component Error & Loading State Tests

*   **Description:** For all key data-driven components, add tests to verify they render correctly during loading, error, and empty-data states.
*   **Files to Create/Modify:**
    *   `__tests__/components/photos/photo-grid.test.tsx` (modify)
    *   `__tests__/components/admin/user-management.test.tsx` (modify)
*   **Tools Required:** Vitest, React Testing Library, MSW
*   **Key Scenarios to Test:**
    *   **PhotoGrid:**
        *   When the `/api/photos` endpoint is pending, verify that a loading skeleton component is rendered.
        *   When the API returns a 500 error, verify that a user-friendly error message is displayed.
        *   When the API returns an empty array `[]`, verify that a "No photos found" message is displayed.

### Task 2.2: Implement Business Logic Edge Case Tests

*   **Description:** Add unit tests for critical business logic to ensure it handles boundary conditions correctly.
*   **Files to Create/Modify:**
    *   `__tests__/lib/ai-cost-tracker.test.ts` (new file)
    *   `__tests__/lib/rate-limiter.test.ts` (new file)
*   **Tools Required:** Vitest
*   **Key Scenarios to Test:**
    *   **AI Cost Tracker:**
        *   Test behavior when the monthly cost is exactly at the limit.
        *   Test behavior when a single API call pushes the cost over the limit.
    *   **Rate Limiter:**
        *   Test that the Nth request (where N is the limit) is allowed.
        *   Test that the N+1th request is blocked.
        *   Test that the limiter resets correctly after the time window expires.

---

## 5. Phase 3: Performance & Advanced Scenarios

**Goal:** Establish performance baselines and test complex, realistic end-to-end failure modes.

### Task 3.1: Create Performance Baseline E2E Tests

*   **Description:** Develop a suite of E2E tests that measure key performance indicators and fail if they regress beyond a set threshold.
*   **Files to Create/Modify:**
    *   `e2e/performance.spec.ts` (new file)
    *   `playwright.config.ts` (add a new project for performance tests)
*   **Tools Required:** Playwright
*   **Key Scenarios to Test:**
    *   **Dashboard Load Time:**
        *   Seed the test database with ~500 photos.
        *   Write a Playwright test to navigate to the photo dashboard and measure the `load` event time and the time to first visual content.
        *   Assert that this time is below the PRD target (e.g., `< 3 seconds`). Store this as a baseline.

### Task 3.2: Implement E2E Failure Scenario Tests

*   **Description:** Use Playwright's network interception capabilities to simulate real-world failures during a complete user journey.
*   **Files to Create/Modify:**
    *   `e2e/failure-scenarios.spec.ts` (new file)
*   **Tools Required:** Playwright
*   **Key Scenarios to Test:**
    *   **Intermittent Upload Failure:**
        *   Begin a batch upload of 5 photos.
        *   Use `page.route()` to intercept the network request for the 3rd photo and make it fail with a 500 server error.
        *   Assert that the UI correctly shows the first 2 photos as successful, the 3rd as failed (with a retry option), and the last 2 as successful.
    *   **AI Processing API Failure:**
        *   Upload a single photo successfully.
        *   Intercept the call to the AI processing endpoint and simulate a timeout or a 503 error.
        *   Navigate to the photo details page and assert that the photo has a "Processing Failed" status and that a notification was shown to the user.

## 6. Timeline & Effort Estimation

*   **Phase 1 (Security):** 2-3 days
*   **Phase 2 (UX & Edge Cases):** 2-3 days
*   **Phase 3 (Performance & E2E):** 1-2 days
*   **Total Estimated Effort:** 5-8 development days

## 7. CI/CD Integration

*   The existing GitHub Actions workflow in `.github/workflows/test.yml` should be updated.
*   A new, separate job for security integration tests (`rbac.test.ts`, `rls.test.ts`) should be added. This job will require a running Supabase instance (or a containerized Postgres service) to run against.
*   The performance baseline tests should be run in a separate, scheduled workflow (e.g., nightly) against the staging environment to monitor for regressions over time.

---

By executing this plan, the Minerva project will have a robust, production-grade test suite that covers not only the "happy paths" but also the critical failure modes and security vulnerabilities, ensuring a high-quality launch.
