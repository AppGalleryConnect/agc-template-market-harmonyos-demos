import { HashMap, util } from '@kit.ArkTS';
import * as wxopensdk from '@tencent/wechat_open_sdk';
import { UtilLog } from '@hw-agconnect/util-log';

import { WeChatRequestCb, WeChatResponseCb } from '../common/CustomTypes';

const TAG: string = '[WechatEventHandler]';

class WechatEventHandler implements wxopensdk.WXApiEventHandler {
  private requestCallbacks: HashMap<string, WeChatRequestCb> = new HashMap();
  private responseCallbacks: HashMap<string, WeChatResponseCb> = new HashMap();

  public registerRequestEvent(cb: WeChatRequestCb): string {
    const id: string = util.generateRandomUUID(false);
    try {
      this.requestCallbacks.set(id, cb);
    } catch (error) {
      UtilLog.error(TAG, 'register request event failed. error: ' + JSON.stringify(error));
    }
    return id;
  }

  public registerResponseEvent(cb: WeChatResponseCb): string {
    const id: string = util.generateRandomUUID(false);
    try {
      this.responseCallbacks.set(id, cb);
    } catch (error) {
      UtilLog.error(TAG, 'register response event failed. error: ' + JSON.stringify(error));
    }
    return id;
  }

  public unregisterRequestEvent(callbackId: string): void {
    try {
      this.requestCallbacks.remove(callbackId);
    } catch (error) {
      UtilLog.error(TAG, 'remove request event failed. error: ' + JSON.stringify(error));
    }
  }

  public unregisterResponseEvent(callbackId: string): void {
    try {
      this.responseCallbacks.remove(callbackId);
    } catch (error) {
      UtilLog.error(TAG, 'remove response event failed. error: ' + JSON.stringify(error));
    }
  }

  public unregisterAllRequestEvents(): void {
    try {
      this.requestCallbacks.clear();
    } catch (error) {
      UtilLog.error(TAG, 'clear request event failed. error: ' + JSON.stringify(error));
    }
  }

  public unregisterAllResponseEvents(): void {
    try {
      this.responseCallbacks.clear();
    } catch (error) {
      UtilLog.error(TAG, 'clear response event failed. error: ' + JSON.stringify(error));
    }
  }

  public onReq(req: wxopensdk.BaseReq): void {
    try {
      this.requestCallbacks.forEach((cb: WeChatRequestCb): void => cb(req));
    } catch (error) {
      UtilLog.error(TAG, 'handle request event failed. error: ' + JSON.stringify(error));
    }
  }

  public onResp(resp: wxopensdk.BaseResp): void {
    try {
      this.responseCallbacks.forEach((cb: WeChatResponseCb): void => cb(resp));
    } catch (error) {
      UtilLog.error(TAG, 'handle response event failed. error: ' + JSON.stringify(error));
    }
  }
}

export const wechatEventHandler: WechatEventHandler = new WechatEventHandler();
