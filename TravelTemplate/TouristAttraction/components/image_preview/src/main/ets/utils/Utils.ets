import { componentUtils, ComponentUtils } from '@kit.ArkUI'
import { UtilLog } from '@hw-agconnect/util-log'
import { ComInfoType, SourceImageModel } from '../models/PreviewModel'

export class PreviewUtils {
  /**
   * 获取组件信息
   * @param {context} UIContext
   * @param {key} 组件id
   * */
  public static getComponentsInfo = (context: UIContext, key: string): ComInfoType | undefined => {
    try {
      let comUtils: ComponentUtils = context.getComponentUtils()
      let info: componentUtils.ComponentInfo = comUtils.getRectangleById(key)
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
    } catch (e) {
      UtilLog.error('getComponentsInfo fail, error: ' + JSON.stringify(e));
      return undefined;
    }
  }
  /**
   * 获取区间值
   */
  public static clamp = (num: number, min: number, max: number): number => Math.min(Math.max(num, min), max)

  /**
   * 判断是否是动图
   * 动图暂不支持PixelMap | Resource | DrawableDescriptor
   */
  public static isMovingPhoto(imageSrc: SourceImageModel) {
    return (imageSrc.videoUrl || imageSrc.movingPhoto) && typeof imageSrc.imageUrl === 'string'
  }

  /**
   * 判断是否是动图
   * 动图来源是沙箱还是云侧接口
   */
  public static isMovingPhotoFromSandbox(imageSrc: SourceImageModel) {
    return imageSrc.movingPhoto || (imageSrc.videoUrl?.startsWith('file://') && imageSrc.imageUrl)
  }
}

