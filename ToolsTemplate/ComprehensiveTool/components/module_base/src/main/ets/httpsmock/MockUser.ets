import { UserResponse } from '../model/HttpResponse';

/**
 * User Mock数据
 */
export class MockUser {
  static user: UserResponse = {
    userId: '001',
    userNickName: '华为用户',
    userIcon: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_12.jpg',
    userPhone: '177******96',
  };
}