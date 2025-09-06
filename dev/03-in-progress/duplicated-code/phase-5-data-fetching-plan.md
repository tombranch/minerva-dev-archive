# Phase 5: Data Fetching Standardization Implementation Plan

**Duration:** 2 weeks  
**Priority:** Medium  
**Agent Assignment:** Data Management Specialist  
**Dependencies:** Phase 1 (Authentication Service), Phase 2 (API Infrastructure)  

## Overview

Consolidate scattered data fetching patterns into a unified, efficient system. This phase addresses duplication in custom hooks, API calls, caching strategies, and state management patterns.

## Current State Analysis

### Files to Consolidate
- `hooks/use-search.ts` (200+ lines) - Search data fetching
- `components/ai/console/shared/hooks.ts` (500+ lines) - AI console data hooks
- `hooks/use-optimized-real-time-dashboard.ts` (400+ lines) - Dashboard data
- `components/ai/console/shared/live-hooks.ts` (400+ lines) - Real-time data
- `providers/query-provider.tsx` (89 lines) - React Query configuration
- Multiple components with inline data fetching

### Duplication Issues
1. Similar data fetching patterns with different implementations
2. Inconsistent error handling across hooks
3. Duplicated loading state management
4. Scattered caching strategies
5. Repeated API call patterns
6. Inconsistent real-time data handling

## Implementation Tasks

### Task 1: Create Unified Data Fetching Framework
**File:** `hooks/data/use-unified-query.ts`
**Estimated Time:** 4 days

```typescript
// Comprehensive data fetching framework
export interface QueryConfig<TData, TParams = void> {
  queryKey: QueryKey | ((params: TParams) => QueryKey)
  queryFn: (params: TParams) => Promise<TData>
  enabled?: boolean | ((params: TParams) => boolean)
  staleTime?: number
  cacheTime?: number
  refetchInterval?: number | false
  refetchOnWindowFocus?: boolean
  refetchOnReconnect?: boolean
  retry?: number | boolean | ((failureCount: number, error: any) => boolean)
  retryDelay?: number | ((attemptIndex: number) => number)
  onSuccess?: (data: TData) => void
  onError?: (error: Error) => void
  select?: (data: TData) => any
  placeholderData?: TData
  keepPreviousData?: boolean
}

export interface QueryResult<TData> {
  data: TData | undefined
  isLoading: boolean
  isError: boolean
  error: Error | null
  isSuccess: boolean
  isFetching: boolean
  isStale: boolean
  refetch: () => Promise<QueryObserverResult<TData>>
  remove: () => void
  dataUpdatedAt: number
  errorUpdatedAt: number
  failureCount: number
  status: 'idle' | 'loading' | 'error' | 'success'
}

export function useUnifiedQuery<TData, TParams = void>(
  params: TParams,
  config: QueryConfig<TData, TParams>
): QueryResult<TData> {
  // Generate query key
  const queryKey = useMemo(() => {
    return typeof config.queryKey === 'function' 
      ? config.queryKey(params)
      : config.queryKey
  }, [config.queryKey, params])

  // Check if query should be enabled
  const enabled = useMemo(() => {
    if (typeof config.enabled === 'function') {
      return config.enabled(params)
    }
    return config.enabled !== false
  }, [config.enabled, params])

  // Create query function
  const queryFn = useCallback(() => {
    return config.queryFn(params)
  }, [config.queryFn, params])

  // Use React Query with unified configuration
  const query = useQuery({
    queryKey,
    queryFn,
    enabled,
    staleTime: config.staleTime ?? 5 * 60 * 1000, // 5 minutes default
    cacheTime: config.cacheTime ?? 10 * 60 * 1000, // 10 minutes default
    refetchInterval: config.refetchInterval,
    refetchOnWindowFocus: config.refetchOnWindowFocus ?? false,
    refetchOnReconnect: config.refetchOnReconnect ?? true,
    retry: config.retry ?? 3,
    retryDelay: config.retryDelay ?? ((attemptIndex) => Math.min(1000 * 2 ** attemptIndex, 30000)),
    onSuccess: config.onSuccess,
    onError: config.onError,
    select: config.select,
    placeholderData: config.placeholderData,
    keepPreviousData: config.keepPreviousData ?? false
  })

  return {
    data: query.data,
    isLoading: query.isLoading,
    isError: query.isError,
    error: query.error,
    isSuccess: query.isSuccess,
    isFetching: query.isFetching,
    isStale: query.isStale,
    refetch: query.refetch,
    remove: query.remove,
    dataUpdatedAt: query.dataUpdatedAt,
    errorUpdatedAt: query.errorUpdatedAt,
    failureCount: query.failureCount,
    status: query.status
  }
}

// Mutation hook for data modifications
export interface MutationConfig<TData, TVariables> {
  mutationFn: (variables: TVariables) => Promise<TData>
  onSuccess?: (data: TData, variables: TVariables) => void
  onError?: (error: Error, variables: TVariables) => void
  onSettled?: (data: TData | undefined, error: Error | null, variables: TVariables) => void
  retry?: number | boolean
  retryDelay?: number | ((attemptIndex: number) => number)
  invalidateQueries?: QueryKey[]
  updateQueries?: Array<{
    queryKey: QueryKey
    updater: (oldData: any, newData: TData) => any
  }>
}

export function useUnifiedMutation<TData, TVariables>(
  config: MutationConfig<TData, TVariables>
) {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: config.mutationFn,
    onSuccess: (data, variables) => {
      // Invalidate specified queries
      if (config.invalidateQueries) {
        config.invalidateQueries.forEach(queryKey => {
          queryClient.invalidateQueries(queryKey)
        })
      }

      // Update specified queries
      if (config.updateQueries) {
        config.updateQueries.forEach(({ queryKey, updater }) => {
          queryClient.setQueryData(queryKey, (oldData: any) => updater(oldData, data))
        })
      }

      config.onSuccess?.(data, variables)
    },
    onError: config.onError,
    onSettled: config.onSettled,
    retry: config.retry ?? false,
    retryDelay: config.retryDelay
  })
}
```

