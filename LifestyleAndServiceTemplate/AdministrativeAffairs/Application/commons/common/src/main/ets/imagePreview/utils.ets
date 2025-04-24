import { componentUtils, ComponentUtils } from '@kit.ArkUI'

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
  return `${val}`
}

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
  let info: componentUtils.ComponentInfo = comUtils.getRectangleById(key)
  return {
    width: px2vp(info.size.width),
    height: px2vp(info.size.height),
    localLeft: px2vp(info.localOffset.x),
    localTop: px2vp(info.localOffset.y),
    screenLeft: px2vp(info.screenOffset.x),
    screenTop: px2vp(info.screenOffset.y),
    windowLeft: px2vp(info.windowOffset.x),
    windowTop: px2vp(info.windowOffset.y),
  }
}