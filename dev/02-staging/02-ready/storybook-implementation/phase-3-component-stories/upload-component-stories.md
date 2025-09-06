# Phase 3: Upload Component Stories
**Module:** Photo Upload & Processing  
**Components:** 4 core upload handling components  
**Estimated Time:** 1 hour  
**Priority:** High (essential workflow)

## Overview

Upload components handle the critical photo ingestion workflow in Minerva, supporting drag & drop uploads, batch processing, and real-time progress tracking. These components must handle large files, validation, and error recovery while providing excellent user feedback.

## Component Priority Matrix

### Tier 1: Core Upload Components (45 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|--------------|
| FileDropZone | `upload/file-drop-zone.tsx` | Medium | Critical | 20 min |
| UploadProgress | `upload/upload-progress.tsx` | Medium | High | 15 min |
| FilePreview | `upload/file-preview.tsx` | Medium | High | 10 min |

### Tier 2: Organization Assignment (15 minutes)
| Component | File | Complexity | Business Impact | Time Est. |
|-----------|------|------------|-----------------|--------------|
| SiteProjectSelector | `upload/site-project-selector.tsx` | Medium | High | 15 min |

## Detailed Implementation Guide

### Tier 1: Core Upload Components

#### 1. FileDropZone Component (`upload/file-drop-zone.tsx`)

**Story File:** `components/upload/file-drop-zone.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { FileDropZone } from './file-drop-zone';
import { mockUploadData } from '../../../.storybook/mocks';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof FileDropZone> = {
  title: 'Features/Upload/FileDropZone',
  component: FileDropZone,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: `
**FileDropZone** - Primary file upload interface

Drag & drop file upload component supporting multiple file types, validation,
and batch upload capabilities. Central component for photo ingestion workflow.

**Key Features:**
- **Drag & Drop**: Native browser drag & drop with visual feedback
- **File Validation**: Size, type, and format validation with clear error messages
- **Batch Upload**: Handle multiple files simultaneously with progress tracking
- **Image Preview**: Thumbnail previews with file metadata
- **Error Recovery**: Retry failed uploads and skip problematic files
- **Mobile Support**: Touch-friendly file selection on mobile devices

**Supported Formats:**
- **Images**: JPG, PNG, HEIC, WebP (primary focus)
- **Videos**: MP4, MOV (for inspection videos)
- **Documents**: PDF (for safety reports and documentation)

**Upload Constraints:**
- **File Size**: 50MB per file, 500MB total batch
- **File Count**: Up to 100 files per batch
- **Image Resolution**: Minimum 800x600 recommended
- **Processing**: Automatic EXIF extraction and thumbnail generation
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="w-full max-w-2xl p-4">
        <Story />
      </div>
    ),
  ],
  argTypes: {
    acceptedTypes: {
      control: { type: 'check' },
      options: ['image/*', 'video/*', 'application/pdf'],
      description: 'Accepted file MIME types',
    },
    maxFileSize: {
      control: { type: 'range', min: 1, max: 100, step: 1 },
      description: 'Maximum file size in MB',
    },
    maxFiles: {
      control: { type: 'range', min: 1, max: 200, step: 10 },
      description: 'Maximum number of files',
    },
    disabled: {
      control: 'boolean',
      description: 'Disable upload functionality',
    },
    onFilesSelected: { action: 'files-selected' },
    onUploadStart: { action: 'upload-started' },
    onValidationError: { action: 'validation-error' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const EmptyDropZone: Story = {
  args: {
    acceptedTypes: ['image/*'],
    maxFileSize: 50,
    maxFiles: 100,
    disabled: false,
    onFilesSelected: action('files-selected'),
    onUploadStart: action('upload-started'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Empty drop zone ready to accept files. Shows file type and size constraints.',
      },
    },
  },
};

export const DragOverState: Story = {
  args: {
    acceptedTypes: ['image/*'],
    maxFileSize: 50,
    maxFiles: 100,
    isDragOver: true,
    onFilesSelected: action('files-selected'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Active drag over state with visual feedback indicating valid drop target.',
      },
    },
  },
};

