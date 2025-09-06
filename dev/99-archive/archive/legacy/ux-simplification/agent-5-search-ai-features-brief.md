# Agent 5: Search & AI Features Brief

**Duration:** 1 week  
**Priority:** Medium  
**Dependencies:** Agent 1 (smart albums), Agent 3 (simplified photos)

## Mission

Transform the search experience from complex filtering to intelligent, AI-powered search with natural language support, visual search capabilities, and smart suggestions. Implement smart album recommendations and create an intuitive search interface that leverages existing AI tagging infrastructure.

## Objectives

1. Replace complex filters with intelligent search bar
2. Implement natural language search processing
3. Add visual search with image upload capability
4. Create smart album suggestion system
5. Build AI-powered search suggestions and autocomplete
6. Implement search result optimization and ranking
7. Add "More like this" functionality
8. Document AI features and create handover materials

## Current Search Issues

### Existing Problems
- Multiple filter dropdowns overwhelming users
- Complex boolean search not user-friendly
- No natural language support
- Advanced filtering buried in UI
- No visual search capabilities
- Limited AI integration despite rich tagging

### Target Improvements
- Single intelligent search bar
- Natural language queries ("Show me all pinch points from last month")
- Visual search with reference photos
- AI-powered suggestions and autocomplete
- Smart album recommendations
- Contextual search results

## Implementation Requirements

### Intelligent Search Architecture

#### Search Input Component
```typescript
const IntelligentSearch = () => {
  const [query, setQuery] = useState('');
  const [suggestions, setSuggestions] = useState([]);
  const [searchType, setSearchType] = useState<'text' | 'visual'>('text');
  
  return (
    <div className="relative w-full max-w-2xl">
      <SearchInput
        value={query}
        onChange={setQuery}
        placeholder="Search photos, equipment, hazards, or sites..."
        onSubmit={handleSearch}
      />
      <SearchSuggestions suggestions={suggestions} />
      <VisualSearchButton onClick={enableVisualSearch} />
    </div>
  );
};
```

#### Natural Language Processing
```typescript
const parseNaturalLanguage = (query: string) => {
  const patterns = [
    // Time-based queries
    { pattern: /last (week|month|year)/i, type: 'time' },
    { pattern: /(today|yesterday|this week)/i, type: 'time' },
    
    // Equipment queries
    { pattern: /(conveyor|press|machine|motor)/i, type: 'equipment' },
    
    // Hazard queries
    { pattern: /(pinch point|sharp edge|hot surface)/i, type: 'hazard' },
    
    // Site queries
    { pattern: /(site|location|area) ([A-Z0-9]+)/i, type: 'site' },
    
    // Status queries
    { pattern: /(untagged|needs review|high priority)/i, type: 'status' }
  ];
  
  return patterns.find(p => p.pattern.test(query));
};
```

### Visual Search Implementation

#### Image Upload Search
```typescript
const VisualSearch = () => {
  const [searchImage, setSearchImage] = useState<File | null>(null);
  const [searchResults, setSearchResults] = useState([]);
  
  const handleImageSearch = async (image: File) => {
    const formData = new FormData();
    formData.append('image', image);
    
    const response = await fetch('/api/search/visual', {
      method: 'POST',
      body: formData
    });
    
    const results = await response.json();
    setSearchResults(results);
  };
  
  return (
    <Dropzone onDrop={handleImageUpload}>
      <p>Drop an image here to find similar photos</p>
    </Dropzone>
  );
};
```

#### Visual Similarity API
```typescript
// /api/search/visual/route.ts
export async function POST(request: Request) {
  const formData = await request.formData();
  const image = formData.get('image') as File;
  
  // Extract features using Google Vision API
  const features = await extractImageFeatures(image);
  
  // Find similar photos in database
  const similarPhotos = await findSimilarPhotos(features);
  
  return Response.json({ results: similarPhotos });
}
```

### Smart Suggestions System

