# Google Logo Search Implementation Plan

**Status**: Someday/Maybe  
**Priority**: Medium  
**Estimated Effort**: 3-4 days  
**Dependencies**: Google Custom Search API setup  

## Overview

Implement automatic logo discovery for sites using Google image search, allowing users to find and select company logos automatically instead of manual upload.

## Technical Architecture

### API Selection: Google Custom Search API
- **Rationale**: Official Google service, reliable results, reasonable pricing
- **Cost**: Free tier (100 searches/day), then $5 per 1000 queries
- **Quality**: High-quality results with relevance scoring
- **Rate Limits**: 10 queries per second

### Alternative Options Considered
1. **SerpApi**: $50/month, easier setup but higher cost
2. **Web Scraping**: Free but unreliable and legally risky
3. **Bing Image Search API**: Lower cost but reduced quality

## Implementation Plan

### Phase 1: Backend Infrastructure (Day 1)

#### 1.1 Environment Setup
```bash
# Add to .env.local
GOOGLE_CUSTOM_SEARCH_API_KEY=your_api_key
GOOGLE_CUSTOM_SEARCH_ENGINE_ID=your_cx_id
```

#### 1.2 API Endpoint Creation
**File**: `/app/api/ai/find-logo/route.ts`
```typescript
export async function POST(request: NextRequest) {
  return withAuth(async (request, user, organizationId) => {
    const { siteName, customer, website } = await request.json();
    
    // Build optimized search query
    const searchTerms = [
      `"${siteName}" logo`,
      customer ? `"${customer}" logo` : null,
      website ? `site:${website} logo` : null
    ].filter(Boolean);
    
    const results = await searchGoogleImages(searchTerms);
    return createSuccessResponse({ logos: results });
  });
}
```

#### 1.3 Search Service Implementation
**File**: `/lib/services/logo-search-service.ts`
```typescript
interface LogoSearchResult {
  url: string;
  thumbnail: string;
  title: string;
  source: string;
  size: { width: number; height: number };
  confidence: number;
}

export async function searchGoogleImages(query: string): Promise<LogoSearchResult[]> {
  const params = new URLSearchParams({
    key: process.env.GOOGLE_CUSTOM_SEARCH_API_KEY!,
    cx: process.env.GOOGLE_CUSTOM_SEARCH_ENGINE_ID!,
    q: query,
    searchType: 'image',
    imgSize: 'medium',
    imgType: 'clipart|face|lineart|news|photo',
    safe: 'active',
    num: '10'
  });
  
  const response = await fetch(`https://www.googleapis.com/customsearch/v1?${params}`);
  const data = await response.json();
  
  return data.items?.map(formatSearchResult) || [];
}
```

### Phase 2: Frontend Integration (Day 2)

#### 2.1 Logo Search Component
**File**: `/components/ui/logo-search-modal.tsx`
```typescript
interface LogoSearchModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  siteName: string;
  customer?: string;
  onLogoSelect: (logoUrl: string) => void;
}

