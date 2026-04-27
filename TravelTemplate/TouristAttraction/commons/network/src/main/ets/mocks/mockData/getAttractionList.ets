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
        location: '松山湖欧洲小镇L区',
        introduction: 'L区建筑以海德堡建筑风格为主，红褐色古城堡是海德堡城的标志，大多为白墙红瓦的老城建筑。设计参考了在人文科学上闻名、并在德国具有最悠久历史的海德堡大学，以红砂岩外墙和传统街区构成建筑群，布置在小山丘上细致而雄伟的城堡与由网格状道路构成的街区形成了鲜明的对比。',
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
          location: '松山湖欧洲小镇J区',
          introduction: 'J区借鉴了弗里堡的中世纪古城风格，哥特式建筑赋予了这座古城无与伦比的风格与魅力，以白墙红瓦的淡色系建筑为主。根据用地起伏、靠近松山湖水域的地理位置特点，结合瑞士具有历史性的古城和修道院建筑特色，通过棕红色瓦斜坡屋顶和绿色砂岩外墙等特征，打造了面向湖畔的斜面风景。',
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
          location: '松山湖欧洲小镇K区',
          introduction: 'K区以勃艮第为模板，勃艮第地区位于法国巴黎南部，日照充足，是世界闻名的葡萄酒产区，主要出产酒体从中等到丰满的红葡萄酒，以及干白葡萄酒。借鉴了枫德内修道院、昂诺克西奥街区以及以棕红色屋顶为特征的瑟米尔，利用现代工艺和手法将其进行重塑，形成了特有的建筑风貌。"',
        },
      ] as AttractionListItem[],
    },
  };
