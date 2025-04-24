import { window } from '@kit.ArkUI';
import { Constants } from '../constants/Constants';

export class BrightnessUtil {
  private static readonly DEFAULT_BRIGHTNESS: number = -1;
  private static readonly HIGH_BRIGHTNESS: number = 1;
  private static windowClass: window.Window | undefined = undefined;

  /**
   * init windowClass
   *
   * @param windowClass Window object
   */
  public static initWindow(windowClass: window.Window) {
    BrightnessUtil.windowClass = windowClass;
  }

  public static setBrightness(setMode: number): void {
    if (setMode === Constants.SET_BRIGHTNESS_SLIDE) {
      BrightnessUtil.windowClass?.setWindowBrightness(BrightnessUtil.HIGH_BRIGHTNESS);
    } else {
      BrightnessUtil.windowClass?.setWindowBrightness(BrightnessUtil.DEFAULT_BRIGHTNESS);
    }
  }
}