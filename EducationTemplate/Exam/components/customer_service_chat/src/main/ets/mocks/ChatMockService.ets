import { AppStorageV2 } from '@kit.ArkUI';
import { MessageHistoryModel, MessageModel, MessageStatus, MessageType, SenderType } from '../models/MessageModel';
import { ChatUtil } from '../utils/ChatUtil';

// todo: 当前为纯端数据mock，请实现真实的对话类
export class ChatMockService {
  private messageCallbacks: ((message: MessageModel) => void)[] = [];
  private statusCallbacks: ((connected: boolean) => void)[] = [];
  private isMockConnected = false;
  private responseTimer: number | null = null;
  private lastRequestTime = 0;
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
  private history = AppStorageV2.connect(MessageHistoryModel, () => new MessageHistoryModel())!;

  /**
   * 获取聊天记录
   */
  async queryHistoryMessage(): Promise<MessageModel[]> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve([...this.history.list]);
      }, 100)
    });
  }

  /**
   * 启动连接
   */
  async connect(): Promise<boolean> {
    return new Promise((resolve) => {
      setTimeout(() => {
        this.isMockConnected = true;
        this.notifyStatusChange(true);

        // 发送欢迎消息
        this._sendWelcomeMessage();
        resolve(true);
      }, 600);
    });
  }

  /**
   * 发送消息
   */
  async sendMessage(content: MessageModel): Promise<boolean> {
    // 时间戳过滤过期请求
    const requestTime = Date.now();
    this.lastRequestTime = requestTime;

    if (!this.isMockConnected) {
      content.status = MessageStatus.FAILED;
      this.history.list.push(content);
      return false;
    }
    this.history.list.push(content);

    // 清除之前的定时器
    if (this.responseTimer) {
      clearTimeout(this.responseTimer);
    }

    // 模拟网络延迟
    return new Promise((resolve) => {
      this.responseTimer = setTimeout(() => {
        resolve(true);
        if (requestTime === this.lastRequestTime) {
          this._generateResponse(content);
        }
      }, 600);
    });
  }

  /**
   * 断开连接
   */
  disconnect(): Promise<void> {
    return new Promise(() => {
      this.isMockConnected = false;
      if (this.responseTimer) {
        clearTimeout(this.responseTimer);
        this.responseTimer = null;
      }
      this.notifyStatusChange(false);
    })
  }

  /**
   * 注册消息接收回调
   */
  onMessageReceived(callback: (message: MessageModel) => void): void {
    this.messageCallbacks.push(callback);
  }

  /**
   * 注册状态变化回调
   */
  onStatusChange(callback: (connected: boolean) => void): void {
    this.statusCallbacks.push(callback);
  }

  /**
   * 判断当前是否连接
   */
  isConnected(): boolean {
    return this.isMockConnected;
  }

  /**
   * 通知消息接收
   */
  private notifyMessageReceived(message: MessageModel): void {
    this.messageCallbacks.forEach((callback) => {
      callback(message);
    });
  }

  /**
   * 通知状态变化
   */
  private notifyStatusChange(connected: boolean): void {
    this.statusCallbacks.forEach((callback) => {
      callback(connected);
    });
  }

  private _sendWelcomeMessage(): void {
    const welcomeMessage: MessageModel = {
      id: Date.now().toString(),
      content: '您好！我是客服小助手，请问有什么可以帮您？',
      type: MessageType.TEXT,
      timestamp: Date.now(),
      isShowTime: true,
      sender: SenderType.CUSTOMER_SERVICE,
    };
    welcomeMessage.isShowTime = ChatUtil.setDisplayTime(welcomeMessage, this.history.list)
    this.history.list.push(welcomeMessage);

    this.notifyMessageReceived(welcomeMessage);
  }

  // 生成智能回复
  private _generateResponse(userMessage: MessageModel): void {
    let responseText = '';

    if (typeof userMessage.content === 'string') {
      // 查找匹配的回复模式
      for (const item of this.responseMap) {
        const pattern = item[0];
        const responses = item[1];
        if (pattern.test(userMessage.content.toLowerCase())) {
          responseText = responses[Math.floor(Math.random() * responses.length)];
          break;
        }
      }
    }

    // 如果没有匹配，使用默认回复
    if (!responseText) {
      responseText =
        this.defaultResponses[
        Math.floor(Math.random() * this.defaultResponses.length)
        ];
    }

    const responseMessage: MessageModel = {
      id: Date.now().toString(),
      content: responseText,
      type: MessageType.TEXT,
      timestamp: Date.now(),
      isShowTime: false,
      sender: SenderType.CUSTOMER_SERVICE,
    }
    responseMessage.isShowTime = ChatUtil.setDisplayTime(responseMessage, this.history.list)
    this.history.list.push(responseMessage);
    this.notifyMessageReceived(responseMessage);
  }
}
