import { BinaryMessageType, LENGTH_RECORD_DATA_IN_HEADER, LENGTH_TRANSFER_HEADER } from '../common/Constant';
import {
  BinaryProtocolHeader,
  BinaryProtocolMessage,
  ContactMessage,
  FileCountMessage,
  FileEndMessage,
  FileStartMessage,
} from '../model/BinaryProtocol';
import { BufferUtil } from './BufferUtil';
import { util } from '@kit.ArkTS';


/**
 * 二进制协议编解码器类
 * 负责二进制协议的编码和解码操作
 */
export class BinaryProtocolCodec {
  static encodeBinaryProtocolMessage(binaryProtocolMessage: BinaryProtocolMessage) {
    return BufferUtil.stringToArrayBuffer(JSON.stringify(binaryProtocolMessage));
  }

  //解析协议头部
  static parseHeader(buffer: ArrayBuffer): BinaryProtocolHeader {
    try {
      if (buffer.byteLength < LENGTH_TRANSFER_HEADER) {
        throw new Error(`缓冲区长度不足，需要${LENGTH_TRANSFER_HEADER}字节，实际${buffer.byteLength}字节`);
      }
      const view: DataView = new DataView(buffer);
      return {
        dataLength: view.getUint32(0, false),
        type: view.getUint8(LENGTH_RECORD_DATA_IN_HEADER) as BinaryMessageType,
      };
    } catch (error) {
      throw new Error(`解析协议头部失败: ${error}`);
    }
  }

  //解码文件数量消息
  static decodeFileCountMessage(dataBuffer: ArrayBuffer): FileCountMessage {
    try {
      const textDecoder = util.TextDecoder.create();
      // 将 ArrayBuffer 转换为 Uint8Array
      const uint8Data = new Uint8Array(dataBuffer);
      const jsonStr: string = textDecoder.decodeToString(uint8Data);
      return JSON.parse(jsonStr) as FileCountMessage;
    } catch (error) {
      throw new Error(`解码文件开始消息失败: ${error}`);
    }
  }

  //解码文件开始消息
  static decodeFileStartMessage(dataBuffer: ArrayBuffer): FileStartMessage | ContactMessage {
    try {
      const textDecoder = util.TextDecoder.create();
      // 将 ArrayBuffer 转换为 Uint8Array
      const uint8Data = new Uint8Array(dataBuffer);
      const jsonStr: string = textDecoder.decodeToString(uint8Data);
      return JSON.parse(jsonStr)
    } catch (error) {
      throw new Error(`解码文件开始消息失败: ${error}`);
    }
  }

  //解码文件结束消息
  static decodeFileEndMessage(dataBuffer: ArrayBuffer): FileEndMessage {
    try {
      const textDecoder = util.TextDecoder.create();
      // 将 ArrayBuffer 转换为 Uint8Array
      const uint8Data = new Uint8Array(dataBuffer);
      const jsonStr: string = textDecoder.decode(uint8Data);
      return JSON.parse(jsonStr) as FileEndMessage;
    } catch (error) {
      throw new Error(`解码文件结束消息失败: ${error}`);
    }
  }
}