**Implementation Steps:**
1. Create unified query hook with comprehensive configuration
2. Implement mutation hook with cache management
3. Add error handling and retry logic
4. Implement query key generation utilities
5. Add TypeScript support for all configurations
6. Write comprehensive unit tests

### Task 2: Create Specialized Data Hooks
**File:** `hooks/data/specialized-hooks.ts`
**Estimated Time:** 3 days

```typescript
// Specialized hooks for common data patterns

// Paginated data hook
export interface PaginatedParams {
  page?: number
  limit?: number
  search?: string
  filters?: Record<string, any>
  sortBy?: string
  sortOrder?: 'asc' | 'desc'
}

export interface PaginatedResult<T> {
  data: T[]
  total: number
  page: number
  limit: number
  hasMore: boolean
  totalPages: number
}

export function usePaginatedQuery<T>(
  endpoint: string,
  params: PaginatedParams = {},
  options: Partial<QueryConfig<PaginatedResult<T>, PaginatedParams>> = {}
) {
  return useUnifiedQuery(params, {
    queryKey: [endpoint, 'paginated', params],
    queryFn: async (params) => {
      const searchParams = new URLSearchParams()
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, String(value))
        }
      })

      const response = await fetch(`${endpoint}?${searchParams}`)
      if (!response.ok) throw new Error('Failed to fetch data')
      
      const result = await response.json()
      if (!result.success) throw new Error(result.error?.message || 'Request failed')
      
      return result.data
    },
    staleTime: 2 * 60 * 1000, // 2 minutes for paginated data
    ...options
  })
}

// Real-time data hook
export function useRealTimeQuery<T>(
  endpoint: string,
  params: any = {},
  options: {
    interval?: number
    enabled?: boolean
    onUpdate?: (data: T) => void
  } = {}
) {
  const { interval = 30000, enabled = true, onUpdate } = options

  return useUnifiedQuery(params, {
    queryKey: [endpoint, 'realtime', params],
    queryFn: async () => {
      const response = await fetch(endpoint)
      if (!response.ok) throw new Error('Failed to fetch real-time data')
      
      const result = await response.json()
      if (!result.success) throw new Error(result.error?.message || 'Request failed')
      
      return result.data
    },
    enabled,
    refetchInterval: enabled ? interval : false,
    refetchOnWindowFocus: true,
    staleTime: 0, // Always consider real-time data stale
    onSuccess: onUpdate
  })
}

// Search hook with debouncing
export function useSearchQuery<T>(
  endpoint: string,
  searchTerm: string,
  options: {
    debounceMs?: number
    minLength?: number
    filters?: Record<string, any>
  } = {}
) {
  const { debounceMs = 300, minLength = 2, filters = {} } = options
  const [debouncedTerm, setDebouncedTerm] = useState(searchTerm)

  // Debounce search term
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedTerm(searchTerm), debounceMs)
    return () => clearTimeout(timer)
  }, [searchTerm, debounceMs])

  return useUnifiedQuery({ search: debouncedTerm, ...filters }, {
    queryKey: [endpoint, 'search', debouncedTerm, filters],
    queryFn: async (params) => {
      const searchParams = new URLSearchParams()
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, String(value))
        }
      })

      const response = await fetch(`${endpoint}?${searchParams}`)
      if (!response.ok) throw new Error('Search failed')
      
      const result = await response.json()
      if (!result.success) throw new Error(result.error?.message || 'Search failed')
      
      return result.data
    },
    enabled: debouncedTerm.length >= minLength,
    staleTime: 5 * 60 * 1000, // 5 minutes for search results
    keepPreviousData: true
  })
}

// Infinite query hook for large datasets
export function useInfiniteQuery<T>(
  endpoint: string,
  params: any = {},
  options: {
    pageSize?: number
    getNextPageParam?: (lastPage: any, pages: any[]) => any
  } = {}
) {
  const { pageSize = 20, getNextPageParam } = options

  return useInfiniteQuery({
    queryKey: [endpoint, 'infinite', params],
    queryFn: async ({ pageParam = 1 }) => {
      const searchParams = new URLSearchParams({
        ...params,
        page: String(pageParam),
        limit: String(pageSize)
      })

      const response = await fetch(`${endpoint}?${searchParams}`)
      if (!response.ok) throw new Error('Failed to fetch data')
      
      const result = await response.json()
      if (!result.success) throw new Error(result.error?.message || 'Request failed')
      
      return result.data
    },
    getNextPageParam: getNextPageParam || ((lastPage) => {
      return lastPage.hasMore ? lastPage.page + 1 : undefined
    }),
    staleTime: 5 * 60 * 1000
  })
}

// Optimistic update hook
export function useOptimisticMutation<TData, TVariables>(
  config: MutationConfig<TData, TVariables> & {
    optimisticUpdate?: (variables: TVariables) => any
    rollbackUpdate?: (error: Error, variables: TVariables) => any
  }
) {
  const queryClient = useQueryClient()

  return useUnifiedMutation({
    ...config,
    onMutate: async (variables) => {
      // Cancel outgoing refetches
      if (config.invalidateQueries) {
        await Promise.all(
          config.invalidateQueries.map(queryKey => 
            queryClient.cancelQueries(queryKey)
          )
        )
      }

      // Snapshot previous values
      const previousData = config.invalidateQueries?.reduce((acc, queryKey) => {
        acc[queryKey.toString()] = queryClient.getQueryData(queryKey)
        return acc
      }, {} as Record<string, any>)

      // Optimistically update
      if (config.optimisticUpdate && config.updateQueries) {
        config.updateQueries.forEach(({ queryKey, updater }) => {
          queryClient.setQueryData(queryKey, (oldData: any) => 
            updater(oldData, config.optimisticUpdate!(variables))
          )
        })
      }

      return { previousData }
    },
    onError: (error, variables, context) => {
      // Rollback optimistic updates
      if (context?.previousData && config.invalidateQueries) {
        config.invalidateQueries.forEach(queryKey => {
          const previousValue = context.previousData[queryKey.toString()]
          if (previousValue !== undefined) {
            queryClient.setQueryData(queryKey, previousValue)
          }
        })
      }

      config.rollbackUpdate?.(error, variables)
      config.onError?.(error, variables)
    }
  })
}
```

