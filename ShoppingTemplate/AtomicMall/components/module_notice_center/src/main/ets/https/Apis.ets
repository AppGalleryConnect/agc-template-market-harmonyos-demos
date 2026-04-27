import { BusinessError } from '@kit.BasicServicesKit';
import axios, { AxiosResponse } from '@ohos/axios';
import { Logger } from 'module_ui_base';
import { RequestUrlMap } from '../commons/Enums';
import { MessageGroup, MessageItem } from '../commons/Types';

const TAG: string = '[NoticeApis]';

export const request = axios.create({
  baseURL: '',
  timeout: 10 * 3000,
  headers: {},
});

request.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.status === 200) {
      return Promise.resolve(response.data);
    } else {
      Logger.error(
        TAG,
        `https request failed：${response.config.url}. error:` +
        JSON.stringify(response.status),
      );
      return Promise.reject(response);
    }
  },
  (error: BusinessError) => {
    Logger.error(TAG, `https request failed. error:` + JSON.stringify(error));
    return Promise.reject(error);
  },
);

class NoticeApis {
  /**
   * 获取消息群组
   * @returns
   */
  getNoticeGroups(): Promise<MessageGroup[]> {
    return request.get(RequestUrlMap.NOTICE_GROUP);
  }

  /**
   * 获取某一类型的消息列表
   * @param type
   * @returns
   */
  getNoticeList(type: number): Promise<MessageItem[]> {
    return request.get(RequestUrlMap.NOTICE_LIST, { params: { type } });
  }

  /**
   * 修改消息已读状态
   * @param type
   * @returns
   */
  changeNoticeReadStatus(type: number): Promise<number> {
    return request.post(RequestUrlMap.NOTICE_STATUS_CHANGE, type);
  }

  /**
   * 一键已读
   */
  changeAllNoticeReadStatus(): Promise<number> {
    return request.post(RequestUrlMap.NOTICE_STATUS_CHANGE_ALL);
  }

  /**
   * 删除消息
   */
  deleteNotice(id: string): Promise<number> {
    return request.delete(RequestUrlMap.NOTICE_DETAIL, { params: { id } });
  }
}

const apis = new NoticeApis();

export { apis as NoticeApis };
