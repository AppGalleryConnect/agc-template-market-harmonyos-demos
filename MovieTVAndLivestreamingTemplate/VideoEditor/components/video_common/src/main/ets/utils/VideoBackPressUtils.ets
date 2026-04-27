export class VideoBackPressUtils {
  /**
   * 返回按键操作
   */
  private static onBackPress: Array<(() => boolean)> = []

  static addBackPressCb(cb: (() => boolean)) {
    VideoBackPressUtils.onBackPress.push(cb)
  }

  static removeBackPressCb(cb: (() => boolean)) {
    VideoBackPressUtils.onBackPress.filter((item, index) => item !== cb);
  }

  static clickBack(): boolean {
    if (!!VideoBackPressUtils.onBackPress) {
      let len = VideoBackPressUtils.onBackPress.length;
      for (let i = 0; i < len; i++) {
        let item = VideoBackPressUtils.onBackPress[i];
        let res = item()
        if (!!res) {
          return res
        }
      }
      return false
    } else {
      return false
    }
  }
}