#### AI-Powered Autocomplete
```typescript
const useSearchSuggestions = (query: string) => {
  const [suggestions, setSuggestions] = useState([]);
  
  useEffect(() => {
    if (query.length > 2) {
      const getSuggestions = async () => {
        const response = await fetch(`/api/search/suggestions?q=${query}`);
        const data = await response.json();
        setSuggestions(data.suggestions);
      };
      
      const debounced = debounce(getSuggestions, 300);
      debounced();
    }
  }, [query]);
  
  return suggestions;
};
```

#### Smart Album Recommendations
```typescript
const SmartAlbumSuggestions = () => {
  const { data: suggestions } = useSWR('/api/smart-albums/suggestions');
  
  return (
    <div className="mb-6">
      <h3>Suggested for you</h3>
      <div className="flex gap-2 overflow-x-auto">
        {suggestions?.map(album => (
          <AlbumSuggestionCard key={album.id} album={album} />
        ))}
      </div>
    </div>
  );
};
```

### Search Result Optimization

#### Ranking Algorithm
```typescript
const rankSearchResults = (results: Photo[], query: string, userContext: UserContext) => {
  return results.sort((a, b) => {
    let scoreA = 0, scoreB = 0;
    
    // Relevance scoring
    scoreA += calculateRelevanceScore(a, query);
    scoreB += calculateRelevanceScore(b, query);
    
    // Recency bonus
    scoreA += calculateRecencyScore(a.created_at);
    scoreB += calculateRecencyScore(b.created_at);
    
    // User preference (frequently viewed categories)
    scoreA += calculateUserPreferenceScore(a, userContext);
    scoreB += calculateUserPreferenceScore(b, userContext);
    
    return scoreB - scoreA;
  });
};
```

#### Search Analytics
```typescript
const trackSearchEvent = (query: string, resultsCount: number, userAction: string) => {
  posthog.capture('search_performed', {
    query: hashQuery(query), // Hash for privacy
    results_count: resultsCount,
    search_type: detectSearchType(query),
    user_action: userAction
  });
};
```

## Implementation Steps

1. **Day 1: Search Infrastructure**
   - Replace filter UI with search bar
   - Implement basic text search
   - Add search result routing
   - Connect to existing photo API

2. **Day 2: Natural Language Processing**
   - Build query parsing system
   - Implement common search patterns
   - Add intelligent query expansion
   - Test natural language queries

3. **Day 3: Visual Search**
   - Implement image upload interface
   - Build visual similarity API
   - Connect to Google Vision API
   - Test visual search accuracy

4. **Day 4: Smart Suggestions**
   - Build autocomplete system
   - Implement smart album suggestions
   - Add personalization logic
   - Create suggestion ranking

5. **Day 5: Search Optimization**
   - Implement result ranking
   - Add search analytics
   - Optimize search performance
   - Test with large datasets

6. **Day 6: Advanced Features**
   - Add "More like this" functionality
   - Implement search filters (date, type)
   - Add saved searches
   - Build search history

7. **Day 7: Polish & Testing**
   - Performance optimization
   - Cross-browser testing
   - Documentation
   - Handover preparation

## Key Files to Create/Modify

### New Files
- `components/search/IntelligentSearch.tsx`
- `components/search/VisualSearch.tsx`
- `components/search/SearchSuggestions.tsx`
- `components/search/SmartAlbumSuggestions.tsx`
- `components/search/SearchResults.tsx`
- `app/api/search/visual/route.ts`
- `app/api/search/suggestions/route.ts`
- `app/api/search/natural-language/route.ts`
- `lib/search/natural-language-parser.ts`
- `lib/search/visual-similarity.ts`
- `lib/search/ranking-algorithm.ts`
- `lib/search/search-analytics.ts`
- `hooks/useSearchSuggestions.ts`
- `hooks/useVisualSearch.ts`

### Modified Files
- `app/(protected)/search/page.tsx` - Complete redesign
- `components/photos/PhotoGrid.tsx` - Add search integration
- `lib/types/search.ts` - Add search types

