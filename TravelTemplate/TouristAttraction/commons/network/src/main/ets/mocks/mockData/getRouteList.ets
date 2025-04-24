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
    },
      {
        routeId: 1,
        routeName: '精品研学游',
        routeDistance: 25,
        duration: 5,
        routeBanner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_B,
        attractionIds: [0, 2],
      }],
  };