export const WithSelectedFiles: Story = {
  args: {
    acceptedTypes: ['image/*'],
    maxFileSize: 50,
    maxFiles: 100,
    selectedFiles: [
      {
        file: mockUploadData.validImageFile,
        preview: 'https://picsum.photos/200/150?random=1',
        status: 'selected',
        size: '2.4 MB',
        dimensions: '4032x3024',
      },
      {
        file: mockUploadData.validImageFile2,
        preview: 'https://picsum.photos/200/150?random=2',
        status: 'selected',
        size: '1.8 MB',
        dimensions: '3264x2448',
      },
      {
        file: mockUploadData.validImageFile3,
        preview: 'https://picsum.photos/200/150?random=3',
        status: 'selected',
        size: '3.1 MB',
        dimensions: '4608x3456',
      },
    ],
    onFilesSelected: action('files-selected'),
    onFileRemove: action('file-removed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Drop zone with selected files showing previews and metadata.',
      },
    },
  },
};

export const ValidationErrors: Story = {
  args: {
    acceptedTypes: ['image/*'],
    maxFileSize: 10,
    maxFiles: 5,
    selectedFiles: [
      {
        file: mockUploadData.validImageFile,
        preview: 'https://picsum.photos/200/150?random=1',
        status: 'valid',
        size: '2.4 MB',
      },
      {
        file: mockUploadData.oversizedFile,
        status: 'error',
        error: 'File size exceeds 10MB limit',
        size: '15.2 MB',
      },
      {
        file: mockUploadData.invalidTypeFile,
        status: 'error',
        error: 'File type not supported. Please upload JPG, PNG, or HEIC files.',
        size: '1.2 MB',
      },
    ],
    onFilesSelected: action('files-selected'),
    onValidationError: action('validation-error'),
  },
  parameters: {
    docs: {
      description: {
        story: 'File validation errors with specific error messages and recovery options.',
      },
    },
  },
};

export const UploadInProgress: Story = {
  args: {
    acceptedTypes: ['image/*'],
    selectedFiles: [
      {
        file: mockUploadData.validImageFile,
        preview: 'https://picsum.photos/200/150?random=1',
        status: 'uploading',
        progress: 45,
        size: '2.4 MB',
      },
      {
        file: mockUploadData.validImageFile2,
        preview: 'https://picsum.photos/200/150?random=2',
        status: 'completed',
        progress: 100,
        size: '1.8 MB',
      },
      {
        file: mockUploadData.validImageFile3,
        preview: 'https://picsum.photos/200/150?random=3',
        status: 'queued',
        progress: 0,
        size: '3.1 MB',
      },
    ],
    isUploading: true,
    disabled: true,
    onUploadStart: action('upload-started'),
    onUploadCancel: action('upload-cancelled'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Upload in progress showing different file states and overall progress.',
      },
    },
  },
};

export const MobileOptimized: Story = {
  args: {
    acceptedTypes: ['image/*'],
    maxFileSize: 50,
    maxFiles: 50,
    mode: 'mobile',
    showCameraOption: true,
    onFilesSelected: action('files-selected'),
    onCameraCapture: action('camera-capture'),
  },
  parameters: {
    viewport: {
      defaultViewport: 'mobile1',
    },
    docs: {
      description: {
        story: 'Mobile-optimized version with camera capture option and touch-friendly interface.',
      },
    },
  },
};

export const DisabledState: Story = {
  args: {
    acceptedTypes: ['image/*'],
    maxFileSize: 50,
    maxFiles: 100,
    disabled: true,
    disabledReason: 'Upload quota exceeded. Please upgrade your plan to upload more photos.',
  },
  parameters: {
    docs: {
      description: {
        story: 'Disabled state with informative message about why uploads are not available.',
      },
    },
  },
};

