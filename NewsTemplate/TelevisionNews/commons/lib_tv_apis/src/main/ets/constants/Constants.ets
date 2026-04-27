/**
 * 新闻类型
 */
export enum NewsEnum {
  /**
   * 文章
   */
  Article = 0,
  /**
   * 视频
   */
  Video,
  /**
   * 动态
   */
  Post,
  /**
   * 广播
   */
  Broadcast,
  /**
   * 电视
   */
  Television
}

/**
 * 视频类型
 */
export enum VideoEnum {
  /**
   * 竖屏
   */
  Portrait = 0,
  /**
   * 横屏
   */
  Landscape,
}

/**
 * 聊天内容枚举
 */
export enum ChatEnum {
  /**
   * 文本
   */
  Text = 'text',
  /**
   * 图片
   */
  Image = 'image',
  /**
   * 时间
   */
  Time = 'time',
}
