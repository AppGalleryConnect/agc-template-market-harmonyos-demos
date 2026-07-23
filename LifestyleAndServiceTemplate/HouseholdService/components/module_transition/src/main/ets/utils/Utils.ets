import { componentUtils, ComponentUtils, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';

const TAG = '[TransitionUtils]'
const DOMAIN = 0xFF00

/**
 * 组件信息类型
 */
export interface ComInfoType {
  width: number
  height: number
  localLeft: number
  localTop: number
  screenLeft: number
  screenTop: number
  windowTop: number
  windowLeft: number
}

/**
 * 获取组件信息
 * @param {context} UIContext
 * @param {key} 组件id
 * */
export const getComponentsInfo = (context: UIContext, key: string): ComInfoType => {
  let comUtils: ComponentUtils = context.getComponentUtils()
  try {
    const info: componentUtils.ComponentInfo = comUtils.getRectangleById(key)
    return {
      width: context.px2vp(info.size.width),
      height: context.px2vp(info.size.height),
      localLeft: context.px2vp(info.localOffset.x),
      localTop: context.px2vp(info.localOffset.y),
      screenLeft: context.px2vp(info.screenOffset.x),
      screenTop: context.px2vp(info.screenOffset.y),
      windowLeft: context.px2vp(info.windowOffset.x),
      windowTop: context.px2vp(info.windowOffset.y),
    }
  } catch (error) {
    UtilLog.error(TAG, `getRectangleById failed, key: ${key}, error: ${JSON.stringify(error)}`)
    return {
      width: 0,
      height: 0,
      localLeft: 0,
      localTop: 0,
      screenLeft: 0,
      screenTop: 0,
      windowLeft: 0,
      windowTop: 0,
    }
  }
}

/**
 * 获取区间值
 */
export const clamp = (num: number, min: number, max: number): number => Math.min(Math.max(num, min), max)


/**
 * 根据类型和单位拼接尺寸 用于组件尺寸类属性格式化
 */
export function getSizeByUnit(val: string | number, isFont?: boolean): string {
  if (typeof val === 'string') {
    return val
  }
  let unit = 'vp'
  return `${val}${unit}`
}

/**
 * 设置顶部状态栏颜色
 */
export function setWindowSystemBarProp(properties: window.SystemBarProperties) {
  const windowStage = AppStorage.get('windowStage') as window.WindowStage;
  try {
    const windowClass = windowStage.getMainWindowSync()
    windowClass.setWindowSystemBarProperties(properties).catch((error: BusinessError) => {
      UtilLog.error(TAG, `setWindowSystemBarProperties failed, code: ${error.code}, message: ${error.message}`);
    })
  } catch (error) {
    UtilLog.error(TAG, `setWindowSystemBarProp failed, code: ${(error).code}, message: ${(error).message}`);
  }
}