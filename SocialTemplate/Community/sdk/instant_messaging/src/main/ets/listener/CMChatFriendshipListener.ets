import { CMChatFriendInfo } from '../viewmodels/CMChatGroupMemberInfo';

/**
 * 好友关系监听链
 */
export interface CMChatFriendshipListener {
  /**
   * 好友新增通知
   */
  onFriendListAdded?: (userIDList: CMChatFriendInfo[]) => void;
  /**
   * 好友删除通知，，两种情况会收到这个回调：
   * 1. 自己删除好友（单向和双向删除都会收到回调）
   * 2. 好友把自己删除（双向删除会收到）
   */
  onFriendListDeleted?: (userIDList: string[]) => void;
  /**
   * 黑名单新增通知
   */
  onBlackListAdded?: (infoList: CMChatFriendInfo[]) => void;
  /**
   * 黑名单删除通知
   */
  onBlackListDeleted?: (userIDList: string[]) => void;
  /**
   * 好友资料更新通知
   */
  onFriendInfoChanged?: (infoList: CMChatFriendInfo[]) => void;
}