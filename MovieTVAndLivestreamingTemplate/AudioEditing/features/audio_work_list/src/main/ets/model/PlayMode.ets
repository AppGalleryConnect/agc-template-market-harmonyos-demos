/**
 * 播放模式枚举
 */
export enum PlayMode {
  LIST_LOOP = 0,    // 列表循环
  SINGLE_LOOP = 1   // 单曲循环
}

/**
 * 获取播放模式文本
 */
export function getPlayModeText(mode: PlayMode): string {
  switch (mode) {
    case PlayMode.LIST_LOOP:
      return '列表循环'
    case PlayMode.SINGLE_LOOP:
      return '单曲循环'
    default:
      return '列表循环'
  }
}
