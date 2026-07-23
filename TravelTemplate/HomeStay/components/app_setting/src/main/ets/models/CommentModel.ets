/**
 * 评论弹窗模型
 * */
export interface CommentDialogConfig {
  // 间隔天数，默认3天
  intervalDays?: number;

  // 是否强制弹出
  forceShow?: boolean;
}