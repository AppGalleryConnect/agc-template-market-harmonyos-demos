import { CMChatMessage } from '../viewmodels/CMChatMessage';
/**
 * 高级消息监听器
 */
export interface CMChatAdvanceMsgListener {
  /**
   * 收到新消息
   *
   * @param message 消息
   */
  onRecvNewMessage?: (message: CMChatMessage) => void;
}