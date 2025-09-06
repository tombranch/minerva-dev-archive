# Spell Check & Autocorrect Enhancement Plan

## Status: Quick Win Implemented ✅

Native browser spell check has been added to all text inputs and textareas by updating the base UI components:
- `/components/ui/input.tsx` - Added `spellCheck={true}` by default (disabled for non-text inputs)
- `/components/ui/textarea.tsx` - Added `spellCheck={true}` by default

This automatically enables spell checking across all components that use these base components including:
- Photo chat interface
- Photo notes (creating/editing)
- Project descriptions
- Search bars
- Organization settings
- All form inputs throughout the app

## Future AI-Powered Enhancements

### Option 1: OpenAI GPT-Based Spell & Grammar Check

**Pros:**
- Leverages existing OpenAI infrastructure (already referenced in super-admin settings)
- Contextual grammar and style corrections
- Can handle industry-specific terminology
- Advanced corrections beyond basic spell check

**Implementation:**
```typescript
// Backend API route: /api/spell-check
export async function POST(request: Request) {
  const { text } = await request.json();
  
  const response = await openai.chat.completions.create({
    model: "gpt-3.5-turbo",
    messages: [
      {
        role: "system",
        content: "You are a copy editor that corrects spelling and grammar errors. Return only the corrected text, no explanations."
      },
      {
        role: "user",
        content: `Correct the spelling and grammatical errors in the following text: ${text}`
      }
    ]
  });
  
  return Response.json({ correctedText: response.choices[0].message.content });
}

// React hook for spell checking
export function useSpellCheck() {
  const [isChecking, setIsChecking] = useState(false);
  
  const checkSpelling = async (text: string) => {
    setIsChecking(true);
    try {
      const response = await fetch('/api/spell-check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text })
      });
      const { correctedText } = await response.json();
      return correctedText;
    } finally {
      setIsChecking(false);
    }
  };
  
  return { checkSpelling, isChecking };
}
```

**Component Integration:**
```typescript
function EnhancedTextarea({ value, onChange, ...props }) {
  const { checkSpelling, isChecking } = useSpellCheck();
  
  const handleSpellCheck = async () => {
    const corrected = await checkSpelling(value);
    onChange(corrected);
  };
  
  return (
    <div className="relative">
      <Textarea value={value} onChange={onChange} {...props} />
      <Button 
        onClick={handleSpellCheck} 
        disabled={isChecking}
        className="absolute top-2 right-2"
        size="sm"
      >
        {isChecking ? <Loader2 className="h-4 w-4 animate-spin" /> : "Check Spelling"}
      </Button>
    </div>
  );
}
```

**Cost Estimate:** ~$0.001-0.003 per correction request

### Option 2: Sapling AI Integration

**Pros:**
- Specialized in grammar and spell checking
- Multi-language support (10+ languages)
- Real-time corrections
- Lower cost than OpenAI for this specific use case

**Implementation:**
```bash
npm install sapling-js
```

```typescript
import { SaplingClient } from 'sapling-js';

const client = new SaplingClient({
  key: process.env.SAPLING_API_KEY
});

export async function checkText(text: string) {
  const response = await client.edits({
    text,
    session_id: 'unique-session-id'
  });
  
  return response.edits.map(edit => ({
    start: edit.start,
    end: edit.end,
    replacement: edit.replacement,
    error_type: edit.error_type
  }));
}
```

**Cost Estimate:** ~$0.001 per 1000 characters

### Option 3: Search Enhancement with Typo Tolerance

**For search functionality specifically:**

```typescript
// Using Typesense (open-source, self-hostable)
npm install typesense

const typesense = new Typesense.Client({
  nodes: [{ host: 'localhost', port: 8108, protocol: 'http' }],
  apiKey: process.env.TYPESENSE_API_KEY
});

// Search with typo tolerance
export async function searchWithTypoTolerance(query: string) {
  return await typesense.collections('photos').documents().search({
    q: query,
    query_by: 'title,description,tags',
    typo_tokens_threshold: 1,
    drop_tokens_threshold: 2,
    num_typos: 2
  });
}
```

**Algolia Alternative (paid service):**
```typescript
const algoliasearch = require('algoliasearch');
const client = algoliasearch('APP_ID', 'API_KEY');

const index = client.initIndex('photos');
const results = await index.search(query, {
  typoTolerance: 'strict',
  attributesToRetrieve: ['title', 'description', 'tags']
});
```

### Option 4: Manufacturing/Safety Terminology Dictionary

**Custom dictionary for industry-specific terms:**

```typescript
const manufacturingTerms = [
  'lockout tagout', 'LOTO', 'pinch point', 'safety barrier',
  'light curtain', 'emergency stop', 'e-stop', 'machine guard',
  'conveyor belt', 'hydraulic press', 'CNC machine', 'safety switch'
];

// Add to browser's spell check dictionary
function addCustomDictionary() {
  // This would require browser extension or custom implementation
  // Could integrate with AI services to recognize these terms
}
```

## Implementation Priority

1. **Immediate (Already Done)**: Native browser spell check
2. **Phase 1**: OpenAI GPT integration for major text areas (notes, descriptions)
3. **Phase 2**: Search typo tolerance using Typesense
4. **Phase 3**: Custom manufacturing terminology dictionary
5. **Phase 4**: Real-time spell checking with Sapling AI

## Technical Requirements

- **Backend**: Node.js API routes for AI service integration
- **Frontend**: React hooks for spell check functionality
- **Security**: API keys stored securely, rate limiting
- **User Experience**: Non-intrusive spell check buttons/options
- **Settings**: User preference to enable/disable advanced spell check

## Cost Considerations

- **OpenAI**: ~$20-50/month for moderate usage
- **Sapling**: ~$10-30/month for text checking
- **Typesense**: Free (self-hosted) or ~$20/month (cloud)
- **Algolia**: ~$50-200/month depending on search volume

## User Settings Integration

Add spell check preferences to user settings:

```typescript
interface UserSettings {
  spellCheck: {
    enabled: boolean;
    provider: 'browser' | 'openai' | 'sapling';
    realTimeChecking: boolean;
    manufacturingTerms: boolean;
  };
}
```

## Files to Modify (Future Implementation)

- `components/ui/input.tsx` - Add spell check button option
- `components/ui/textarea.tsx` - Add spell check button option
- `app/api/spell-check/route.ts` - New API endpoint
- `hooks/use-spell-check.ts` - New React hook
- `app/settings/page.tsx` - Add spell check preferences
- `lib/spell-check/` - New spell check utility functions

## Notes for Implementation

- Start with OpenAI integration since infrastructure already exists
- Consider user feedback before implementing real-time checking
- Manufacturing terms dictionary would be highly valuable for this industry
- Mobile support should be considered for all implementations
- Test thoroughly with different browsers and devices