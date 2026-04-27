import { common } from '@kit.AbilityKit';
import { UtilLog } from '@hw-agconnect/util-log';
import { ContactMessage, FileCountMessage, FileEndMessage, FileStartMessage } from '../model/BinaryProtocol';
import { FileTransferCallback } from '../model/FileTransferCallback';
import { addContactByPermissions, FileUtil } from '../utils/FileUtil';
import { BinaryMessageType, FileType, LENGTH_WRITE_FILE_CHUNK } from '../common/Constant';
import { BinaryProtocolCodec } from '../utils/BinaryProtocolCodec';
import { FileVo } from '../model/FileVo';
import { BufferUtil } from '../utils/BufferUtil';


export class FileReceiverService {
  private context: common.UIAbilityContext | undefined;
  /** 接收到的文件块映射 */
  private receivedChunks: ArrayBuffer = new ArrayBuffer(0);
  private receivedChunkSize: number = 0;
  private targetPath: string = '';
  private targetOffset: number = 0;
  private downloadDirectoryPath: string = '';
  /** 文件信息映射 */
  private fileStartMessage: FileStartMessage = {} as FileStartMessage;
  private fileTransCallback: FileTransferCallback = {} as FileTransferCallback;

  // 设置进度回调
  setFileTransferCallback(context: common.UIAbilityContext, callback: FileTransferCallback) {
    this.context = context;
    this.fileTransCallback = callback;
    FileUtil.getDownloadDirectoryPath(context).then((value) => {
      this.downloadDirectoryPath = value;
    });
  }

  /**
   * 处理二进制文件消息
   */
  handleBinaryFileMessage(messageType: BinaryMessageType, data: ArrayBuffer) {
    try {
      switch (messageType) {
        case BinaryMessageType.FILE_START:
          this.handleFileStart(data);
          break;
        case BinaryMessageType.FILE_CHUNK:
          this.handleFileChunk(data);
          break;
        case BinaryMessageType.FILE_END:
          this.handleFileEnd(data);
          break;
        case BinaryMessageType.CONTACT:
          this.handleContact(data);
          break;
        case BinaryMessageType.FILE_COUNT:
          this.handleFileCount(data);
        default:
          UtilLog.info(0x0001, 'testTag', '%{public}s', '未知的二进制消息类型');
      }
    } catch (error) {
      console.error('处理二进制文件消息失败:', JSON.stringify(error));
    }
  }

  /**
   * 处理文件的数量消息
   */
  private handleFileCount(data: ArrayBuffer) {
    const message: FileCountMessage = BinaryProtocolCodec.decodeFileCountMessage(data);
    if (this.fileTransCallback.onBefore) {
      this.fileTransCallback.onBefore(message);
    }
  }

  /**
   * 处理联系人消息
   */
  private handleContact(data: ArrayBuffer) {
    const contactMessage: ContactMessage = BinaryProtocolCodec.decodeFileStartMessage(data) as ContactMessage;
    if (this.context) {
      addContactByPermissions(this.context, contactMessage.list);
      if (this.fileTransCallback.onProgress) {
        const fileVo: FileVo = {
          name: '',
          size: 0,
          type: FileType.CONTACT,
          uri: '',
        };
        this.fileTransCallback.onProgress(fileVo, data.byteLength);
      }
    }
  }

  /**
   * 处理文件开始消息
   */
  private handleFileStart(data: ArrayBuffer) {
    const fileStartMessage: FileStartMessage = BinaryProtocolCodec.decodeFileStartMessage(data) as FileStartMessage;
    if (this.fileTransCallback.onStart) {
      this.fileTransCallback.onStart(fileStartMessage.fileType);
    }
    // 初始化接收数组
    this.fileStartMessage = fileStartMessage;
    this.targetPath = this.downloadDirectoryPath + '/' + fileStartMessage.fileName;
  }

  /**
   * 处理文件分片消息
   */
  private handleFileChunk(data: ArrayBuffer) {
    const fileVo: FileVo = {
      name: this.fileStartMessage.fileName,
      size: this.fileStartMessage.fileSize,
      type: this.fileStartMessage.fileType,
      uri: this.targetPath,
    };
    this.receivedChunks = BufferUtil.mergeArrayBuffer(this.receivedChunks, data);
    // 更新接收进度
    if (this.receivedChunks.byteLength >= LENGTH_WRITE_FILE_CHUNK) {
      if (this.targetPath && this.context) {
        let currentReceivedChunkLength = this.receivedChunks.byteLength;
        this.targetOffset += currentReceivedChunkLength;
        this.receivedChunks = new ArrayBuffer(0);
      }
    }
    this.receivedChunkSize += data.byteLength;
    if (this.fileTransCallback.onProgress) {
      this.fileTransCallback.onProgress(fileVo, data.byteLength);
    }
  }

  /**
   * 处理文件结束消息
   */
  private handleFileEnd(data: ArrayBuffer) {
    try {
      const fileEndMessage: FileEndMessage = BinaryProtocolCodec.decodeFileEndMessage(data);
      const fileName: string = fileEndMessage.fileName;
      if (fileEndMessage.fileName !== this.fileStartMessage.fileName) {
        console.log(`文件接收失败，文件名：${fileEndMessage.fileName}, 应收文件块${fileEndMessage.totalChunks}, 实收文件块${this.receivedChunkSize}`);
        return;
      }
      if (this.fileTransCallback.onComplete) {
        this.fileTransCallback.onComplete({
          name: fileName,
          size: this.fileStartMessage.fileSize,
          type: this.fileStartMessage.fileType,
          uri: this.targetPath,
        });
      }
    } finally {
      this.resume();
    }
  }

  private resume() {
    this.receivedChunks = new ArrayBuffer(0);
    this.receivedChunkSize = 0;
    this.fileStartMessage = {} as FileStartMessage;
    this.targetOffset = 0;
    this.targetPath = '';
  }
}

const instance = new FileReceiverService();

export function registerFileRecvTransferCallback(context: common.UIAbilityContext, callback: FileTransferCallback) {
  instance.setFileTransferCallback(context, callback);
}

export default instance;