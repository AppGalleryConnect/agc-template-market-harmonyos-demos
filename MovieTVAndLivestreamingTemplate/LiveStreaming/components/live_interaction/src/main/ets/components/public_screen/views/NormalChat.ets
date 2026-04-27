import { BaseChatMessage } from '../chat/BaseChatMesage';
import { ChatType } from './Constans';

export class SimpleChat extends BaseChatMessage {
  userName: string
  // 点赞等级
  like: boolean = false;
  likeLevel: number = 0;
  // 主播粉团级别
  fans: Boolean = false
  fanName: string | null = null
  fanLevel: number = 0
  // 打赏级别
  pay: boolean = false;
  payLevel: number = 0

  constructor(userName: string, content: string) {
    super(ChatType.NORMAL_CHAT, content);
    this.userName = userName
  }
}