export const InteractiveBatchUpload: Story = {
  render: () => {
    const [selectedFiles, setSelectedFiles] = React.useState([]);
    const [isUploading, setIsUploading] = React.useState(false);
    const [uploadProgress, setUploadProgress] = React.useState(0);

    const handleFilesSelected = (files) => {
      const fileData = files.map((file, index) => ({
        file,
        preview: URL.createObjectURL(file),
        status: 'selected',
        size: `${(file.size / 1024 / 1024).toFixed(1)} MB`,
        dimensions: `${Math.floor(Math.random() * 2000) + 2000}x${Math.floor(Math.random() * 1500) + 1500}`,
      }));
      setSelectedFiles(fileData);
      action('files-selected')(files);
    };

    const handleUploadStart = () => {
      setIsUploading(true);
      setUploadProgress(0);
      
      // Simulate upload progress
      const interval = setInterval(() => {
        setUploadProgress(prev => {
          if (prev >= 100) {
            clearInterval(interval);
            setIsUploading(false);
            // Update file statuses to completed
            setSelectedFiles(files => files.map(f => ({ ...f, status: 'completed', progress: 100 })));
            return 100;
          }
          
          // Update individual file progress
          setSelectedFiles(files => files.map((f, i) => {
            const individualProgress = Math.max(0, prev - (i * 20));
            return {
              ...f,
              progress: Math.min(100, individualProgress),
              status: individualProgress >= 100 ? 'completed' : individualProgress > 0 ? 'uploading' : 'queued'
            };
          }));
          
          return prev + 5;
        });
      }, 300);
      
      action('upload-started')();
    };

    return (
      <div className="space-y-4">
        <div className="p-4 bg-muted rounded-lg">
          <h3 className="font-semibold mb-2">Interactive Upload Demo</h3>
          <p className="text-sm text-muted-foreground">
            Try selecting files and starting an upload to see the complete workflow in action.
          </p>
        </div>
        
        <FileDropZone
          acceptedTypes={['image/*']}
          maxFileSize={50}
          maxFiles={20}
          selectedFiles={selectedFiles}
          isUploading={isUploading}
          disabled={isUploading}
          onFilesSelected={handleFilesSelected}
          onUploadStart={handleUploadStart}
          onFileRemove={(index) => {
            setSelectedFiles(files => files.filter((_, i) => i !== index));
          }}
        />
      </div>
    );
  },
  parameters: {
    docs: {
      description: {
        story: 'Interactive demo showing the complete file upload workflow with real-time progress.',
      },
    },
  },
};
```

#### 2. UploadProgress Component (`upload/upload-progress.tsx`)

**Story File:** `components/upload/upload-progress.stories.tsx`

```typescript
import type { Meta, StoryObj } from '@storybook/react';
import { UploadProgress } from './upload-progress';
import { mockUploadData } from '../../../.storybook/mocks';
import { action } from '@storybook/addon-actions';

const meta: Meta<typeof UploadProgress> = {
  title: 'Features/Upload/UploadProgress',
  component: UploadProgress,
  parameters: {
    layout: 'centered',
    docs: {
      description: {
        component: `
**UploadProgress** - Real-time upload progress tracking

Comprehensive upload progress component providing detailed feedback on batch upload operations,
individual file progress, error handling, and completion statistics.

**Key Features:**
- **Batch Progress**: Overall progress across all files in upload session
- **Individual Tracking**: Per-file progress with detailed status information
- **Error Handling**: Clear error messages with retry and skip options
- **Performance Metrics**: Upload speed, time remaining, and completion estimates
- **Cancellation**: Ability to cancel uploads with proper cleanup
- **Statistics**: Success/failure counts, data transferred, and timing information

**Progress States:**
- **Queued**: File waiting to be processed
- **Uploading**: Active upload with progress percentage
- **Processing**: Server-side processing (AI analysis, thumbnail generation)
- **Completed**: Successfully uploaded and processed
- **Failed**: Upload failed with specific error message
- **Cancelled**: Upload cancelled by user or system
        `.trim(),
      },
    },
  },
  tags: ['autodocs'],
  decorators: [
    (Story) => (
      <div className="w-full max-w-2xl">
        <Story />
      </div>
    ),
  ],
  argTypes: {
    files: {
      control: false,
      description: 'Array of files with upload status',
    },
    overallProgress: {
      control: { type: 'range', min: 0, max: 100, step: 5 },
      description: 'Overall upload progress percentage',
    },
    isActive: {
      control: 'boolean',
      description: 'Whether upload is currently active',
    },
    onCancel: { action: 'upload-cancelled' },
    onRetry: { action: 'retry-failed' },
    onSkip: { action: 'skip-failed' },
  },
};

export default meta;
type Story = StoryObj<typeof meta>;

