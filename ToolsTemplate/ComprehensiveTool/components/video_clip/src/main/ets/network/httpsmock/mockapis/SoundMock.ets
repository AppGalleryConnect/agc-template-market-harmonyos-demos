import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { HttpStatusCode } from '@ohos/axios';
import { mockSoundList } from '../MockData';

export class SoundMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取音乐列表
    adapter.onGet('/sound/list').reply(() => {
      return [HttpStatusCode.Ok, mockSoundList];
    })
  }
}