import { Constant } from 'common';
import { GetAccommodationDetailResp } from '../../types/responseTypes/GetAccommodationDetailResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const accommodationDetailMock: GetAccommodationDetailResp = {
  siteId: '',
  banner: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.ACCOMMODATION],
  images: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.ACCOMMODATION],
  detail: '碧水湾酒店是松山湖地区首家按五星级标准规划设计的旅游会议型、亲水型湖畔酒店,酒店倒影水中,缤纷霓虹、风情万种,零距离与水交融。2024年9月CBA国内篮球联赛的指定接待酒店。集住宿、餐饮、会务、健身房、观光游玩、垂钓等服务于一体。建筑总面积2万多平米,总投资2.2亿。地上主体建筑共13层。东临106国道,西临万顷松山湖:“下榻碧水湾酒店,观赏松山湖全景”。',
  labels: ['WiFi服务', '免费停车场', '行李寄存', '24小时服务'],
};