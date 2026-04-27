

import { Logger } from "../logger/AppLogger";
import { Context } from '@kit.AbilityKit';

const TAG = 'EventHubUtil';

interface OnceCallback {
  event: string;
  callback: Function
}

/**
 * 使用全局ability context发送eventhub事件
 */
export class EventHubUtil {
  private static onOnceCallbacks: OnceCallback[] = []

  private constructor() {
  }

  /**
   * 订阅事件（只能收到一次）
   * @param context context
   * @param event 事件名称
   * @param callback 回调
   */
  public static onOnce(context: Context, event: string | string[], callback?: Function): void {
    if (!callback) {
      Logger.info(TAG, `can NOT onOnce, callback is undefined`);
      return;
    }
    let allEvents = [].concat(event);
    allEvents.forEach((event) => {
      try {
        Logger.debug(TAG, `event ${event} onOnce`);
        let onceCallback = {
          event: event,
          callback: callback
        }
        EventHubUtil.onOnceCallbacks.push(onceCallback)
        context?.eventHub.on(event, callback);
      } catch (err) {
        Logger.error(TAG, `eventHub.onOnce ${event} error`);
        EventHubUtil.onOnceCallbacks.pop();
      }
    })
  }

  /**
   * 订阅事件
   * @param context context
   * @param event 事件名称
   * @param callback 回调
   */
  public static on(context: Context, event: string | string[], callback?: Function): void {
    if (!callback) {
      Logger.info(TAG, `can NOT on, callback is undefined`);
      return;
    }
    let allEvents = [].concat(event);
    allEvents.forEach((value) => {
      try {
        Logger.debug(TAG, `event ${value} on`);
        context?.eventHub.on(value, callback);
      } catch (err) {
        Logger.error(TAG, `eventHub.on ${value} error`);
      }
    })
  }

  /**
   * 触发事件
   * @param context context
   * @param event 事件
   * @param args 参数
   */
  public static emit(context: Context, event: string | string[], ...args: unknown[]): void {
    let allEvents = [].concat(event);
    allEvents.forEach((value) => {
      try {
        Logger.debug(TAG, `event ${value} emit`);
        context?.eventHub.emit(value, args);
        let onOnceCallbacks = EventHubUtil.onOnceCallbacks.filter(item => item.event === value) || [];
        EventHubUtil.onOnceCallbacks = EventHubUtil.onOnceCallbacks.filter(item => item.event !== value) || [];
        onOnceCallbacks.forEach(item => {
          context?.eventHub.off(item.event, item.callback);
        })
      } catch (err) {
        Logger.error(TAG, `eventHub.emit ${value} error`);
      }
    })
  }

  /**
   * 取消订阅当前的callBack
   * @param context context
   * @param event 事件
   * @param callback 回调
   */
  public static off(context: Context, event: string, callback?: Function): void {
    if (!callback) {
      Logger.info(TAG, `can NOT off, callback is undefined`);
    }
    try {
      Logger.debug(TAG, `event ${event} off`);
      context?.eventHub.off(event, callback);
    } catch (err) {
      Logger.error(TAG, `eventHub.off error`);
    }
  }

  /**
   * 取消订阅事件的所有callBack
   * @param context context
   * @param event 事件
   */
  public static offAll(context: Context, event: string): void {
    try {
      Logger.debug(TAG, `event off all`);
      context?.eventHub.off(event);
    } catch (err) {
      Logger.error(TAG, `eventHub.off error`);
    }
  }
}
