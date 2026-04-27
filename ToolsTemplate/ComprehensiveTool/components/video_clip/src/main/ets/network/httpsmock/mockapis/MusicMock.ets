import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { HttpStatusCode } from '@ohos/axios';
import { mockMusicList } from '../MockData';

export class MusicMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 获取音乐列表
    adapter.onGet('/music/list').reply(() => {
      return [HttpStatusCode.Ok, mockMusicList];
    })
  }
}