import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { HttpStatusCode } from '@ohos/axios';
import { mockStickerList } from '../MockData';

export class StickerMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取贴纸列表
    adapter.onGet('/sticker/list').reply(() => {
      return [HttpStatusCode.Ok, mockStickerList];
    });
  }
}