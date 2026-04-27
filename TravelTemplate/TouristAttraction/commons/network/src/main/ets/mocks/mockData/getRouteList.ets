import { Constant } from 'common';
import { BaseResponse } from '../../types/ResponseTypes';
import { GetRouteLineListResp } from '../../types/responseTypes/GetRouteListResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const routeListMock: BaseResponse<GetRouteLineListResp> =
  {
    code: 0,
    data: [{
      routeId: 0,
      routeName: '经典线路游',
      routeDistance: 10,
      duration: 2,
      routeBanner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_B,
      attractionIds: [0, 1],
      brief: '松山湖景区，全称为东莞市松山湖生态景区，位于广东省东莞市中部，地处粤港澳大湾区的黄金腹地，坐落在东莞市的几何中心，是穗、莞、深、港经济走廊的中段',
    },
      {
        routeId: 1,
        routeName: '精品研学游',
        routeDistance: 25,
        duration: 5,
        routeBanner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_B,
        attractionIds: [0, 2],
        brief: '松山湖景区，全称为东莞市松山湖生态景区，位于广东省东莞市中部，地处粤港澳大湾区的黄金腹地，坐落在东莞市的几何中心，是穗、莞、深、港经济走廊的中段',
      }],
  };