import { common } from '@kit.AbilityKit';
import { ContactMessage, FileCountMessage, FileEndMessage, FileStartMessage } from '../model/BinaryProtocol';
import { addContactByPermissions } from '../utils/FileUtil';
import { FileType, LENGTH_WRITE_FILE_CHUNK, WorkerMessageType } from '../common/Constant';
import { BinaryProtocolCodec } from '../utils/BinaryProtocolCodec';
import { FileVo } from '../model/FileVo';
import { BufferUtil } from '../utils/BufferUtil';
import { FileSaveVo } from '../model/FileSaveVo';
import { fileSaveService } from './FileSaveService';
import { ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { ReceiveProgressInfo, WorkerMessage } from '../model/WorkerMessage';

export class ReceiverUtil {
  private context: common.UIAbilityContext | undefined;
  /** 接收到的文件块映射 */
  private receivedChunks: ArrayBuffer = new ArrayBuffer(0);
  private receivedChunkSize: number = 0;
  private targetPath: string = '';
  private targetOffset: number = 0;
  private downloadDirectoryPath: string = '';
  /** 文件信息映射 */
  private fileStartMessage: FileStartMessage = {} as FileStartMessage;
  private workerPort: ThreadWorkerGlobalScope = worker.workerPort;

  constructor(workerPort: ThreadWorkerGlobalScope) {
    this.workerPort = workerPort
  }

  setContext(context: common.UIAbilityContext) {
    this.context = context
  }


  /**
   * 处理文件的数量消息
   */
  handleFileCount(data: ArrayBuffer) {
    const message: FileCountMessage = BinaryProtocolCodec.decodeFileCountMessage(data);
    this.workerPort.postMessage({
      type: WorkerMessageType.RECEIVE_FILE_COUNT,
      data: message,
    } as WorkerMessage);
  }

  /**
   * 处理联系人消息
   */
  handleContact(data: ArrayBuffer) {
    const contactMessage: ContactMessage = BinaryProtocolCodec.decodeFileStartMessage(data) as ContactMessage;
    if (this.context) {
      addContactByPermissions(this.context, contactMessage.list);
      const fileVo: FileVo = {
        name: '',
        size: 0,
        type: FileType.CONTACT,
        uri: '',
      };
      this.workerPort.postMessage({
        type: WorkerMessageType.PROGRESS,
        data: { fileVo, byteLength: data.byteLength } as ReceiveProgressInfo,
      } as WorkerMessage);
      this.workerPort.postMessage({
        type: WorkerMessageType.END,
        data: {
          name: '',
          size: this.fileStartMessage.fileSize,
          type: FileType.CONTACT,
          uri: this.targetPath,
        } as FileVo,
      } as WorkerMessage);
    }
  }

  /**
   * 处理文件开始消息
   */
  handleFileStart(data: ArrayBuffer) {
    try {
      const fileStartMessage: FileStartMessage = BinaryProtocolCodec.decodeFileStartMessage(data) as FileStartMessage;
      this.workerPort.postMessage({
        type: WorkerMessageType.START,
        data: fileStartMessage.fileType.toString(),
      } as WorkerMessage);
      // 初始化接收数组
      this.fileStartMessage = fileStartMessage;
      this.targetPath = this.downloadDirectoryPath + '/' + fileStartMessage.fileName;
    } catch (e) {
      console.log('start', JSON.stringify(e))
    }
  }

  /**
   * 处理文件分片消息
   */
  handleFileChunk(data: ArrayBuffer) {
    try {
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
      this.workerPort.postMessage({
        type: WorkerMessageType.PROGRESS,
        data: { fileVo, byteLength: data.byteLength } as ReceiveProgressInfo,
      } as WorkerMessage);
    } catch (e) {
      console.error('progress', JSON.stringify(e))
    }
  }

  /**
   * 处理文件结束消息
   */
  handleFileEnd(data: ArrayBuffer) {
    try {
      const fileEndMessage: FileEndMessage = BinaryProtocolCodec.decodeFileEndMessage(data);
      const fileName: string = fileEndMessage.fileName;
      if (fileEndMessage.fileName !== this.fileStartMessage.fileName) {
        console.log(`文件接收失败，文件名：${fileEndMessage.fileName}, 应收文件块${fileEndMessage.totalChunks}, 实收文件块${this.receivedChunkSize}`);
        return;
      }
      if (this.receivedChunks.byteLength > 0) {
        if (this.targetPath && this.context) {
          fileSaveService.saveFile(this.context, {
            path: this.targetPath,
            offset: this.targetOffset,
            data: this.receivedChunks,
            type: this.fileStartMessage.fileType,
          } as FileSaveVo);
        }
      }
      this.workerPort.postMessage({
        type: WorkerMessageType.END,
        data: {
          name: fileName,
          size: this.fileStartMessage.fileSize,
          type: this.fileStartMessage.fileType,
          uri: this.targetPath,
        } as FileVo,
      } as WorkerMessage);
    } catch (e) {
      console.error('end', JSON.stringify(e))
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