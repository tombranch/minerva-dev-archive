# Google Maps & Places Integration Plan

**Document Version:** 1.0
**Date:** July 17, 2025
**Status:** Proposed
**Objective:** Integrate Google Maps Platform to add location context to photos, enabling site-based organization, customer management, and enhanced data for AI processing.

---

## 1. Overview & Business Value

Integrating Google Maps will transform the application from a photo organizer into a location-aware safety management tool. This provides immense value by:

-   **Improving Organization:** Users can group photos by physical sites and customers.
-   **Enhancing AI Context:** Location data (e.g., "Site: Main Production Facility") can be fed into the AI models to dramatically improve the accuracy and relevance of tags and descriptions.
-   **Streamlining Workflows:** Automatically suggesting sites based on photo GPS data saves users time.
-   **Providing Visual Context:** A map view in the photo details provides immediate spatial awareness, similar to the experience in Google Photos.

## 2. Feature Breakdown & Complexity

**Overall Difficulty:** Moderately Complex but Very Achievable.

This feature touches the full stack: database, backend, frontend, and a third-party API integration.

| Feature Component                 | Description                                                                                                | Complexity |
| --------------------------------- | ---------------------------------------------------------------------------------------------------------- | ---------- |
| **GCP & API Setup**               | Configure Google Cloud project, enable APIs (Maps, Places, Geocoding), and secure API keys.                | Low        |
| **Database Schema**               | Add `customers` and `sites` tables. Add `site_id` foreign key to the `photos` table.                       | Medium     |
| **Backend: EXIF Extraction**      | On upload, extract GPS data from photos using a library like `exif-parser`.                                | Medium     |
| **Backend: API Endpoints**        | Create CRUD APIs for `customers` and `sites`. Add logic for reverse geocoding and site suggestions.        | Medium     |
| **Frontend: Customer/Site UI**    | Build a new dashboard section for managing customers and sites.                                            | Medium     |
| **Frontend: Upload Workflow**     | Add a "Site" selection step to the upload modal, with Google Places Autocomplete.                          | High       |
| **Frontend: Map View**            | Create a `PhotoLocationMap` component using `@react-google-maps/api` for the photo detail modal.           | Medium     |

---

## 3. High-Level Implementation Plan

### **Phase 1: Foundation & Backend (1 Week)**

1.  **Google Cloud Platform (GCP) Setup:**
    *   Create a new GCP project.
    *   Enable APIs: **Maps JavaScript API**, **Places API**, **Geocoding API**.
    *   Create and secure an API key, restricting it to the app's domain and required APIs.
    *   Add `GOOGLE_MAPS_API_KEY` to `lib/env.ts` and `env-validation.ts`.

2.  **Database Schema Changes (Supabase Migration):**
    *   **New Table: `customers`**
        *   `id` (uuid, pk)
        *   `name` (text, not null)
        *   `organization_id` (uuid, fk to `organizations.id`)
        *   `created_at` (timestamptz)
    *   **New Table: `sites`**
        *   `id` (uuid, pk)
        *   `customer_id` (uuid, fk to `customers.id`, nullable)
        *   `organization_id` (uuid, fk to `organizations.id`)
        *   `name` (text, not null)
        *   `address` (text)
        *   `latitude` (float8, not null)
        *   `longitude` (float8, not null)
        *   `created_at` (timestamptz)
    *   **Modify Table: `photos`**
        *   Add `site_id` (uuid, fk to `sites.id`, nullable).

3.  **Backend Logic & API Endpoints (`app/api/`):**
    *   **EXIF Extraction:** Update `lib/upload-processor.ts` to extract GPS data during upload.
    *   **Reverse Geocoding:** If GPS data exists, use the Geocoding API to get an address and suggest nearby sites.
    *   **New API Routes:**
        *   `/api/customers` (GET, POST, PUT, DELETE)
        *   `/api/sites` (GET, POST, PUT, DELETE)
        *   `/api/sites/autocomplete` (GET - powered by Places API)

### **Phase 2: Frontend Integration & UI/UX (1-2 Weeks)**

1.  **Customer & Site Management UI:**
    *   Create a new route `app/dashboard/organization/sites` with a data table to manage customers and sites.

2.  **Updated Upload Workflow:**
    *   Modify the upload modal to include an optional "Assign to a Site" step.
    *   Use Google Places Autocomplete for the site address input.
    *   If EXIF data was found, automatically suggest the closest site.

3.  **Photo Detail Map View:**
    *   Create `components/photos/photo-location-map.tsx`.
    *   Use `@react-google-maps/api` to render a map with a pin for the photo's site.
    *   Integrate this component into `components/photos/photo-detail-modal.tsx`.

---

## 4. Potential Challenges & Mitigation

-   **Cost:** Google Maps APIs are pay-as-you-go.
    -   **Mitigation:** Monitor usage closely. Use the `ai-cost-tracker.ts` as a model. Cache geocoding results where possible.
-   **API Key Security:** Frontend API keys can be exposed.
    -   **Mitigation:** Use strict HTTP referrer restrictions in GCP to ensure the key only works on the application's domain.
-   **Missing EXIF Data:** Most photos will not have GPS data.
    -   **Mitigation:** The primary workflow must be manual site selection. EXIF-based suggestion is a progressive enhancement, not a requirement.
-   **GPS Inaccuracy:** GPS data can be off.
    -   **Mitigation:** Always present location information as a suggestion for the user to confirm.

## 5. Success Metrics

-   Percentage of photos assigned to a site.
-   User engagement with the customer/site management UI.
-   Reduction in time-to-organize for users who adopt the feature.
-   Qualitative feedback on the usefulness of the map view.
