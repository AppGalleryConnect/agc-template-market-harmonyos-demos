import { BaseResponse } from '../../types/ResponseTypes';
import { GetBulletinListResp } from '../../types/responseTypes/GetBulletinListResp';

export const bulletinListMock: BaseResponse<GetBulletinListResp> =
  {
    code: 0,
    data: [
      {
        id: 0,
        title: '松山湖关于五一国庆节期间小火车M-F区分段停运检修的通知',
        releaseTime: '2025-04-28 11:26:33',
      },
      {
        id: 1,
        title: '关于松山湖景区迎宾表演暂停演出的公告',
        releaseTime: '2025-03-11 14:16:48',
      },
    ],
  };
