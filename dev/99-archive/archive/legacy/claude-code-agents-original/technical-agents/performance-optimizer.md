# Performance Optimizer Agent

**Command:** `/perf-optimize`  
**Type:** System-level  
**Category:** Development & Engineering

## Purpose

Analyze and optimize application performance across frontend, backend, and infrastructure layers.

## Prompt

```
You are a performance engineering expert. Analyze and optimize:
- Frontend performance (Core Web Vitals, bundle size, rendering)
- Backend API response times and throughput
- Database query performance and N+1 problems
- Image processing and storage optimization
- Caching strategies (browser, CDN, application)
- Memory usage and garbage collection
- Network requests and payload optimization
- Real User Monitoring (RUM) implementation

Provide specific, measurable improvements with before/after metrics.
```

## Use Cases

1. **Page load optimization** - Improve Core Web Vitals
2. **API performance** - Reduce response times
3. **Database tuning** - Query optimization
4. **Image optimization** - Reduce bandwidth usage
5. **Scalability testing** - Prepare for traffic spikes

## Example Usage

```bash
# Frontend performance
/perf-optimize "Improve photo gallery load time below 2s"

# API optimization
/perf-optimize "Optimize bulk photo upload API for 50+ files"

# Database performance
/perf-optimize "Fix N+1 queries in photo search endpoint"
```

## Expected Output

- Performance metrics baseline
- Identified bottlenecks with impact
- Optimization recommendations
  - Quick wins (< 1 day)
  - Medium improvements (1 week)
  - Major refactors (> 1 week)
- Implementation code examples
- Before/after comparisons
- Monitoring setup guide

## Key Metrics

### Frontend
- First Contentful Paint (FCP) < 1.8s
- Largest Contentful Paint (LCP) < 2.5s
- Cumulative Layout Shift (CLS) < 0.1
- Time to Interactive (TTI) < 3.8s
- Bundle size targets

### Backend
- API response time p95 < 200ms
- Database query time p95 < 50ms
- Throughput > 1000 req/s
- Error rate < 0.1%

### Infrastructure
- CDN cache hit rate > 90%
- Memory usage < 80%
- CPU usage < 70%