export function LogoSearchModal({ ... }: LogoSearchModalProps) {
  const [results, setResults] = useState<LogoSearchResult[]>([]);
  const [isSearching, setIsSearching] = useState(false);
  
  const handleSearch = async () => {
    setIsSearching(true);
    const response = await fetch('/api/ai/find-logo', {
      method: 'POST',
      body: JSON.stringify({ siteName, customer })
    });
    const data = await response.json();
    setResults(data.logos);
    setIsSearching(false);
  };
  
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-4xl">
        <DialogHeader>
          <DialogTitle>Find Logo for {siteName}</DialogTitle>
        </DialogHeader>
        <div className="grid grid-cols-3 md:grid-cols-4 gap-4">
          {results.map((logo) => (
            <LogoOption 
              key={logo.url}
              logo={logo}
              onSelect={() => onLogoSelect(logo.url)}
            />
          ))}
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

#### 2.2 Integration with Site Manager
**Updates to**: `/components/organization/site-manager.tsx`
```typescript
// Add to logo upload section
<div className="flex gap-2">
  <Button
    type="button"
    variant="outline"
    onClick={() => fileInputRef.current?.click()}
  >
    Upload Logo
  </Button>
  <Button
    type="button"
    variant="outline"
    onClick={() => setShowLogoSearch(true)}
    disabled={!formData.name.trim()}
  >
    <Search className="h-4 w-4 mr-1" />
    Find Logo
  </Button>
</div>

<LogoSearchModal
  open={showLogoSearch}
  onOpenChange={setShowLogoSearch}
  siteName={formData.name}
  customer={formData.customer}
  onLogoSelect={handleLogoSelect}
/>
```

### Phase 3: Enhancement Features (Day 3)

#### 3.1 Logo Quality Assessment
```typescript
interface LogoQualityScore {
  resolution: number; // 0-100
  transparency: number; // 0-100 (PNG with alpha)
  aspectRatio: number; // closeness to 1:1 square
  fileSize: number; // reasonable size check
  overall: number; // weighted average
}

function assessLogoQuality(image: LogoSearchResult): LogoQualityScore {
  // Implementation for logo quality scoring
}
```

#### 3.2 Smart Search Query Optimization
```typescript
function buildSearchQueries(siteName: string, customer?: string, website?: string): string[] {
  const queries = [
    `"${siteName}" official logo transparent`,
    `"${siteName}" brand logo PNG`,
    customer ? `"${customer}" "${siteName}" logo` : null,
    website ? `site:${new URL(website).hostname} logo` : null,
    `"${siteName}" company logo vector`
  ].filter(Boolean);
  
  return queries;
}
```

#### 3.3 Logo Processing Pipeline
```typescript
async function processFoundLogo(logoUrl: string): Promise<string> {
  // 1. Download and validate image
  // 2. Resize to standard dimensions (256x256)
  // 3. Remove background if needed
  // 4. Optimize for web delivery
  // 5. Upload to Supabase storage
  // 6. Return optimized URL
}
```

### Phase 4: Advanced Features (Day 4)

#### 4.1 Logo Caching System
```typescript
// Cache frequently searched logos to reduce API calls
interface LogoCache {
  query: string;
  results: LogoSearchResult[];
  timestamp: number;
  expiryHours: number;
}
```

#### 4.2 Fallback Strategies
```typescript
const searchStrategies = [
  'exact company name + logo',
  'parent company + logo',
  'industry standard + logo template',
  'favicon extraction from website',
  'social media profile images'
];
```

#### 4.3 User Feedback Loop
```typescript
interface LogoFeedback {
  logoUrl: string;
  siteId: string;
  rating: 1 | 2 | 3 | 4 | 5;
  feedback: 'perfect' | 'good' | 'poor' | 'wrong_company';
}
```

## Database Schema Changes

### New Tables Required
```sql
-- Logo search cache
CREATE TABLE logo_search_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  search_query TEXT NOT NULL,
  results JSONB NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- Logo feedback for ML improvement
CREATE TABLE logo_feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_id UUID REFERENCES sites(id) ON DELETE CASCADE,
  logo_url TEXT NOT NULL,
  search_query TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  feedback_type TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_logo_cache_query ON logo_search_cache(search_query);
CREATE INDEX idx_logo_cache_expires ON logo_search_cache(expires_at);
```

## Cost Analysis

### Google Custom Search API Pricing
- **Free Tier**: 100 searches/day
- **Paid Tier**: $5 per 1000 additional searches
- **Expected Usage**: ~50-200 searches/day for typical organization
- **Monthly Cost Estimate**: $0-15 depending on usage

### Development Costs
- **Backend Development**: 1.5 days
- **Frontend Integration**: 1.5 days  
- **Testing & Polish**: 1 day
- **Total**: 4 days development time

## Risk Assessment

### Technical Risks
- **API Rate Limits**: Mitigated by caching and intelligent querying
- **Search Quality**: Addressed through multiple search strategies
- **Image Copyright**: Handled through proper attribution and fair use

### Business Risks
- **API Costs**: Controlled through usage monitoring and caching
- **User Experience**: Fallback to manual upload always available
- **Legal Compliance**: Terms of service compliance for image usage

## Success Metrics

### Technical Metrics
- Logo search success rate > 80%
- Average search time < 3 seconds
- User satisfaction rating > 4/5
- API cost per successful logo < $0.10

### User Experience Metrics
- Reduction in manual logo uploads by 60%
- Decrease in "no logo" sites by 70%
- User engagement with logo search feature > 40%

## Future Enhancements

### Phase 2 Possibilities
1. **AI Logo Generation**: Create logos when none found
2. **Brand Color Extraction**: Extract brand colors from found logos
3. **Logo Variation Detection**: Find different versions (light/dark, horizontal/vertical)
4. **Social Media Integration**: Search LinkedIn, Facebook company pages
5. **Vector Logo Search**: Prioritize SVG and vector formats
6. **Logo History Tracking**: Track logo changes over time

## Implementation Notes

### Environment Setup Requirements
```bash
# Google Custom Search Engine setup
1. Create Custom Search Engine at https://cse.google.com/
2. Configure to search "Images on the web"
3. Add refinement labels for logo-specific searches
4. Enable SafeSearch and restrict explicit content
```

### Testing Strategy
```typescript
// Unit tests for logo search service
describe('LogoSearchService', () => {
  test('should find logo for well-known companies', async () => {
    const results = await searchGoogleImages('Apple Inc logo');
    expect(results.length).toBeGreaterThan(0);
    expect(results[0].confidence).toBeGreaterThan(0.8);
  });
});
```

### Monitoring & Analytics
- Track search success rates by company type
- Monitor API usage and costs
- Collect user feedback on logo relevance
- A/B test different search query strategies

## Dependencies

### External APIs
- Google Custom Search API (required)
- Google Cloud Vision API (optional, for logo validation)

### Internal Systems
- Existing logo upload infrastructure
- Supabase storage system
- Site management forms

### Libraries to Add
```json
{
  "dependencies": {
    "sharp": "^0.32.0",
    "canvas": "^2.11.0"
  }
}
```

## Conclusion

This implementation would significantly enhance the user experience by automating logo discovery, reducing manual work, and improving site visual consistency. The phased approach allows for incremental delivery and risk mitigation while building toward a comprehensive logo management system.

The feature aligns well with the existing AI-powered capabilities of the application and leverages proven Google search technology for reliable results.