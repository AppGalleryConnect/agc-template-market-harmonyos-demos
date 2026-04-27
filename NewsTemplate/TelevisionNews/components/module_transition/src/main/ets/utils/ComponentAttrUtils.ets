import { UIContext } from '@kit.ArkUI';

export class ComponentAttrUtils {
  // 根据组件的id获取组件的位置信息
  public static getRectInfoById(context: UIContext, id: string, cornerRadius: number): RectInfoPx | undefined {
    if (!context || !id) {
      return undefined;
    }
    let node = context.getAttachedFrameNodeById(id);
    if (!node) {
      return undefined;
    }

    let sizeValue = node.getMeasuredSize();
    let widthValue = sizeValue.width;
    let heightValue = sizeValue.height;
    if (widthValue === 0 || heightValue === 0) {
      return undefined;
    }

    let positionValue = node.getPositionToWindowWithTransform();
    let leftPosition = context.vp2px(positionValue.x);
    let topPosition = context.vp2px(positionValue.y);
    return {
      left: leftPosition,
      top: topPosition,
      width: widthValue,
      height: heightValue,
      cornerRadius: cornerRadius ?? 0
    }
  }
}

export class RectInfoPx {
  left: number = 0;
  top: number = 0;
  width: number = 0;
  height: number = 0;
  cornerRadius: number = 0;
}