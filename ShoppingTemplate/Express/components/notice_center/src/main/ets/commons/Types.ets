export interface MessageGroup {
  type: number; // 1：系统消息； 2：物流消息； 3：活动推送； 4：客服消息
  title: string;
  icon: ResourceStr;
  latestContent: string;
  latestTime: number;
  unreadCount: number;
}

export interface MessageItem {
  id: string;
  type: number;
  title: string; // 消息标题
  content: string; // 消息内容
  timestamp: number; // 时间戳
  isRead: boolean; // 阅读状态
}
