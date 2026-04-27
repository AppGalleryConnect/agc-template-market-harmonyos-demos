import { StickerResp } from '../../model/Index';
import request from '../Request';
// 启动mock
import('../../httpsmock/MockAdapter');

class StickerApis {
  /**
   * 获取贴纸列表
   */
  public getStickerList(): Promise<StickerResp[]> {
    return request.get('/sticker/list');
  }
}

const instance = new StickerApis();

export { instance as StickerApis };