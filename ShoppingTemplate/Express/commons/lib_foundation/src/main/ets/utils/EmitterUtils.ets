import { emitter } from '@kit.BasicServicesKit';
import { Logger } from './Logger';

const TAG = '[EmitterUtils]'

export class EmitterUtils {
  /**
   * 发送事件
   * @param eventId 事件唯一ID
   * @param data 要传递的数据对象
   */
  static emit(eventId: string, data?: ESObject): void {
    const eventData: emitter.EventData = {
      data: data
    };
    try {
      emitter.emit(eventId, eventData);
    } catch (e) {
      Logger.error(TAG, `${eventId} emit failed. error: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 持续订阅事件
   * @param eventId 事件唯一ID
   * @param callback 回调函数
   */
  static on(eventId: string, callback: (data?: emitter.EventData) => void): void {
    try {
      emitter.on(eventId, (eventData: emitter.EventData) => {
        if (callback) {
          callback(eventData.data);
        }
      });
    } catch (e) {
      Logger.error(TAG, `${eventId} on failed. error: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 单次订阅事件
   * @param eventId 事件唯一ID
   * @param callback 回调函数
   */
  static once(eventId: string, callback: (data?: emitter.EventData) => void): void {
    try {
      emitter.once(eventId, (eventData: emitter.EventData) => {
        if (callback) {
          callback(eventData.data);
        }
      });
    } catch (e) {
      Logger.error(TAG, `${eventId} once failed. error: ${JSON.stringify(e)}`)
    }
  }

  /**
   * 取消订阅
   * @param eventId 事件唯一ID
   */
  static off(eventId: string, callback?: (data?: emitter.EventData) => void): void {
    try {
      if (callback) {
        emitter.off(eventId, callback);
      } else {
        emitter.off(eventId);
      }
    } catch (e) {
      Logger.error(TAG, `${eventId} off failed. error: ${JSON.stringify(e)}`)
    }
  }
}