**Implementation Steps:**
1. Create paginated query hook
2. Implement real-time data hook
3. Create search hook with debouncing
4. Implement infinite query hook
5. Create optimistic update hook
6. Test all specialized hooks

### Task 3: Create Data Service Layer
**File:** `lib/data/data-services.ts`
**Estimated Time:** 2 days

```typescript
// Centralized data service layer
export class DataService {
  private baseURL: string
  private defaultHeaders: Record<string, string>

  constructor(baseURL: string = '/api', defaultHeaders: Record<string, string> = {}) {
    this.baseURL = baseURL
    this.defaultHeaders = {
      'Content-Type': 'application/json',
      ...defaultHeaders
    }
  }

  // Generic request method
  async request<T>(
    endpoint: string,
    options: RequestInit & {
      params?: Record<string, any>
      timeout?: number
    } = {}
  ): Promise<T> {
    const { params, timeout = 30000, ...fetchOptions } = options
    
    let url = `${this.baseURL}${endpoint}`
    
    // Add query parameters
    if (params) {
      const searchParams = new URLSearchParams()
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined && value !== null) {
          searchParams.append(key, String(value))
        }
      })
      if (searchParams.toString()) {
        url += `?${searchParams}`
      }
    }

    // Create abort controller for timeout
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), timeout)

    try {
      const response = await fetch(url, {
        ...fetchOptions,
        headers: {
          ...this.defaultHeaders,
          ...fetchOptions.headers
        },
        signal: controller.signal
      })

      clearTimeout(timeoutId)

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`)
      }

      const result = await response.json()
      
      if (!result.success) {
        throw new Error(result.error?.message || 'Request failed')
      }

      return result.data
    } catch (error) {
      clearTimeout(timeoutId)
      
      if (error.name === 'AbortError') {
        throw new Error('Request timeout')
      }
      
      throw error
    }
  }

  // Convenience methods
  async get<T>(endpoint: string, params?: Record<string, any>): Promise<T> {
    return this.request<T>(endpoint, { method: 'GET', params })
  }

  async post<T>(endpoint: string, data?: any, params?: Record<string, any>): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'POST',
      body: data ? JSON.stringify(data) : undefined,
      params
    })
  }

  async put<T>(endpoint: string, data?: any, params?: Record<string, any>): Promise<T> {
    return this.request<T>(endpoint, {
      method: 'PUT',
      body: data ? JSON.stringify(data) : undefined,
      params
    })
  }

  async delete<T>(endpoint: string, params?: Record<string, any>): Promise<T> {
    return this.request<T>(endpoint, { method: 'DELETE', params })
  }

  // File upload method
  async upload<T>(endpoint: string, file: File, additionalData?: Record<string, any>): Promise<T> {
    const formData = new FormData()
    formData.append('file', file)
    
    if (additionalData) {
      Object.entries(additionalData).forEach(([key, value]) => {
        formData.append(key, String(value))
      })
    }

    return this.request<T>(endpoint, {
      method: 'POST',
      body: formData,
      headers: {} // Let browser set Content-Type for FormData
    })
  }
}