export const UploadStarting: Story = {
  args: {
    files: [
      {
        id: 'file-1',
        name: 'safety_inspection_001.jpg',
        size: '2.4 MB',
        status: 'queued',
        progress: 0,
      },
      {
        id: 'file-2',
        name: 'conveyor_maintenance_002.jpg',
        size: '1.8 MB',
        status: 'queued',
        progress: 0,
      },
      {
        id: 'file-3',
        name: 'emergency_stop_check_003.jpg',
        size: '3.1 MB',
        status: 'queued',
        progress: 0,
      },
    ],
    overallProgress: 0,
    isActive: true,
    filesCompleted: 0,
    totalFiles: 3,
    onCancel: action('upload-cancelled'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Upload session starting with all files queued and ready to begin.',
      },
    },
  },
};

export const UploadInProgress: Story = {
  args: {
    files: [
      {
        id: 'file-1',
        name: 'safety_inspection_001.jpg',
        size: '2.4 MB',
        status: 'completed',
        progress: 100,
        uploadTime: '3.2s',
        uploadSpeed: '750 KB/s',
      },
      {
        id: 'file-2',
        name: 'conveyor_maintenance_002.jpg',
        size: '1.8 MB',
        status: 'uploading',
        progress: 67,
        uploadSpeed: '820 KB/s',
        timeRemaining: '1.2s',
      },
      {
        id: 'file-3',
        name: 'emergency_stop_check_003.jpg',
        size: '3.1 MB',
        status: 'queued',
        progress: 0,
      },
    ],
    overallProgress: 56,
    isActive: true,
    filesCompleted: 1,
    totalFiles: 3,
    timeElapsed: '8.4s',
    estimatedTimeRemaining: '6.2s',
    averageSpeed: '785 KB/s',
    onCancel: action('upload-cancelled'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Active upload session with one completed file, one in progress, and one queued.',
      },
    },
  },
};

export const WithFailedUploads: Story = {
  args: {
    files: [
      {
        id: 'file-1',
        name: 'safety_inspection_001.jpg',
        size: '2.4 MB',
        status: 'completed',
        progress: 100,
        uploadTime: '3.2s',
      },
      {
        id: 'file-2',
        name: 'corrupted_file_002.jpg',
        size: '1.8 MB',
        status: 'failed',
        progress: 45,
        error: 'File appears to be corrupted or unreadable',
        canRetry: true,
      },
      {
        id: 'file-3',
        name: 'oversized_photo_003.jpg',
        size: '75.1 MB',
        status: 'failed',
        progress: 0,
        error: 'File size exceeds 50MB limit',
        canRetry: false,
      },
      {
        id: 'file-4',
        name: 'emergency_stop_check_004.jpg',
        size: '3.1 MB',
        status: 'uploading',
        progress: 23,
        uploadSpeed: '650 KB/s',
      },
    ],
    overallProgress: 42,
    isActive: true,
    filesCompleted: 1,
    filesFailed: 2,
    totalFiles: 4,
    onCancel: action('upload-cancelled'),
    onRetry: action('retry-failed'),
    onSkip: action('skip-failed'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Upload session with failed files showing error messages and retry/skip options.',
      },
    },
  },
};

export const UploadCompleted: Story = {
  args: {
    files: [
      {
        id: 'file-1',
        name: 'safety_inspection_001.jpg',
        size: '2.4 MB',
        status: 'completed',
        progress: 100,
        uploadTime: '3.2s',
      },
      {
        id: 'file-2',
        name: 'conveyor_maintenance_002.jpg',
        size: '1.8 MB',
        status: 'completed',
        progress: 100,
        uploadTime: '2.8s',
      },
      {
        id: 'file-3',
        name: 'emergency_stop_check_003.jpg',
        size: '3.1 MB',
        status: 'completed',
        progress: 100,
        uploadTime: '4.1s',
      },
    ],
    overallProgress: 100,
    isActive: false,
    isCompleted: true,
    filesCompleted: 3,
    totalFiles: 3,
    totalTime: '12.4s',
    averageSpeed: '785 KB/s',
    totalDataTransferred: '7.3 MB',
    onViewPhotos: action('view-uploaded-photos'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Completed upload session showing success statistics and next action options.',
      },
    },
  },
};

