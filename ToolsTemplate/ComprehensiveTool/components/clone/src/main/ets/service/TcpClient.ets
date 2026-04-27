import { MessageEvents, ThreadWorkerPriority, worker } from '@kit.ArkTS';
import { WorkerMessageType, BinaryMessageType, LENGTH_TRANSFER_HEADER, FileType } from '../common/Constant';
import { ContactMessage, FileCountMessage } from '../model/BinaryProtocol';
import { ConnectionVo } from '../model/ConnectionVo';
import { FileVo } from '../model/FileVo';
import { TcpCallback } from '../model/TcpCallback';
import { ProgressInfo, WorkerMessage } from '../model/WorkerMessage';
import { BufferUtil } from '../utils/BufferUtil';
import { checkStringContent } from '../utils/FileUtil';

export class TcpClient {
  private static tcpWorker = new worker.ThreadWorker('../workers/TCPSocketWorker.ets', {
    priority: ThreadWorkerPriority.IDLE,
  });
  private static tcpCallback: TcpCallback = {}
  public static isConnected: boolean = true
  public static onStart: (type: FileType) => void = () => {
  }
  public static onProgress: (data: ProgressInfo) => void = () => {
  }
  public static onEnd: () => void = () => {
  }

  static init(connectionVo: ConnectionVo, tcpCallback: TcpCallback) {
    TcpClient.tcpCallback = tcpCallback
    TcpClient.tcpWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerMessage;
      TcpClient.isConnected = checkStringContent(JSON.stringify(data))
      switch (data.type) {
        case WorkerMessageType.CONNECT:
          TcpClient.handleConnectionCallback(data.data as string)
          break;
        case WorkerMessageType.SEND:
          TcpClient.handleSendCallback(data.data as string);
          break;
        case WorkerMessageType.START:
          TcpClient.onStart(Number(data.data))
          break;
        case WorkerMessageType.PROGRESS:
          TcpClient.onProgress(data.data as ProgressInfo)
          break;
        case WorkerMessageType.END:
          TcpClient.onEnd()
          break;
        default:
          break;
      }
    }
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.CONNECT,
      data: connectionVo,
    } as WorkerMessage)
  }

  static handleSendCallback(data: string) {
    console.log('TcpClient', JSON.stringify(data))
  }

  static handleConnectionCallback(data: string) {
    if (data === 'success') {
      if (TcpClient.tcpCallback.onConnected) {
        TcpClient.tcpCallback.onConnected();
      }
    } else {
      if (TcpClient.tcpCallback.onFailed) {
        TcpClient.tcpCallback.onFailed(data);
      }
    }
  }

  static sendFileCount(fileCount: FileCountMessage) {
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.SEND_FILE_COUNT,
      data: fileCount,
    } as WorkerMessage)
  }

  static sendContactData(contactMessage: ContactMessage): void {
    try {
      TcpClient.tcpWorker.postMessage({
        type: WorkerMessageType.CONTACT,
        data: JSON.stringify(contactMessage),
      } as WorkerMessage)
    } catch (e) {
      console.error('sendContactData', JSON.stringify(e))
    }
  }

  static sendFileData(fileVo: FileVo): void {
    try {
      TcpClient.tcpWorker.postMessage({
        type: WorkerMessageType.SEND,
        data: fileVo,
      } as WorkerMessage)
    } catch (e) {
      console.error('sendFileData', JSON.stringify(e))
    }
  }

  static sendBinaryData(data: ArrayBuffer, dataType: BinaryMessageType): void {
    let headerBuffer = TcpClient.generateBinaryDataHeader(data.byteLength, dataType);
    let sendData = BufferUtil.mergeArrayBuffer(headerBuffer, data)
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.SEND,
      data: sendData,
    } as WorkerMessage, [sendData])
  }

  private static generateBinaryDataHeader(binaryDataLength: number, dataType: BinaryMessageType): ArrayBuffer {
    // 创建缓冲区
    const buffer: ArrayBuffer = new ArrayBuffer(LENGTH_TRANSFER_HEADER);
    const view: DataView = new DataView(buffer); // 用于读取和写入 ArrayBuffer 中的数据的视图对象
    // 写入头部
    view.setUint32(0, binaryDataLength, false); // 大端序
    view.setUint8(4, dataType);
    return buffer;
  }

  static close() {
    TcpClient.tcpWorker.postMessage({
      type: WorkerMessageType.CLOSE_CLIENT,
      data: '',
    } as WorkerMessage)
  }
}