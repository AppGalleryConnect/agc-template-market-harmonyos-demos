import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { request } from './Apis';
import { MOCK_MESSAGE_LIST, MOCK_MESSAGE_GROUP } from './MockData';
import { RequestUrlMap } from '../commons/Enums';
import { MessageGroup, MessageItem } from '../commons/Types';

export class NoticeMockApis {
  private _mockGroup: MessageGroup[] = MOCK_MESSAGE_GROUP;
  private _mockList: MessageItem[] = MOCK_MESSAGE_LIST;

  public start(adapter: AxiosMockAdapter) {
    // 获取消息群组
    adapter
      .onGet(RequestUrlMap.NOTICE_GROUP)
      .reply((config: AxiosRequestConfig) => {
        return [HttpStatusCode.Ok, this._mockGroup];
      });

    // 获取某一类型的消息列表
    adapter
      .onGet(RequestUrlMap.NOTICE_LIST)
      .reply((config: AxiosRequestConfig) => {
        const type: number = config.params.type;
        const resList = this._mockList.filter(
          (message) => message.type === type,
        );
        return [HttpStatusCode.Ok, resList];
      });

    // 修改消息已读状态
    adapter
      .onPost(RequestUrlMap.NOTICE_STATUS_CHANGE)
      .reply((config: AxiosRequestConfig) => {
        const type: number = config.data;
        this._mockList.forEach((message) => {
          if (message.type === type && !message.isRead) {
            message.isRead = true;
          }
        });
        this._mockGroup.forEach((group) => {
          if (group.type === type) {
            group.unreadCount = 0;
          }
        });
        return [HttpStatusCode.Ok, 0];
      });

    // 一键已读
    adapter
      .onPost(RequestUrlMap.NOTICE_STATUS_CHANGE_ALL)
      .reply((config: AxiosRequestConfig) => {
        this._mockList.forEach((message) => {
          if (!message.isRead) {
            message.isRead = true;
          }
        });
        this._mockGroup.forEach((group) => {
          group.unreadCount = 0;
        });
        return [HttpStatusCode.Ok, 0];
      });

    // 删除消息
    adapter
      .onDelete(RequestUrlMap.NOTICE_DETAIL)
      .reply((config: AxiosRequestConfig) => {
        const id = config.params.id as string;
        this._mockList = this._mockList.filter((message) => message.id !== id);
        return [HttpStatusCode.Ok, 0];
      });
  }
}

export const adapter = new AxiosMockAdapter(request, {
  delayResponse: 300,
});

// 全局配置，是否启用mock，当前默认启用
const enableMock: boolean = true;

if (enableMock) {
  const apis = new NoticeMockApis();
  apis.start(adapter);
}
