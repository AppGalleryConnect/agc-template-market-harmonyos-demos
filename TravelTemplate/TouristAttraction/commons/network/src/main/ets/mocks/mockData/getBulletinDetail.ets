import { Constant } from 'common';
import { GetBulletinDetailsResp } from '../../types/responseTypes/GetBulletinDetailResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const bulletinDetailList: GetBulletinDetailsResp = [
  {
    id: 0,
    title: '松山湖关于五一国庆节期间小火车M-F区分段停运检修的通知',
    detail: '松山湖关于五一国庆节期间小火车M-F区分段停运检修的通知',
    releaseTime: '2025-04-28 11:26:33',
    banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_B,
    detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_I],
  },
  {
    id: 1,
    title: '关于松山湖景区迎宾表演暂停演出的公告',
    detail: '尊敬的游客朋友们:\n' + '\n' +
      '        因天气原因,松山湖旅游景区L区的迎宾表演于3月16日起暂停演出。由此给您带来的不便,敬请谅解。\n' + '\n' +
      '        您可以关注景区官方网站，了解景区最新信息或拨打景区客服电话咨询。',
    releaseTime: '2025-03-11 14:16:48',
    banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_B,
    detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_L],
  },
];
