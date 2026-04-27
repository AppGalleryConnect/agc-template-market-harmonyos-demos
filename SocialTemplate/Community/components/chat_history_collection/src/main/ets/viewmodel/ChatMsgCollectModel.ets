import { ChatContentSingleModel } from 'chat_base';
import { CollectDataManager } from '../util/CollectDataManager';

@ObservedV2
export class ChatMsgCollectModel {
  @Trace msgCollectList: ChatContentSingleModel[] = [];

  constructor() {
    this.msgCollectList = CollectDataManager.getInstance()
      .getCollectData()
  }
}