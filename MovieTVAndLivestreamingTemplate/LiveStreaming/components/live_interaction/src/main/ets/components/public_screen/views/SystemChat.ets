import { BaseChatMessage } from '../chat/BaseChatMesage';
import { ChatType } from './Constans';

export class SystemChat extends BaseChatMessage {
  constructor(content: string) {
    super(ChatType.SYSTEM_CHAT, content);
  }
}