import * as wxopensdk from '@tencent/wechat_open_sdk';
import { HashMap, util } from '@kit.ArkTS';
import { UtilLog } from '@hw-agconnect/util-log';
import { WeChatRequestCb, WeChatResponseCb } from '../common/CustomTypes';

const TAG = '[WechatEventHandler]'

class WechatEventHandler implements wxopensdk.WXApiEventHandler {
  private requestCallbacks: HashMap<string, WeChatRequestCb> = new HashMap();
  private responseCallbacks: HashMap<string, WeChatResponseCb> = new HashMap();

  public registerRequestEvent(cb: WeChatRequestCb): string {
    const id: string = util.generateRandomUUID(false);
    try {
      this.requestCallbacks.set(id, cb);
    } catch (error) {
      UtilLog.error(TAG, `Failed to set request callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
    return id;
  }

  public registerResponseEvent(cb: WeChatResponseCb): string {
    const id: string = util.generateRandomUUID(false);
    try {
      this.responseCallbacks.set(id, cb);
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to set response callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
    return id;
  }

  public unregisterRequestEvent(callbackId: string): void {
    try {
      this.requestCallbacks.remove(callbackId);
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to remove request callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  public unregisterResponseEvent(callbackId: string): void {
    try {
      this.responseCallbacks.remove(callbackId);
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to remove response callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  public unregisterAllRequestEvents(): void {
    try {
      this.requestCallbacks.clear();
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to clear request callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  public unregisterAllResponseEvents(): void {
    try {
      this.responseCallbacks.clear();
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to clear response callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  public onReq(req: wxopensdk.BaseReq): void {
    try {
      this.requestCallbacks.forEach((cb: WeChatRequestCb): void => cb(req));
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to forEacch request callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }

  public onResp(resp: wxopensdk.BaseResp): void {
    try {
      this.responseCallbacks.forEach((cb: WeChatResponseCb): void => cb(resp));
    } catch (error) {
      UtilLog.error(TAG,
        `Failed to forEach response callbacks, errCode: ${error.code}, errMessage: ${error.message}`);
    }
  }
}

export const wechatEventHandler: WechatEventHandler = new WechatEventHandler();
