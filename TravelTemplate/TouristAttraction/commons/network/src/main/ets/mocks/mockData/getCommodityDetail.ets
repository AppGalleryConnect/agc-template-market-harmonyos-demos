import { Constant } from 'common';
import { GetCommodityDetailsResp } from '../../types/responseTypes/GetCommodityDetailResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const commodityDetailList: GetCommodityDetailsResp = [
  {
    commodityId: 3,
    banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY1,
    banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY1],
    detail: '',
    basicSpu: 0,
    introduction: '',
    name: '广东特产百搭蚕丝丝巾',
    detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY1],
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
    banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY2],
    detail: '',
    basicSpu: 0,
    introduction: '',
    name: '松山湖毛笔专业套装',
    detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.CULTURE_COMMODITY2],
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
  }, {
  commodityId: 0,
  banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY1,
  banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY1],
  detail: '',
  basicSpu: 0,
  introduction: '',
  name: '松山湖特色米香型白酒',
  detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY1],
  spuInfo: [{
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
    }],
},
  {
    commodityId: 1,
    banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY2,
    banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY2],
    detail: '',
    basicSpu: 0,
    introduction: '',
    name: '松山湖特产浔糕冰淇淋',
    detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.SPECIAL_COMMODITY2],
    spuInfo: [{
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
      }],
  },
];
