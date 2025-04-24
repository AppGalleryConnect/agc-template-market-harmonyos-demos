import { Constant } from 'common';
import { BaseResponse } from '../../types/ResponseTypes';
import { GetCommodityListResp } from '../../types/responseTypes/GetCommodityListResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const culturalCommodityListMock: BaseResponse<GetCommodityListResp> =
  {
    code: 0,
    data: [{
      commodityId: 3,
      banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY1,
      basicSpu: 0,
      name: '广东特产百搭蚕丝丝巾',
      spuInfo: [{
        spuId: 0,
        spuName: '特色田园配色',
        spuOriginalPrice: 15,
        spuDiscountPrice: 15,
      },
        {
          spuId: 1,
          spuName: '古韵水乡配色',
          spuOriginalPrice: 24,
          spuDiscountPrice: 24,
        }],
    },
      {
        commodityId: 4,
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY2,
        basicSpu: 0,
        name: '松山湖毛笔专业套装',
        spuInfo: [{
          spuId: 0,
          spuName: '浅忆（适合行书字体）',
          spuOriginalPrice: 12,
          spuDiscountPrice: 12,
        },
          {
            spuId: 1,
            spuName: '深沅（适合隶书字体）',
            spuOriginalPrice: 18,
            spuDiscountPrice: 18,
          }],
      }],
  };