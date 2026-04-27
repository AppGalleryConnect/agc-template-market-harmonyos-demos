import { CMChatGroupInfo } from 'instant_messaging';

@ObservedV2
export class MessageGroupInfoModel extends CMChatGroupInfo {
  @Trace count: number = 0; // 群内好友数量
  /**
   * 群成员头像二维列表
   */
  @Trace memberAvatarList: string[][] = [];
}