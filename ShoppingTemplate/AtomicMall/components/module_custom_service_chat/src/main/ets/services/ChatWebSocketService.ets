import { BusinessError } from '@kit.BasicServicesKit';
import webSocket from '@ohos.net.webSocket';
import { Logger } from 'module_ui_base';
import { BaseChatService } from '../models/BaseChatModel';
import { MessageData, MessageModel, MessageType, SenderType } from '../models/MessageModel';

/**
 * todo: 实现真实的websocket对话类
 */
export class ChatWebSocketService extends BaseChatService {
  private webSocket: webSocket.WebSocket | null = null;
  private messageCallbacks: ((message: MessageModel) => void)[] = [];
  private statusCallbacks: ((connected: boolean) => void)[] = [];
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectInterval = 3000;

  // 连接WebSocket服务器
  async connect(serverUrl: string): Promise<boolean> {
    try {
      this.webSocket = webSocket.createWebSocket();

      // 注册事件监听器
      this.webSocket.on('open', () => {
        console.info('WebSocket连接已建立');
        this.reconnectAttempts = 0;
        this.notifyStatusChange(true);
      });

      this.webSocket.on(
        'message',
        (err: BusinessError, value: string | ArrayBuffer) => {
          if (err) {
            return;
          }
          console.info('on message, message:' + value);
          // 当收到服务器的`bye`消息时（此消息字段仅为示意，具体字段需要与服务器协商），主动断开连接。
          if (value === 'bye') {
            this.webSocket!.close((err: BusinessError) => {
              if (!err) {
                console.info('Connection closed successfully');
              } else {
                console.error(
                  'Failed to close the connection. Err: ' + JSON.stringify(err),
                );
              }
            });
          } else {
            this.handleMessage(value as string);
          }
        },
      );

      this.webSocket.on('close', () => {
        console.info('WebSocket连接已关闭');
        this.notifyStatusChange(false);
        this.attemptReconnect(serverUrl);
      });

      this.webSocket.on('error', (err: Error) => {
        console.error('WebSocket错误:', err.message);
        this.notifyStatusChange(false);
      });

      // 连接到服务器
      await this.webSocket.connect(serverUrl);
      return true;
    } catch (error) {
      console.error('WebSocket连接失败:', error.message);
      this.notifyStatusChange(false);
      return false;
    }
  }

  // 发送消息
  async sendMessage(
    content: string,
    type: MessageType = MessageType.TEXT,
  ): Promise<boolean> {
    if (!this.webSocket) {
      console.error('WebSocket未连接');
      return false;
    }

    try {
      const messageData: MessageData = {
        type: type,
        content: content,
        timestamp: Date.now(),
      };

      await this.webSocket.send(JSON.stringify(messageData));
      return true;
    } catch (error) {
      console.error('发送消息失败:', error.message);
      return false;
    }
  }

  // 处理接收到的消息
  private handleMessage(data: string): void {
    try {
      const messageData = JSON.parse(data) as MessageModel;
      const message = new MessageModel(
        messageData.content,
        messageData.type,
        SenderType.CUSTOMER_SERVICE,
      );

      this.notifyMessageReceived(message);
    } catch (error) {
      console.error('解析消息失败:', error.message);
    }
  }

  // 断开连接
  disconnect(): void {
    if (this.webSocket) {
      this.webSocket.close().catch((err: BusinessError) => {
        Logger.error('close websocket failed. error: ' + JSON.stringify(err));
      });
      this.webSocket = null;
    }
  }

  // 尝试重新连接
  private attemptReconnect(serverUrl: string): void {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++;
      console.info(
        `尝试重新连接 (${this.reconnectAttempts}/${this.maxReconnectAttempts})`,
      );

      setTimeout(() => {
        this.connect(serverUrl);
      }, this.reconnectInterval);
    }
  }

  // 注册消息接收回调
  onMessageReceived(callback: (message: MessageModel) => void): void {
    this.messageCallbacks.push(callback);
  }

  // 注册状态变化回调
  onStatusChange(callback: (connected: boolean) => void): void {
    this.statusCallbacks.push(callback);
  }

  // 通知消息接收
  private notifyMessageReceived(message: MessageModel): void {
    this.messageCallbacks.forEach((callback) => {
      callback(message);
    });
  }

  // 通知状态变化
  private notifyStatusChange(connected: boolean): void {
    this.statusCallbacks.forEach((callback) => {
      callback(connected);
    });
  }

  // 检查连接状态
  isConnected(): boolean {
    return this.webSocket !== null;
  }
}
