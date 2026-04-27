import { ChatDataSource } from './ChatDataSource';
@ObservedV2
export class ChatViewVM{
  @Trace dataSource:ChatDataSource = new ChatDataSource()
  private static _instance: ChatViewVM;
  @Trace isShowTips = false

  public static get instance() {
    if (!ChatViewVM._instance) {
      ChatViewVM._instance = new ChatViewVM();
    }
    return ChatViewVM._instance;
  }
}