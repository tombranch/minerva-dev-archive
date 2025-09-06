# Global AI Assistant & Super Admin Configuration Plan

**Status**: Someday/Maybe - Future Enhancement
**Created**: 2025-01-21
**Complexity**: High (4 weeks, multiple phases)
**Dependencies**: Existing photo chat system (already implemented)

## Executive Summary

Transform Minerva's existing photo-specific chatbot into a **global, context-aware AI assistant** accessible throughout the application, with a **super admin configuration dashboard** for complete customization of AI behavior, personality, and technical parameters.

## Current State Analysis

### ✅ Sophisticated Photo Chat System Already Exists:
- PhotoChat component with full AI conversations
- FloatingPhotoChat widget (draggable, resizable, mobile-responsive)
- Complete API at /api/photos/[id]/chat with Google Gemini integration
- Database support via photo_notes table with message threading
- Industrial safety expertise with tag management commands
- Spell correction for common safety/industrial terms
- Context-aware responses using photo metadata

### ✅ Super Admin Infrastructure Ready:
- Complete super admin panel at /super-admin/ with role-based access
- Admin panels for organizations, users, and system monitoring
- Database schema supports super_admin role in users table

## Plan: Global AI Assistant Expansion

### 🎯 Goal

Transform the existing photo-specific chatbot into a global, context-aware AI assistant accessible throughout the Minerva application, with a super admin configuration dashboard for complete customization.

---

## Phase 1: Global Chat Infrastructure (Week 1)

### 1.1 Create Global Chat System

**Global Chat Widget Component** (components/chat/global-chat-widget.tsx)
- Based on existing FloatingPhotoChat architecture
- Context-aware positioning and behavior
- Persistent across page navigation
- Mobile-responsive with bottom sheet on mobile

**Global Chat Provider** (providers/chat-provider.tsx)
- App-wide state management for chat visibility/position
- Context detection (current page, selected items, user state)
- Conversation history and persistence
- Integration with existing auth and data providers

**Global Chat API** (/api/chat/global/route.ts)
- Organization-wide conversations
- Context-aware responses based on current page/data
- Conversation threading and history
- Integration with existing AI infrastructure

### 1.2 Database Schema Extension

