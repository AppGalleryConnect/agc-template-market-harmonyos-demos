/**
 * 话题数据模型
 */
export interface Topic {
  id: string
  title: string
}

/**
 * 用户数据模型
 */
export interface User {
  authorId: string
  authorNickName: string
  authorIcon: string
}

/**
 * 文本片段信息接口
 */
export interface TextSpanInfo {
  text: string; // 文本内容
  start?: number; // 起始位置
  end?: number; // 结束位置
  type: 'topic' | 'contact' | 'default'; // 类型
}
