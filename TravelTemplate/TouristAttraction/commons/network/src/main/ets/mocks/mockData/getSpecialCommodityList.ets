import { Constant } from 'common';
import { BaseResponse } from '../../types/ResponseTypes';
import { GetCommodityListResp } from '../../types/responseTypes/GetCommodityListResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const specialCommodityListMock: BaseResponse<GetCommodityListResp> =
  {
    code: 0,
    data: [
      {
        commodityId: 0,
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY1,
        basicSpu: 0,
        name: '松山湖特色米香型白酒',
        spuInfo: [
          {
            spuId: 0,
            spuName: '53度米酒',
            spuOriginalPrice: 21,
            spuDiscountPrice: 21,
          },
          {
            spuId: 1,
            spuName: '42度米酒',
            spuOriginalPrice: 32,
            spuDiscountPrice: 32,
          },
        ],
      },
      {
        commodityId: 1,
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY2,
        basicSpu: 0,
        name: '松山湖特产浔糕冰淇淋',
        spuInfo: [
          {
            spuId: 0,
            spuName: '经典传统核桃味',
            spuOriginalPrice: 19,
            spuDiscountPrice: 19,
          },
          {
            spuId: 1,
            spuName: '东南亚特色榴莲味',
            spuOriginalPrice: 30,
            spuDiscountPrice: 30,
          },
        ],
      },
      {
        commodityId: 2,
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY1,
        basicSpu: 0,
        name: '松山湖特色酱香型白酒',
        spuInfo: [
          {
            spuId: 0,
            spuName: '经典传统酱香味',
            spuOriginalPrice: 19,
            spuDiscountPrice: 19,
          },
          {
            spuId: 1,
            spuName: '东南亚特色酱香味',
            spuOriginalPrice: 30,
            spuDiscountPrice: 30,
          },
        ],
      },
      {
        commodityId: 3,
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY2,
        basicSpu: 0,
        name: '松山湖特产汤圆',
        spuInfo: [
          {
            spuId: 0,
            spuName: '经典传统核桃味',
            spuOriginalPrice: 19,
            spuDiscountPrice: 19,
          },
          {
            spuId: 1,
            spuName: '东南亚特色榴莲味',
            spuOriginalPrice: 30,
            spuDiscountPrice: 30,
          },
        ],
      },
    ],
  };