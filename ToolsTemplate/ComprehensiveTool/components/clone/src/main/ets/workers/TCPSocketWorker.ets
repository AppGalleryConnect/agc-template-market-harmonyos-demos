import { MessageEvents, ThreadWorkerGlobalScope, worker } from '@kit.ArkTS';
import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  BinaryMessageType,
  FileType,
  LENGTH_READ_FILE_CHUNK,
  LENGTH_TRANSFER_HEADER,
  WorkerMessageType,
} from '../common/Constant';
import { ConnectionVo } from '../model/ConnectionVo';
import { ProgressInfo, WorkerMessage } from '../model/WorkerMessage';
import { UtilLog } from '@hw-agconnect/util-log';
import { FileVo } from '../model/FileVo';
import { FileReaderService } from '../service/FileReadService';
import { TransferUtil } from '../utils/TransferUtil';
import { ContactMessage, FileCountMessage, FileEndMessage, FileStartMessage } from '../model/BinaryProtocol';
import { BufferUtil } from '../utils/BufferUtil';
import { BinaryProtocolCodec } from '../utils/BinaryProtocolCodec';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

const tcpSocket = socket.constructTCPSocketInstance();

workerPort.onmessage = async (event: MessageEvents) => {
  let data = event.data as WorkerMessage;
  switch (data.type) {
    case WorkerMessageType.CONNECT:
      connectServerAddress(data.data as ConnectionVo);
      break;
    case WorkerMessageType.SEND_FILE_COUNT:
      sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(data.data as FileCountMessage),
        BinaryMessageType.FILE_COUNT)
      break;
    case WorkerMessageType.CONTACT:
      workerPort.postMessage({
        type: WorkerMessageType.START,
        data: FileType.CONTACT.toString(),
      } as WorkerMessage);
      const event = JSON.parse(data.data as string) as ContactMessage
      sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(event),
        BinaryMessageType.CONTACT)
      break;
    case WorkerMessageType.SEND:
      readFileData(data.data as FileVo)
      break;
    case WorkerMessageType.CLOSE_CLIENT:
      closeClient();
      break;
    default:
      break;
  }
};

function connectServerAddress(data: ConnectionVo) {
  tcpSocket.connect({
    address: {
      address: data.ip,
      port: data.port,
    },
    timeout: 2000,
  }).then(() => {
    workerPort.postMessage({
      type: WorkerMessageType.CONNECT,
      data: 'success',
    } as WorkerMessage);
  }).catch((err: Error) => {
    workerPort.postMessage({
      type: WorkerMessageType.CONNECT,
      data: `code: ${err.message}`,
    } as WorkerMessage);
  });
}

// 读取文件
function readFileData(fileVo: FileVo) {
  let streamReader: FileReaderService | null = null
  try {
    // 1. 读取文件信息
    // 创建流式文件读取器
    streamReader = new FileReaderService(LENGTH_READ_FILE_CHUNK);
    // 打开文件
    streamReader.openFile(fileVo);
    const fileData = streamReader.getFileInfo();
    // 添加null检查
    if (!fileData) {
      console.error('文件读取失败，无法发送文件:', fileVo.name);
      return;
    }
    const totalChunks = fileData.totalChunks

    workerPort.postMessage({
      type: WorkerMessageType.START,
      data: fileVo.type.toString(),
    } as WorkerMessage);

    // 2. 发送文件开始消息
    const startMessage: FileStartMessage = {
      fileName: fileVo.name,
      fileSize: fileVo.size,
      fileType: fileVo.type,
      totalChunks: totalChunks,
      chunkSize: fileData.chunkSize,
      deviceImgData: fileVo.deviceImgData,
      deviceName: fileVo.deviceName,
    };
    sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(startMessage),
      BinaryMessageType.FILE_START)

    // 3. 分片发送
    for (let i = 0; i < totalChunks; i++) {
      const chunk = streamReader?.readNextChunk()
      if (!chunk) {
        console.error('文件读取失败，无法发送文件:', fileVo.name);
        return;
      }
      // 计算最优分片大小
      const optimalTransferChunkSize = TransferUtil.calculateOptimalChunkSize(chunk.size);
      const transferBatches = chunk.size / optimalTransferChunkSize + 1
      for (let index = 0; index < transferBatches; index++) {
        let transferBufferData = chunk.data.slice(0, optimalTransferChunkSize);
        if (transferBufferData.byteLength > 0) {
          workerPort.postMessage({
            type: WorkerMessageType.PROGRESS,
            data: {
              type: fileVo.type,
              progress: transferBufferData.byteLength,
            } as ProgressInfo,
          } as WorkerMessage);
          sendBinaryData(transferBufferData, BinaryMessageType.FILE_CHUNK);
        }
        chunk.data = chunk.data.slice(optimalTransferChunkSize)
      }
    }

    // 4. 发送文件结束消息
    const endMessage: FileEndMessage = {
      fileName: fileVo.name,
      fileSize: fileVo.size,
      totalChunks: totalChunks,
    };
    sendBinaryData(BinaryProtocolCodec.encodeBinaryProtocolMessage(endMessage),
      BinaryMessageType.FILE_END);
  } catch (error) {
    console.error('文件发送失败:', JSON.stringify(error));
    workerPort.postMessage({
      type: WorkerMessageType.SEND,
      data: `encoding error: ${error}`,
    } as WorkerMessage);
  } finally {
    streamReader?.destroy() // 销毁流式读取器
    streamReader = null
  }
}

// 发送二进制数据
function sendBinaryData(data: ArrayBuffer | null, dataType: BinaryMessageType) {
  if (data) {
    let headerBuffer: ArrayBuffer | null = generateBinaryDataHeader(data.byteLength, dataType);
    let sendData: ArrayBuffer | null = BufferUtil.mergeArrayBuffer(headerBuffer, data)
    try {
      tcpSocket.send({
        data: sendData,
      }, (err: BusinessError) => {
        if (err) {
          workerPort.postMessage({
            type: WorkerMessageType.SEND,
            data: `code: ${err.code}, message: ${err.message}`,
          } as WorkerMessage);
        } else {
          workerPort.postMessage({
            type: WorkerMessageType.SEND,
            data: 'tcp send success',
          } as WorkerMessage);
          if (dataType === BinaryMessageType.FILE_END || dataType === BinaryMessageType.CONTACT) {
            workerPort.postMessage({
              type: WorkerMessageType.END,
              data: ``,
            } as WorkerMessage);
          }
          headerBuffer = null
          sendData = null
        }
      });
    } catch (error) {
      workerPort.postMessage({
        type: WorkerMessageType.SEND,
        data: `encoding error: ${error}`,
      } as WorkerMessage);
    }
  }
}

function generateBinaryDataHeader(binaryDataLength: number, dataType: BinaryMessageType): ArrayBuffer {
  // 创建缓冲区
  const buffer: ArrayBuffer = new ArrayBuffer(LENGTH_TRANSFER_HEADER);
  const view: DataView = new DataView(buffer); // 用于读取和写入 ArrayBuffer 中的数据的视图对象
  // 写入头部
  view.setUint32(0, binaryDataLength, false); // 大端序
  view.setUint8(4, dataType);
  return buffer;
}

function closeClient() {
  tcpSocket.close(() => {
    UtilLog.info('%{public}s', '客户端关闭成功');
  });
}
