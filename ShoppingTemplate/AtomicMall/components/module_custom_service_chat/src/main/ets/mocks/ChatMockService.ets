import { AppStorageV2 } from '@kit.ArkUI';
import { BaseChatService } from '../models/BaseChatModel';
import {
  MessageHistoryModel,
  MessageModel,
  MessageType,
  SenderType,
} from '../models/MessageModel';

export class ChatMockService extends BaseChatService {
  private messageCallbacks: ((message: MessageModel) => void)[] = [];
  private statusCallbacks: ((connected: boolean) => void)[] = [];
  private isMockConnected = false;
  private responseTimer: number | null = null;
  // 智能回复映射
  private responseMap: Map<RegExp, string[]> = new Map([
    [/你好|hello|hi/, ['您好！请问有什么可以帮您？', '你好！很高兴为您服务！']],
    [/退货|退款/, ['请提供订单号，我们会尽快处理', '退货政策是...']],
    [/谢谢|感谢/, ['不客气！', '很高兴能帮助您！']],
    [/快递|物流|发货/, ['一般发货后3-5天到达', '您可以通过订单号查询物流']],
  ]);
  // 默认回复
  private defaultResponses = [
    '我明白了，请您稍等。',
    '好的，正在为您查询。',
    '这个问题我需要进一步确认。',
    '感谢您的耐心等待。',
  ];

  async connect(): Promise<boolean> {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.isMockConnected = true;
        this.notifyStatusChange(true);

        // 发送欢迎消息
        this._sendWelcomeMessage();
        resolve(true);
      }, 1000);
    });
  }

  // 发送欢迎消息
  private _sendWelcomeMessage(): void {
    const history = AppStorageV2.connect(
      MessageHistoryModel,
      () => new MessageHistoryModel(),
    )!;
    if (!history.list.length) {
      const welcomeMessage = new MessageModel(
        '您好！我是客服小助手，请问有什么可以帮您？',
        MessageType.TEXT,
        SenderType.CUSTOMER_SERVICE,
      );

      setTimeout(() => {
        this.notifyMessageReceived(welcomeMessage);
      }, 500);
    }
  }

  async sendMessage(
    content: string,
    _type: MessageType = MessageType.TEXT,
  ): Promise<boolean> {
    if (!this.isMockConnected) {
      return false;
    }

    // 清除之前的定时器
    if (this.responseTimer) {
      clearTimeout(this.responseTimer);
    }

    // 模拟网络延迟
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve(true);

        this.responseTimer = setTimeout(() => {
          this._generateResponse(content);
        }, 1000) as number;
      }, 300);
    });
  }

  // 生成智能回复
  private _generateResponse(userMessage: string): void {
    let responseText = '';

    // 查找匹配的回复模式
    for (const item of this.responseMap) {
      const pattern = item[0];
      const responses = item[1];
      if (pattern.test(userMessage.toLowerCase())) {
        responseText = responses[Math.floor(Math.random() * responses.length)];
        break;
      }
    }

    // 如果没有匹配，使用默认回复
    if (!responseText) {
      responseText =
        this.defaultResponses[
          Math.floor(Math.random() * this.defaultResponses.length)
        ];
    }

    const responseMessage = new MessageModel(
      responseText,
      MessageType.TEXT,
      SenderType.CUSTOMER_SERVICE,
    );

    this.notifyMessageReceived(responseMessage);
  }

  disconnect(): void {
    this.isMockConnected = false;
    if (this.responseTimer) {
      clearTimeout(this.responseTimer);
    }
    this.notifyStatusChange(false);
  }

  onMessageReceived(callback: (message: MessageModel) => void): void {
    this.messageCallbacks.push(callback);
  }

  onStatusChange(callback: (connected: boolean) => void): void {
    this.statusCallbacks.push(callback);
  }

  private notifyMessageReceived(message: MessageModel): void {
    this.messageCallbacks.forEach((callback) => {
      callback(message);
    });
  }

  private notifyStatusChange(connected: boolean): void {
    this.statusCallbacks.forEach((callback) => {
      callback(connected);
    });
  }

  isConnected(): boolean {
    return this.isMockConnected;
  }
}
