import { BaseAuthor } from '../../database/AuthorType';

/**
 * User Mock数据
 */
export class MockUser {
  // 本人模型
  static myself: BaseAuthor = {
    authorId: '001',
    authorNickName: '华为用户',
    authorIcon: 'https://agc-storage-drcn.platform.dbankcloud.cn/v0/news-hnp2d/avatar%2Favatar_12.jpg',
    authorDesc: '在自己的小世界里，做一个快乐的普通人，把节奏放慢，享受生活！十六岁的青春张扬 十八岁的未来可期，携零零碎碎的美好奔赴未知的将来！',
    authorPhone: '177******96',
    authorIp: '南京',
    subscribe: [],
  };
}