**New chat_conversations table:**
```sql
CREATE TABLE chat_conversations (
  id UUID PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id),
  user_id UUID REFERENCES auth.users(id),
  conversation_type TEXT CHECK (conversation_type IN ('global', 'photo', 'project', 'site')),
  context_id UUID, -- photo_id, project_id, etc.
  title TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Extend photo_notes table:**
```sql
ALTER TABLE photo_notes ADD COLUMN conversation_id UUID REFERENCES chat_conversations(id);
ALTER TABLE photo_notes ADD COLUMN conversation_type TEXT DEFAULT 'photo';
```

### 1.3 Layout Integration

- Add GlobalChatWidget to protected layout (app/(protected)/layout.tsx)
- Ensure persistence across all protected routes
- Handle state during page transitions
- Context detection middleware

---

## Phase 2: Super Admin Configuration Dashboard (Week 2)

### 2.1 Chatbot Configuration Interface

**New page: /super-admin/chatbot-config**

#### 🤖 AI Personality & Behavior Settings:
- Assistant Name (default: "Minerva Assistant")
- Personality Description (friendly, professional, technical expert)
- Response Style (concise, detailed, conversational)
- Safety Context Emphasis (high, medium, low)

#### 🧠 AI Model Configuration:
- Temperature (0.1 - 2.0, default: 0.7)
- Max Response Length (100-2000 tokens, default: 1000)
- Context Window (how much conversation history to include)
- Response Confidence Threshold

#### 💬 System Prompts Management:
- Global System Prompt (base personality and context)
- Photo Analysis Prompt (specific to photo conversations)
- Project Context Prompt (for project-related discussions)
- Site Context Prompt (for site/location discussions)
- Safety Expertise Prompt (industrial safety knowledge)

#### 🎯 Context Awareness Settings:
- Auto-detect Context (toggle)
- Context Switching Behavior (automatic vs manual)
- Context Indicators (show current context to users)
- Context Memory (remember context across conversations)

### 2.2 Advanced Configuration Options

#### 📊 Analytics & Monitoring:
- Conversation Analytics (usage patterns, popular topics)
- Response Quality Metrics (user feedback, conversation length)
- Cost Tracking (API usage, token consumption)
- Error Rate Monitoring (failed responses, timeouts)

#### 🔧 Technical Settings:
- API Rate Limits (requests per minute/hour)
- Retry Logic (max retries, backoff strategy)
- Fallback Responses (when AI fails)
- Content Filtering (inappropriate content detection)

#### 🏢 Organization-Specific Overrides:
Allow specific organizations to customize:
- Assistant name and personality
- Industry-specific prompts
- Custom safety terminology
- Specialized knowledge bases

### 2.3 Configuration Database Schema

**New chatbot_config table:**
```sql
CREATE TABLE chatbot_config (
  id UUID PRIMARY KEY,
  organization_id UUID REFERENCES organizations(id), -- null = global config
  config_type TEXT CHECK (config_type IN ('global', 'organization')),
  assistant_name TEXT,
  personality_description TEXT,
  system_prompts JSONB,
  model_settings JSONB, -- temperature, max_tokens, etc.
  context_settings JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by UUID REFERENCES auth.users(id)
);
```

---

## Phase 3: Context-Aware Features (Week 3)

### 3.1 Smart Context Detection

#### 📄 Page-Specific Context:
- **Photos Page**: Access to current photo grid, filters, selected photos
- **Project Page**: Current project details, members, recent activity
- **Sites Page**: Location information, recent photos from site
- **Dashboard**: Organization metrics, recent activity summary
- **Analytics**: Current reports, data being viewed

#### 🔍 Dynamic Context Switching:
- Detect when user navigates between contexts
- Smooth transition messages ("Now helping with Project Alpha...")
- Context breadcrumbs in chat interface
- Option to manually switch contexts

### 3.2 Enhanced AI Capabilities

#### 🧠 Contextual Responses:
- "Show me recent photos from this project"
- "What safety issues were found at Site B last month?"
- "Help me organize these photos by equipment type"
- "Create a summary report of current project status"

#### 🎯 Proactive Assistance:
- Suggest actions based on current context
- Alert about potential safety issues
- Recommend organizational improvements
- Offer relevant quick actions

### 3.3 Integration with Existing Features

#### 🔗 Connect with Current Systems:
- **Smart Albums integration** (suggest albums, help organize)
- **Search integration** (help refine queries, suggest filters)
- **Analytics integration** (explain metrics, suggest insights)
- **User management** (help with invitations, role assignments)

---

## Phase 4: Mobile & UX Optimization (Week 4)

### 4.1 Mobile-First Experience

#### 📱 Mobile Optimizations:
- Bottom sheet implementation for mobile
- Touch-optimized resize handles
- Gesture support (swipe to minimize/close)
- Keyboard-aware positioning
- Offline capability indicators

### 4.2 Accessibility & Polish

#### ♿ Accessibility Features:
- Screen reader support for all chat interactions
- Keyboard navigation throughout chat interface
- High contrast mode compatibility
- Voice input support (browser-based)

#### ✨ UX Enhancements:
- Smooth animations for context switching
- Loading states and typing indicators
- Message reactions and feedback
- Conversation bookmarking
- Export conversation feature

---

## Implementation Benefits

### 🎯 User Experience
- Unified AI assistance across entire application
- Context-aware help that understands current user task
- Consistent interaction model users learn once, use everywhere
- Mobile-optimized for field engineers and inspectors

### 🔧 Administrative Control
- Complete customization of AI personality and behavior
- Organization-specific configurations and overrides
- Real-time monitoring of AI performance and usage
- Cost control through usage analytics and limits

### 🏗️ Technical Architecture
- Builds on existing robust photo chat infrastructure
- Maintains backwards compatibility with current photo chat
- Scalable design supports future context types
- Secure implementation with role-based configuration access

### 📊 Business Value
- Improved user adoption through contextual assistance
- Reduced support tickets via self-service AI help
- Enhanced safety compliance through AI-guided workflows
- Valuable usage analytics for product development

---

## File Structure Overview

```
📁 components/chat/
├── global-chat-widget.tsx         # Main global chat widget
├── chat-context-provider.tsx      # Context detection & management
├── conversation-manager.tsx       # Conversation history & threading
└── chat-analytics.tsx            # Usage tracking & metrics

📁 app/api/chat/
├── global/route.ts                # Global chat API endpoint
├── config/route.ts               # Chat configuration API
└── analytics/route.ts            # Chat analytics API

📁 app/(protected)/super-admin/
└── chatbot-config/
    ├── page.tsx                   # Main config dashboard
    ├── personality-settings.tsx   # AI personality configuration
    ├── prompt-management.tsx      # System prompts editor
    ├── model-settings.tsx         # Technical AI parameters
    └── analytics-overview.tsx     # Usage analytics

📁 providers/
└── chat-provider.tsx             # Global chat state management

📁 lib/chat/
├── context-detection.ts          # Smart context detection
├── conversation-service.ts       # Chat business logic
└── config-service.ts            # Configuration management
```

This plan leverages the excellent existing chat infrastructure while expanding it into a comprehensive, configurable, global AI assistant system.