// Create service instances
export const apiService = new DataService('/api')
export const platformService = new DataService('/api/platform')
export const adminService = new DataService('/api/admin')

// Service-specific classes
export class PhotoService extends DataService {
  constructor() {
    super('/api/photos')
  }

  async listPhotos(params: PaginatedParams) {
    return this.get<PaginatedResult<Photo>>('/', params)
  }

  async getPhoto(id: string) {
    return this.get<Photo>(`/${id}`)
  }

  async uploadPhoto(file: File, metadata: PhotoMetadata) {
    return this.upload<Photo>('/upload', file, metadata)
  }

  async updatePhoto(id: string, updates: Partial<Photo>) {
    return this.put<Photo>(`/${id}`, updates)
  }

  async deletePhoto(id: string) {
    return this.delete<{ deleted: boolean }>(`/${id}`)
  }
}

export class UserService extends DataService {
  constructor() {
    super('/api/users')
  }

  async listUsers(params: PaginatedParams) {
    return this.get<PaginatedResult<User>>('/', params)
  }

  async getUser(id: string) {
    return this.get<User>(`/${id}`)
  }

  async createUser(userData: UserCreateData) {
    return this.post<User>('/', userData)
  }

  async updateUser(id: string, updates: Partial<User>) {
    return this.put<User>(`/${id}`, updates)
  }