export const LargeBatchUpload: Story = {
  args: {
    files: Array.from({ length: 25 }, (_, i) => ({
      id: `file-${i + 1}`,
      name: `safety_photo_${String(i + 1).padStart(3, '0')}.jpg`,
      size: `${(1.5 + Math.random() * 3).toFixed(1)} MB`,
      status: i < 12 ? 'completed' : i < 15 ? 'uploading' : i < 18 ? 'queued' : 'completed',
      progress: i < 12 ? 100 : i < 15 ? Math.floor(Math.random() * 80) + 10 : i < 18 ? 0 : 100,
      uploadTime: i < 12 || i >= 18 ? `${(2 + Math.random() * 3).toFixed(1)}s` : undefined,
      uploadSpeed: i >= 12 && i < 15 ? `${Math.floor(Math.random() * 300) + 600} KB/s` : undefined,
    })),
    overallProgress: 74,
    isActive: true,
    filesCompleted: 21,
    totalFiles: 25,
    timeElapsed: '2m 18s',
    estimatedTimeRemaining: '45s',
    averageSpeed: '742 KB/s',
    onCancel: action('upload-cancelled'),
  },
  parameters: {
    docs: {
      description: {
        story: 'Large batch upload with 25 files showing scalable progress display.',
      },
    },
  },
};
```

### Mock Data for Upload Components

**File:** `.storybook/mocks/upload-data.ts`

```typescript
export const mockUploadData = {
  validImageFile: {
    name: 'safety_inspection_001.jpg',
    size: 2517504, // 2.4 MB
    type: 'image/jpeg',
    lastModified: Date.now(),
  },
  
  validImageFile2: {
    name: 'conveyor_maintenance_002.jpg', 
    size: 1887437, // 1.8 MB
    type: 'image/jpeg',
    lastModified: Date.now() - 60000,
  },
  
  validImageFile3: {
    name: 'emergency_stop_check_003.jpg',
    size: 3248576, // 3.1 MB
    type: 'image/jpeg',
    lastModified: Date.now() - 120000,
  },
  
  oversizedFile: {
    name: 'high_res_equipment_photo.jpg',
    size: 83886080, // 80 MB
    type: 'image/jpeg',
    lastModified: Date.now(),
  },
  
  invalidTypeFile: {
    name: 'safety_report.docx',
    size: 1258291, // 1.2 MB
    type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    lastModified: Date.now(),
  },

  uploadSessions: {
    successful: {
      id: 'session-001',
      startTime: '2025-08-15T10:30:00Z',
      endTime: '2025-08-15T10:32:15Z',
      totalFiles: 8,
      filesCompleted: 8,
      filesFailed: 0,
      totalSize: '18.7 MB',
      averageSpeed: '845 KB/s',
    },
    
    withFailures: {
      id: 'session-002',
      startTime: '2025-08-15T14:15:00Z',
      endTime: '2025-08-15T14:18:45Z',
      totalFiles: 12,
      filesCompleted: 9,
      filesFailed: 3,
      totalSize: '24.3 MB',
      averageSpeed: '723 KB/s',
      failureReasons: [
        'File size exceeds limit',
        'Network connection lost',
        'File format not supported',
      ],
    },
  },
};
```

## Quality Checklist

### Upload Component Stories Quality
- [ ] **File Handling**: Drag & drop, selection, and validation work correctly
- [ ] **Progress Tracking**: Real-time progress with accurate timing and speed metrics
- [ ] **Error Scenarios**: Network failures, validation errors, and recovery workflows
- [ ] **Mobile Optimization**: Touch-friendly interfaces and camera integration
- [ ] **Large Batches**: Performance with 50+ files and large file sizes
- [ ] **Accessibility**: Keyboard navigation and screen reader support

### Upload Workflow Validation
- [ ] **File Validation**: Size, type, and format constraints enforced
- [ ] **Progress Accuracy**: Progress indicators reflect actual upload status
- [ ] **Error Recovery**: Failed uploads can be retried or skipped appropriately
- [ ] **Cancellation**: Upload cancellation works cleanly without corruption
- [ ] **Completion Handling**: Successful uploads transition to photo management
- [ ] **Performance**: Large files and batches upload efficiently

### Integration Testing
- [ ] **API Integration**: Realistic upload timing and error simulation
- [ ] **Store Integration**: Upload state management and data persistence
- [ ] **Navigation**: Smooth transition from upload to photo management
- [ ] **Error Handling**: Network failures and server errors handled gracefully

---

**Phase 3 Status**: Upload component stories completed. All core feature components now documented with comprehensive examples and realistic workflows.