### Deleted Files
- `components/search/ComplexFilters.tsx`
- `components/search/FilterDropdowns.tsx`
- `components/search/AdvancedSearch.tsx`

## Search Performance Requirements

### Response Time Targets
- **Text Search**: < 200ms
- **Autocomplete**: < 100ms
- **Visual Search**: < 2s
- **Smart Suggestions**: < 500ms

### Accuracy Targets
- **Text Search Relevance**: > 85%
- **Visual Search Similarity**: > 70%
- **Natural Language Understanding**: > 80%
- **Suggestion Click-through**: > 15%

## Natural Language Query Examples

### Supported Query Types
```typescript
const exampleQueries = [
  // Time-based
  "Photos from last week",
  "Safety inspections from January 2025",
  "Today's uploads",
  
  // Equipment-based
  "All conveyor belt photos",
  "Hydraulic press inspections",
  "Motor maintenance photos",
  
  // Hazard-based
  "Show me all pinch points",
  "High risk safety issues",
  "Sharp edge photos needing review",
  
  // Site-based
  "Photos from Site A",
  "Building 3 recent inspections",
  "Warehouse safety photos",
  
  // Status-based
  "Untagged photos",
  "Photos needing review",
  "High priority safety issues",
  
  // Combined queries
  "Pinch points from Site A last month",
  "Untagged conveyor photos from this week"
];
```

## Visual Search Features

### Image Similarity Matching
- Equipment type recognition
- Hazard pattern matching
- Workplace condition similarity
- Color and composition matching

### Search Refinement
- "More like this" on any photo
- Exclude similar results
- Combine with text search
- Filter by confidence score

## Testing Checklist

### Functionality Testing
- [ ] Natural language queries work correctly
- [ ] Visual search finds similar images
- [ ] Autocomplete provides relevant suggestions
- [ ] Search results ranked appropriately
- [ ] "More like this" generates good results

### Performance Testing
- [ ] Search responds in < 200ms
- [ ] Visual search completes in < 2s
- [ ] Large result sets load smoothly
- [ ] Search analytics tracking works

### Accuracy Testing
- [ ] Text search relevance > 85%
- [ ] Visual search similarity > 70%
- [ ] Natural language parsing accurate
- [ ] Suggestions improve over time

## Success Criteria

- [ ] Search interface simplified to single bar
- [ ] Natural language queries understood
- [ ] Visual search functional and accurate
- [ ] Smart suggestions improve user engagement
- [ ] Search performance meets targets
- [ ] User search satisfaction improved
- [ ] Advanced features accessible but not overwhelming

## Documentation Requirements

### User Guide
- How to use natural language search
- Visual search capabilities
- Smart suggestion system
- Advanced search features

### API Documentation
- Search endpoints and parameters
- Natural language query syntax
- Visual search API usage
- Analytics and tracking

### Handover Document
Create `HANDOVER-AGENT-5.md` including:
- Search architecture overview
- Natural language processing implementation
- Visual search system details
- Smart suggestion algorithms
- Performance optimization techniques
- Analytics and tracking setup
- Future enhancement opportunities
- Testing results and accuracy metrics

## Coordination with Other Agents

- Use Agent 1's smart albums API for suggestions
- Integrate with Agent 3's simplified photos
- Build on Agent 4's mobile optimizations
- Share search components across the app

## Important Considerations

1. **Privacy**: Hash search queries for analytics
2. **Performance**: Implement efficient caching for common queries
3. **Accuracy**: Continuously improve ML models with usage data
4. **Accessibility**: Support voice input and screen readers
5. **Internationalization**: Consider multiple languages in future

## Future Enhancement Ideas

- Voice search with speech recognition
- Saved search alerts and notifications
- Advanced Boolean query builder for power users
- Machine learning model training from user interactions
- Integration with external safety databases

Remember to focus on user experience and make search feel magical, not mechanical!