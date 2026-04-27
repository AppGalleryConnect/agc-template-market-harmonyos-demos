import { util } from '@kit.ArkTS';

// 消息类型枚举
export enum MessageType {
  TEXT = 'text',
  IMAGE = 'image',
}

// 消息发送状态
export enum MessageStatus {
  SENDING = 'sending',
  SENT = 'sent',
  FAILED = 'failed',
}

// 消息发送者类型
export enum SenderType {
  USER = 'user',
  CUSTOMER_SERVICE = 'customer_service',
}

export interface MessageData{
  content: ResourceStr; // 消息内容（文本内容或图片URL）
  type: MessageType; // 消息类型
  timestamp: number; // 时间戳
}

// 消息实体类
export class MessageModel {
  id: string; // 消息ID
  content: ResourceStr; // 消息内容（文本内容或图片URL）
  type: MessageType; // 消息类型
  sender: SenderType; // 发送者
  timestamp: number; // 时间戳
  status: MessageStatus; // 发送状态

  constructor(content: ResourceStr, type: MessageType, sender: SenderType) {
    this.id = this.generateId();
    this.content = content;
    this.type = type;
    this.sender = sender;
    this.timestamp = Date.now();
    this.status = MessageStatus.SENT;
  }

  // 生成唯一ID
  private generateId(): string {
    return `${Date.now()}_${util.generateRandomUUID(false)}`;
  }
}

// 聊天会话类
export class ChatSession {
  sessionId: string;
  messages: MessageModel[];

  constructor(sessionId: string) {
    this.sessionId = sessionId;
    this.messages = [];
  }

  // 添加消息
  addMessage(message: MessageModel): void {
    this.messages.push(message);
  }

  // 获取最后一条消息
  getLastMessage(): MessageModel | null {
    return this.messages.length > 0
      ? this.messages[this.messages.length - 1]
      : null;
  }
}

//历史消息记录类
@ObservedV2
export class MessageHistoryModel {
  @Trace list: MessageModel[] = [];
}
