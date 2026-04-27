import { Constant } from 'common';
import { GetNoteDetailsResp } from '../../types/responseTypes/GetNoteDetailResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const noteDetailListMock: GetNoteDetailsResp =
  [{
    noteId: 0,
    name: '美丽的海德尔堡',
    banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_B,
    banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_B],
    detail: '邂逅美好，从一份好心情开始，有一种心情叫：突然想去衡水湖看风景。趁阳光正好,趁微风不燥，让我们一起感受自然。',
    createTime: '2025-01-07 11:24:12',
  },
    {
      noteId: 1,
      name: '松山湖小火车乘坐体验',
      banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SWIPER,
      banners: [Constant.CLOUD_STORAGE_URL + MockResourceEnum.SWIPER],
      detail: '邂逅美好，从一份好心情开始，有一种心情叫：突然想去松山湖看风景。趁阳光正好,趁微风不燥，让我们一起感受自然。',
      createTime: '2025-01-06 16:24:12',
    }];