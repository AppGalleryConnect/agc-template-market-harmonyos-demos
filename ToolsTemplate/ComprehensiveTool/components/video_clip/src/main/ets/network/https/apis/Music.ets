import { MusicResp } from '../../model/Index';
import request from '../Request';
// 启动mock
import('../../httpsmock/MockAdapter');


class MusicApis {
  /**
   * 获取音乐列表
   */
  public getMusicList(): Promise<MusicResp[]> {
    return request.get('/music/list');
  }
}

const instance = new MusicApis();

export { instance as MusicApis };