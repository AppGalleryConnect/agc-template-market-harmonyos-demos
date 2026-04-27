import { display } from '@kit.ArkUI';

export class DisplayUtil {
  private constructor() {
  }

  // 获取默认的display对象
  static getDefaultDisplaySync(): display.Display {
    return display.getDefaultDisplaySync();
  }

  // 获取设备的屏幕宽度
  static getWidth(): number {
    return DisplayUtil.getDefaultDisplaySync().width;
  }

  // 获取设备的屏幕高度
  static getHeight(): number {
    return DisplayUtil.getDefaultDisplaySync().height;
  }
}