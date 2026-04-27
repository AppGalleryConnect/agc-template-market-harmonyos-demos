import { FileType, MainFile, WorkerMessageType } from '../common/Constant';
import { FileVo } from './FileVo';

export interface ProgressInfo {
  type: FileType,
  progress: number,
}

export interface ReceiveProgressInfo {
  fileVo: FileVo,
  byteLength: number,
}

export interface CloneFile {
  image: MainFile,
  video: MainFile
}

export interface WorkerMessage {
  type: WorkerMessageType,
  data: object | string,
  context?: Context,
}