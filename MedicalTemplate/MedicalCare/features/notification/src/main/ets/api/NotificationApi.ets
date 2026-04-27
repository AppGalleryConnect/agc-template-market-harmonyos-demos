import { BaseApi, RequestMethod } from 'common';
import { NotificationModel } from '../model/NotificationModel';

export class NotificationApi extends BaseApi {
  constructor() {
    super({
      isMock: true
    })
  }

  /**
   * 获取消息通知列表
   */
  public getNotificationList() {
    return this.sendRequest<NotificationModel[]>('/notification', RequestMethod.GET, undefined)
  }
}