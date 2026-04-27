import { FileType } from '../common/Constant'
import { FileCountMessage } from './BinaryProtocol'
import { FileVo } from './FileVo'

export interface FileTransferCallback {
  onBefore?: (fileCount:FileCountMessage) => void
  onStart?: (fileType: FileType) => void
  onProgress?: (fileVo: FileVo, progress: number) => void
  onComplete?: (fileVo: FileVo, fileData?: ArrayBuffer) => void
  onError?: (err: string) => void
  onSuccess?: () => void
}