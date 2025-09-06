# Remaining MVP Tasks

This report outlines the outstanding tasks required to complete the Minimum Viable Product (MVP).

## A) Organization Context Hardening

*   **Task:** Replace client-side organization derivation in the Photos page.
*   **File:** `app/(protected)/photos/page.tsx`
*   **Details:** The page currently uses a temporary fix (`user?.user_metadata?.organization_id`) to get the organization ID. This should be replaced with a more secure, server-validated method, such as a hook (`useAuth`) or a server-provided property.

## B) AI/Analytics API Security Standardization

*   **Task:** Secure the analytics summary route.
*   **File:** `app/api/ai/analytics/summary/route.ts`
*   **Details:** The endpoint should be wrapped in the `withAuth` middleware to enforce organization-scoped access and prevent unauthorized data access.

*   **Task:** Review and standardize authentication on all AI endpoints.
*   **Files:** `app/api/ai/**/*`
*   **Details:** A comprehensive review of all AI-related API endpoints is needed to ensure consistent use of the `withAuth` middleware and rate limiting where appropriate.

## D) Production Hygiene

*   **Task:** Gate or remove the test data page in production.
*   **File:** `app/platform/test-data/page.tsx`
*   **Details:** This page, which allows for the creation of test data, is currently accessible in production. It should be conditionally rendered based on an environment variable (e.g., `NEXT_PUBLIC_ENABLE_TEST_DATA`) or removed entirely from production builds.

*   **Task:** Remove empty and legacy directories.
*   **File:** `app/ai-management`
*   **Details:** The `app/ai-management` directory is empty and should be removed from the project to improve code hygiene.
