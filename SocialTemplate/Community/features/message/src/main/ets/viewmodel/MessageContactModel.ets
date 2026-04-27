import { CMChatFriendInfo } from 'instant_messaging';

@ObservedV2
export class MessageContactModel extends CMChatFriendInfo {
  @Trace isSelect: boolean = false;
  @Trace isChange: boolean = true;
}