  async deleteUser(id: string) {
    return this.delete<{ deleted: boolean }>(`/${id}`)
  }
}

// Export service instances
export const photoService = new PhotoService()
export const userService = new UserService()
```

**Implementation Steps:**
1. Create base DataService class
2. Implement request methods with error handling
3. Add timeout and abort controller support
4. Create service-specific classes
5. Add file upload support
6. Test all service methods

### Task 4: Migrate Existing Data Hooks
**Files:** Various hook files
**Estimated Time:** 3 days

**Migration Priority:**
1. **High Priority:** Search hooks, dashboard hooks
2. **Medium Priority:** AI console hooks, photo hooks
3. **Low Priority:** Specialized feature hooks

**Migration Pattern:**
```typescript
// Before: Custom hook with manual state management
export function usePhotos(params: PhotoParams) {
  const [photos, setPhotos] = useState<Photo[]>([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchPhotos = async () => {
      setLoading(true)
      try {
        const response = await fetch(`/api/photos?${new URLSearchParams(params)}`)
        const data = await response.json()
        setPhotos(data.data)
      } catch (err) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    fetchPhotos()
  }, [params])

  return { photos, loading, error }
}

// After: Using unified query system
export function usePhotos(params: PhotoParams) {
  return usePaginatedQuery<Photo>('/api/photos', params, {
    staleTime: 5 * 60 * 1000,
    onError: (error) => {
      console.error('Failed to fetch photos:', error)
    }
  })
}
```

**Implementation Steps:**
1. Identify all custom data fetching hooks
2. Migrate search and dashboard hooks first
3. Update AI console hooks to use unified system
4. Migrate photo and user management hooks
5. Update all consuming components
6. Remove old hook implementations

## Testing Requirements

### Unit Tests
- Unified query hook functionality
- Specialized hook behavior
- Data service methods
- Error handling scenarios

### Integration Tests
- Complete data fetching flows
- Cache invalidation behavior
- Real-time data updates
- Optimistic updates

### Performance Tests
- Query performance benchmarks
- Cache efficiency
- Memory usage optimization
- Network request optimization

## Success Criteria

### Code Quality
- [ ] All data fetching uses unified system
- [ ] No duplicated API call patterns
- [ ] Consistent error handling across hooks
- [ ] Optimized caching strategies

### Performance
- [ ] Reduced network requests through better caching
- [ ] Improved loading states and user experience
- [ ] Optimized memory usage
- [ ] Better error recovery

### Developer Experience
- [ ] Easy to create new data hooks
- [ ] Consistent API patterns
- [ ] Good TypeScript support
- [ ] Clear error messages

## Deliverables

1. **Unified Query System** - Complete data fetching framework
2. **Specialized Hooks** - Paginated, real-time, search, infinite hooks
3. **Data Service Layer** - Centralized API communication
4. **Migrated Hooks** - All existing hooks using new system
5. **Performance Optimizations** - Caching and request optimization
6. **Comprehensive Tests** - Full test coverage
7. **Documentation** - Usage guides and best practices
8. **Migration Guide** - How to convert existing hooks

---

**Phase Owner:** Data Management Specialist Agent  
**Review Required:** Senior Developer + Performance Review  
**Next Phase:** Phase 6 - Final Cleanup & Documentation
