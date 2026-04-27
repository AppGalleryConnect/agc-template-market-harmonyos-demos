/**
 * 发帖Span
 */
export interface TextSpanInfo {
  text: string; // 文本内容
  type: 'topic' | 'contact' | 'default'; // 类型
}