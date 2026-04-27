import { BaseChatMessage } from '../chat/BaseChatMesage';
import { ChatType } from './Constans';
interface ImageInfo {
  id: string
  title: string
  resource: ResourceStr
}
export interface User {
  id: string,
  avatar: ResourceStr
  nickname: string
}

export interface RichEditorSpan {
  value?: string
  resourceValue?: ResourceStr
  type: 'text' | 'image' | 'builder'
  data?: User | ImageInfo
}
export class RichChat extends BaseChatMessage {
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
  richContent:RichEditorSpan[]

  constructor(userName: string, richContent:RichEditorSpan[]) {
    super(ChatType.RICH_CHAT, '');
    this.userName = userName
    this.richContent = richContent
  }
}