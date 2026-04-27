import { BinaryMessageType, FileType, MainFile } from '../common/Constant';
import { contact } from '@kit.ContactsKit';

//联系人结构
export interface ContactMessage {
  fileType: FileType;
  list: contact.Contact[];
  deviceName?: string;
  deviceImgData?: string;
}

export interface FileCountMessage {
  contact: MainFile,
  image: MainFile,
  video: MainFile,
  ip: string,
}

//文件开始消息结构
export interface FileStartMessage {
  fileName: string;
  fileSize: number;
  fileType: FileType;
  totalChunks?: number;
  chunkSize?: number;
  deviceName?: string;
  deviceImgData?: string;
}

//文件结束消息结构
export interface FileEndMessage {
  fileName: string;
  fileSize: number;
  totalChunks: number;
  checksum?: string;
}

// 文件传输消息头
export interface BinaryProtocolHeader {
  dataLength: number;
  type: BinaryMessageType
}

export interface BinaryProtocolData {
  type: BinaryMessageType,
  data: ArrayBuffer
}

//二进制协议消息联合类型
export type BinaryProtocolMessage = FileCountMessage | ContactMessage | FileStartMessage | FileEndMessage;