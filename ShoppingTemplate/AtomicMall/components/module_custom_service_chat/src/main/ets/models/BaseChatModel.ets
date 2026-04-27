import { MessageModel, MessageType } from './MessageModel';

export abstract class BaseChatService {
  /**
   * 启动连接
   */
  abstract connect(serverUrl?: string): Promise<boolean>;

  /**
   * 发送消息
   */
  abstract sendMessage(content: string, type: MessageType): Promise<boolean>;

  /**
   * 断开连接
   */
  abstract disconnect(): void;

  /**
   * 注册消息接收回调
   */
  abstract onMessageReceived(callback: (message: MessageModel) => void): void;

  /**
   * 注册状态变化回调
   */
  abstract onStatusChange(callback: (connected: boolean) => void): void;

  /**
   * 判断当前是否连接
   */
  abstract isConnected(): boolean;
}
