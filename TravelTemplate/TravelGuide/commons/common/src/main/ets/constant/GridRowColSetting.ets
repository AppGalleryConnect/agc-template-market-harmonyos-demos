import { GlobalContext } from '../basic/GlobalContext';
import { DeviceUtils } from '../util/DeviceUtils';

/**
 * 断点名称
 */
export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

/**
 * 断点取值
 */
export enum BreakpointValueEnum {
  SM = '600vp',
  MD = '840vp',
  LG = '1440vp',
}

/**
 * 栅格通用设置
 */
export class GridRowColSetting {
  /**
   * 栅格布局-margin
   */
  public static readonly GRID_ROW_OPTIONS_MARGIN: GridRowColumnOption = {
    sm: 16,
    md: 24,
    lg: 32,
    xl: 32,
  };

  /**
   * 获取页面margin
   * @param bp
   * @returns
   */
  public static getPageMargin(bp: BreakpointNameEnum): number {
    // Reflect.get(GridRowColSetting.GRID_ROW_OPTIONS_MARGIN, bp),
    // 针对部分手机机型会报错：Error message:Reflect.has target is not object
    return GridRowColSetting.GRID_ROW_OPTIONS_MARGIN[bp] ?? 16
  }

  /**
   * 根据栅格化动态是否为折叠屏
   */
  public static checkColumnCountModel(): boolean {
    let uiContext = GlobalContext.getUIContext()
    if (DeviceUtils.isSmallScreen(uiContext) && !DeviceUtils.isSmallSquare(uiContext)) {
      // 非阔折叠的直板设备
      return false
    }
    if (DeviceUtils.isSmallScreen(uiContext) && DeviceUtils.isSmallSquare(uiContext)) {
      // 阔折叠的直板设备
      return false
    }
    if (DeviceUtils.isMediumSquare(uiContext)) {
      // 折叠屏展开态
      return true
    }
    return false
  }

  /**
   * 根据栅格化动态获取列表数量
   * @returns
   */
  public static getColumnCount(): number {
    let uiContext = GlobalContext.getUIContext()
    if (DeviceUtils.isSmallScreen(uiContext) && !DeviceUtils.isSmallSquare(uiContext)) {
      // 非阔折叠的直板设备
      return 2
    }
    if (DeviceUtils.isSmallScreen(uiContext) && DeviceUtils.isSmallSquare(uiContext)) {
      // 阔折叠的直板设备
      return 4
    }
    if (DeviceUtils.isMediumSquare(uiContext)) {
      // 折叠屏展开态
      return 6
    }
    return 2
  }
}
