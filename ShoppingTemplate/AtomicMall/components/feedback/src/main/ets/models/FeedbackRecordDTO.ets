/**
 * Feedback Record Data Transfer Object (DTO)
 */
export interface FeedbackRecordDTO {
  id: string; // 唯一标识符
  description: string; // 问题描述
  images: string[]; // 图片列表
  createAt: number; // 创建时间（毫秒级时间戳）
}
