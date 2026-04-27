import { WorkerMessageType } from '../common/Constant';
import { FileCountMessage } from '../model/BinaryProtocol';
import { ConnectionVo } from '../model/ConnectionVo';
import { TcpCallback } from '../model/TcpCallback';
import { ReceiveProgressInfo, WorkerMessage } from '../model/WorkerMessage';
import { worker, MessageEvents } from '@kit.ArkTS';
import { FileVo } from '../model/FileVo';
import { common } from '@kit.AbilityKit';
import { FileTransferCallback } from '../model/FileTransferCallback';

export class TcpServer {
  private static tcpWorker = new worker.ThreadWorker('../workers/TCPSocketServerWorker.ets');
  private static tcpCallback: TcpCallback = {}
  static context: common.UIAbilityContext | undefined;
  static fileTransCallback: FileTransferCallback = {} as FileTransferCallback;

  static create(ip: string, tcpCallback: TcpCallback) {
    TcpServer.tcpCallback = tcpCallback;
    TcpServer.tcpWorker.onmessage = (event: MessageEvents) => {
      const data = event.data as WorkerMessage;
      switch (data.type) {
        case WorkerMessageType.LISTEN:
          TcpServer.handleListenCallback(data.data as string);
          break;
        case WorkerMessageType.CONNECT:
          TcpServer.handleConnectionCallback();
          break;
        case WorkerMessageType.RECEIVE_FILE_COUNT:
          if (TcpServer.fileTransCallback.onBefore) {
            TcpServer.fileTransCallback.onBefore(data.data as FileCountMessage)
          }
          break;
        case WorkerMessageType.START:
          const type = Number(data.data as string)
          if (TcpServer.fileTransCallback.onStart) {
            TcpServer.fileTransCallback.onStart(type)
          }
          break;
        case WorkerMessageType.PROGRESS:
          const event = data.data as ReceiveProgressInfo
          if (TcpServer.fileTransCallback.onProgress) {
            TcpServer.fileTransCallback.onProgress(event.fileVo, event.byteLength)
          }
          break;
        case WorkerMessageType.END:
          const fileVo = data.data as FileVo
          if (TcpServer.fileTransCallback.onComplete) {
            TcpServer.fileTransCallback.onComplete(fileVo)
          }
          break;
        default:
          break;
      }
    }
    TcpServer.tcpWorker.postMessage({
      type: WorkerMessageType.CONTEXT,
      data: TcpServer.context,
    } as WorkerMessage)
    TcpServer.tcpWorker.postMessage({
      type: WorkerMessageType.LISTEN,
      data: {
        ip: ip,
        port: 0,
      } as ConnectionVo,
    } as WorkerMessage)
  }

  static refresh(ip: string) {
    TcpServer.tcpWorker.postMessage({
      type: WorkerMessageType.LISTEN,
      data: {
        ip: ip,
        port: 0,
      } as ConnectionVo,
    } as WorkerMessage)
  }

  static handleConnectionCallback() {
    if (TcpServer.tcpCallback.onConnected) {
      TcpServer.tcpCallback.onConnected();
    }
  }

  static handleListenCallback(data: string) {
    if (data.startsWith('code')) {
      if (TcpServer.tcpCallback.onFailed) {
        TcpServer.tcpCallback.onFailed(data)
      }
    } else {
      if (TcpServer.tcpCallback.onPrepared) {
        TcpServer.tcpCallback.onPrepared(Number(data))
      }
    }
  }
}
