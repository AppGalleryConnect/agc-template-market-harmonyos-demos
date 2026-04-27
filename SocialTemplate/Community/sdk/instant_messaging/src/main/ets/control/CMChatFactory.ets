import { CMChatBase } from './CMChatBase';
import { CMChatTencent } from './CMChatTencent';

export class CMChatFactory {
  /**
   * chatManager支持其他三方SDK构造，需要CMChatBase类的实现
   */
  private static chatManager: CMChatBase;

  public static get instance() {
    if (!CMChatFactory.chatManager) {
      CMChatFactory.chatManager = new CMChatTencent();
    }
    return CMChatFactory.chatManager;
  }
}