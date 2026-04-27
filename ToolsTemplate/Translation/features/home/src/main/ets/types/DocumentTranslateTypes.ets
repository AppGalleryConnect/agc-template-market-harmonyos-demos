/**
 * 上传状态枚举
 */
export enum UploadStatus {
  UPLOADING = 'uploading',
  PAUSED = 'paused',
  COMPLETED = 'completed',
  FAILED = 'failed'
}

/**
 * 上传文件信息类
 */
@ObservedV2
export class UploadedFileInfo {
  name: string = '';
  size: string = '';
  uri: string = '';
  sizeInBytes: number = 0; // 文件大小（字节）
  @Trace uploadedBytes: number = 0; // 已上传字节数
  @Trace progress: number = 0; // 上传进度 0-100
  @Trace status: UploadStatus = UploadStatus.UPLOADING; // 上传状态
  @Trace uploadSpeed: string = '0KB/s'; // 上传速度
}
