# Custom Model Context Protocol (MCP) Strategy

This document outlines the strategy for implementing custom Model Context Protocol (MCP) providers within the Minerva application. The goal is to standardize how our AI features receive contextual information, making them more robust, modular, and easier to develop.

## What is a Custom MCP Provider?

Think of a custom MCP provider as a dedicated, internal API endpoint for our AI. Instead of AI features directly fetching data from various parts of the application (e.g., user session, current page, selected items), they will request specific "context resources" from a centralized MCP system. Each provider is responsible for gathering and formatting a particular piece of context according to the MCP specification.

## Why Implement Custom MCPs?

1.  **Standardization**: Provides a consistent interface for AI models to consume application context, regardless of the underlying data source.
2.  **Modularity & Reusability**: Context providers are self-contained units. We can combine different providers to build complex AI features without duplicating data fetching logic. For example, an AI feature needing user and project context simply requests both providers.
3.  **Separation of Concerns**: AI logic (e.g., in `hooks/useAI.ts`) becomes cleaner, focusing solely on interacting with the AI model. It doesn't need to know *how* user data is fetched; it just requests the `user` context.
4.  **Improved Developer Experience**: Speeds up the development of new AI features by providing a ready-made, structured way to access relevant application state.
5.  **Testability**: Individual context providers can be tested in isolation, ensuring the accuracy and reliability of the context provided to the AI.

## What to Focus On (Key Principles)

*   **User-Centricity**: Prioritize context providers that offer information about the user (who they are, what they're doing, where they are in the app). This is the most valuable context for personalized AI interactions.
*   **Read-Only First**: Initially, focus on providing data *to* the AI (MCP "Resources"). Implementing AI-driven actions (MCP "Tools") can be considered in later phases.
*   **Single Responsibility**: Each provider should be narrowly focused on a specific type of context (e.g., `UserContextProvider` for user data, `SelectionContextProvider` for selected items).
*   **Security and Privacy**: Be extremely cautious about what data is exposed. Ensure sensitive information is never included in context resources.

## Recommended Action Plan

### Phase 1: Build the Foundation

Establish the core infrastructure for managing custom MCP providers.

1.  **Create a Provider Registry**: Implement a central registry (e.g., a Map in `lib/mcp/index.ts`) to store and manage all custom context providers.
2.  **Define Provider Interface**: Define a TypeScript interface (`MCPProvider`) that all custom providers must adhere to, specifying a `name` and a `getContext()` method.
3.  **Integrate with Core AI Hook**: Modify the primary AI interaction hook (`hooks/useAI.ts`) to utilize this new registry. Instead of ad-hoc data fetching, it will request context by provider name from the registry.

### Phase 2: Implement High-Value Context Providers

Develop specific providers based on the application's needs and the "User-Centricity" principle.

1.  **`UserContextProvider`**: Provides details about the currently authenticated user (e.g., ID, name, roles, permissions).
    *   *Example Data*: `{ "id": "user123", "name": "John Doe", "role": "admin" }`
2.  **`NavigationContextProvider`**: Informs the AI about the user's current location within the application.
    *   *Example Data*: `{ "path": "/app/photos/album/summer-2024", "pageTitle": "Summer 2024 Album" }`
3.  **`SelectionContextProvider`**: Offers context about items the user has actively selected (e.g., photos, documents, text).
    *   *Example Data*: `{ "type": "photos", "count": 3, "ids": ["photoA", "photoB", "photoC"] }`
4.  **`ProjectContextProvider`**: Provides details about the specific project or workspace the user is currently interacting with.
    *   *Example Data*: `{ "projectId": "proj456", "projectName": "Minerva Marketing Campaign", "status": "active" }`

### Phase 3: Advanced Capabilities and Tooling

Once the core context provision is stable, consider expanding.

*   **Exposing AI Tools**: Implement MCP "Tools" that allow the AI to trigger actions within the application (e.g., `createTask`, `updatePhotoTags`). This requires careful security considerations.
*   **Dynamic Context**: Explore ways to provide context that changes based on real-time user input or application events.
*   **Monitoring and Logging**: Implement logging for context requests to understand how AI models are utilizing the provided information.

By following this strategy, Minerva can build a sophisticated and highly contextual AI experience.
