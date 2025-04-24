import { Constant } from 'common';
import { BaseResponse } from '../../types/ResponseTypes';
import { GetNoteListResp } from '../../types/responseTypes/GetNoteListResp';
import { MockResourceEnum } from '../MockResourceEnum';

export const noteListMock: BaseResponse<GetNoteListResp> =
  {
    code: 0,
    data: [{
      noteId: 0,
      name: '美丽的海德尔堡',
      banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.HEIDELBERG_B,
    },
      {
        noteId: 1,
        name: '松山湖小火车乘坐体验',
        banner: Constant.CLOUD_STORAGE_URL + MockResourceEnum.SWIPER,
      }],
  };