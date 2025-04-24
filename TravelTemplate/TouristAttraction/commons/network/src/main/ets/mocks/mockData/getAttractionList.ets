import { Constant } from 'common';
import { BaseResponse } from '../../types/ResponseTypes';
import { AttractionListItem, GetAttractionsInfoResp } from '../../types/responseTypes/GetAttractionListResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const attractionListMock: BaseResponse<GetAttractionsInfoResp> =
  {
    code: 0,
    data: {
      banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.SWIPER],
      attractions: [{
        labels: ['文化建筑', '异域风情'],
        detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG],
        attractionId: 0,
        name: '海德尔堡',
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_B,
        icon: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_I,
        isHot: 1,
        latitude: 22.878538,
        longitude: 113.886642,
        audio: Constant.CLOUD_STORAGE_URL + MockResourceEnum.AUDIO,
        location: '松山湖欧洲小镇L区'
      },
        {
          labels: ['文化建筑', '欧美浪漫'],
          detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY],
          attractionId: 1,
          name: '勃艮第',
          banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_B,
          icon: Constant.CLOUD_STORAGE_URL + MockResourceEnum.BURGUNDY_I,
          isHot: 0,
          latitude: 22.881063,
          longitude: 113.88549,
          audio: Constant.CLOUD_STORAGE_URL + MockResourceEnum.AUDIO,
          location: '松山湖欧洲小镇J区'
        },
        {
          labels: ['意大利', '浪漫古堡'],
          detailImages: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.FRIBOURG],
          attractionId: 2,
          name: '弗里堡',
          banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.FRIBOURG_B,
          icon: Constant.CLOUD_STORAGE_URL + MockResourceEnum.FRIBOURG_I,
          isHot: 1,
          latitude: 22.883272,
          longitude: 113.889091,
          audio: Constant.CLOUD_STORAGE_URL + MockResourceEnum.AUDIO,
          location: '松山湖欧洲小镇K区'
        },
        ] as AttractionListItem[]
    }
  }
