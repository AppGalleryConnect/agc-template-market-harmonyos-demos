const MEDIUM_CHUNK_SIZE = 512 * 1024; // 512KB
const LARGE_CHUNK_SIZE = 1024 * 1024; // 1MB
const SMALL_CHUNK_SIZE = 256 * 1024; // 256KB
const X_LARGE_CHUNK_SIZE = 2 * 1024 * 1024; // 2MB

// 分片大小配置常量
const SMALL_FILE_THRESHOLD = 10 * 1024 * 1024; // 10MB
const LARGE_FILE_THRESHOLD = 100 * 1024 * 1024; // 100MB
const X_LARGE_FILE_THRESHOLD = 500 * 1024 * 1024; // 500MB

export class TransferUtil {
  static calculateOptimalChunkSize(fileSize: number): number {
    if (fileSize < SMALL_FILE_THRESHOLD) {
      return SMALL_CHUNK_SIZE;
    } else if (fileSize < LARGE_FILE_THRESHOLD) {
      return MEDIUM_CHUNK_SIZE;
    } else if (fileSize < X_LARGE_FILE_THRESHOLD) { // 500MB
      return LARGE_CHUNK_SIZE;
    } else {
      return X_LARGE_CHUNK_SIZE;
    }
  }
}