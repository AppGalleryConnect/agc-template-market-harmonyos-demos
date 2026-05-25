/**
 * 分享方式
 */
export enum ShareAppType {
  WECHAT_SESSION = 'wechat_session',
  WECHAT_TIMELINE = 'wechat_timeline',
  QQ = 'qq',
  WEIBO = 'weibo',
}

/**
 * 分享操作
 */
export enum ShareWay {
  POSTER = 'create_poster',
  COPY_TO_PASTEBOARD = 'copy_to_pasteboard',
  SYSTEM = 'system_share',
  SAVE_TO_ALBUM = 'save_to_album',
}