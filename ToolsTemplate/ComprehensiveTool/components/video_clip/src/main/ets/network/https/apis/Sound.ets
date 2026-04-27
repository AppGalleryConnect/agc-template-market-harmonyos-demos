import { SoundResp } from '../../model/Index';
import request from '../Request';
// 启动mock
import('../../httpsmock/MockAdapter');

class SoundApis {
  /**
   * 获取音效列表
   */
  public getSoundList(): Promise<SoundResp[]> {
    return request.get('/sound/list');
  }
}

const instance = new SoundApis();

export { instance as SoundApis };