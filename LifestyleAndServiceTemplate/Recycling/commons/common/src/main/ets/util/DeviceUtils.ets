import deviceInfo from '@ohos.deviceInfo';
import { display } from '@kit.ArkUI';

/**
 * 设备判断工具类
 */
export class DeviceUtils {
  /**
   * 小屏设备：直板机、大折叠屏折叠态、小折叠展开态
   * @returns
   */
  static isSmallScreen(uiContext: UIContext): boolean {
    return DeviceUtils.isSmallPortrait(uiContext) || DeviceUtils.isMediumLandscape(uiContext)
  }

  /**
   * 小方屏（pura x）
   * @returns
   */
  static isSmallSquare(uiContext: UIContext): boolean {
    let widthBreakpoint: WidthBreakpoint = uiContext.getWindowWidthBreakpoint()
    let heightBreakpoint: HeightBreakpoint = uiContext.getWindowHeightBreakpoint()
    return widthBreakpoint === WidthBreakpoint.WIDTH_SM && heightBreakpoint === HeightBreakpoint.HEIGHT_LG
  }

  /**
   * 双折叠手机展开态
   * @returns
   */
  static isMediumSquare(uiContext: UIContext): boolean {
    if ((deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'default')) {
      try {
        if (canIUse('SystemCapability.Window.SessionManager')) {
          if (!display.isFoldable()) {
            // 直板机，false
            return false;
          }
        }
      } catch (e) {
      }
    }
    let widthBreakpoint: WidthBreakpoint = uiContext.getWindowWidthBreakpoint()
    let heightBreakpoint: HeightBreakpoint = uiContext.getWindowHeightBreakpoint()
    return widthBreakpoint === WidthBreakpoint.WIDTH_MD && heightBreakpoint === HeightBreakpoint.HEIGHT_MD
  }

  /**
   * 直板竖向: 手机(竖向)、大折叠屏(折叠态竖向)、小折叠屏(展开态竖向)
   * @returns
   */
  private static isSmallPortrait(uiContext: UIContext): boolean {
    let widthBreakpoint: WidthBreakpoint = uiContext.getWindowWidthBreakpoint()
    let heightBreakpoint: HeightBreakpoint = uiContext.getWindowHeightBreakpoint()
    return widthBreakpoint === WidthBreakpoint.WIDTH_SM && heightBreakpoint === HeightBreakpoint.HEIGHT_LG
  }

  /**
   * 直板横向:手机(横向)、大折叠屏折叠态(横向)、小折叠屏展开态(横向)
   * @returns
   */
  private static isMediumLandscape(uiContext: UIContext): boolean {
    let widthBreakpoint: WidthBreakpoint = uiContext.getWindowWidthBreakpoint()
    let heightBreakpoint: HeightBreakpoint = uiContext.getWindowHeightBreakpoint()
    if ((deviceInfo.deviceType === 'phone' || deviceInfo.deviceType === 'default')) {
      try {
        if (canIUse('SystemCapability.Window.SessionManager')) {
          if (display.isFoldable()) {
            // 折叠屏，折叠状态，只支持Medium
            if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
              return DeviceUtils.filterMediumBreakpoint(widthBreakpoint) &&
                heightBreakpoint === HeightBreakpoint.HEIGHT_SM;
            }
          } else {
            // 直板机，只支持Medium
            return DeviceUtils.filterMediumBreakpoint(widthBreakpoint) &&
              heightBreakpoint === HeightBreakpoint.HEIGHT_SM;
          }
        }
      } catch (e) {
      }
    }
    return widthBreakpoint === WidthBreakpoint.WIDTH_MD && heightBreakpoint === HeightBreakpoint.HEIGHT_SM
  }

  /**
   * 直板机判断中等屏幕，直接将大屏也算里，拦截大屏等的断点。默认直板机最大是Medium
   */
  private static filterMediumBreakpoint(widthtBreakpoint: WidthBreakpoint): boolean {
    return ([WidthBreakpoint.WIDTH_MD, WidthBreakpoint.WIDTH_LG, WidthBreakpoint.WIDTH_XL].includes(widthtBreakpoint));
  }
}