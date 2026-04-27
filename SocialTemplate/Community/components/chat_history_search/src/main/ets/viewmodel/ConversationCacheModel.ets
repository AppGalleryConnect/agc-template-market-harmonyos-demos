import { ChatContentSingleModel } from 'chat_base';

@ObservedV2
export class ConversationCacheModel {
  @Trace userId: string = '';
  @Trace groupID: string = '';
  @Trace conversationID: string = '';
  @Trace allCachedMsgList: ChatContentSingleModel[] = [];
}
