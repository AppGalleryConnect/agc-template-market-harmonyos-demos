/**
 * Feedback Submit Data Transfer Object (DTO)
 */
export interface FeedbackSubmitDTO {
  description: string;  // 问题描述
  images: string[];     // 图片列表（可能是 URL 或媒体文件 URI，实际提交前需要进行校验与转换）
  contact: string;      // 联系方式（邮箱/手机号）
}
