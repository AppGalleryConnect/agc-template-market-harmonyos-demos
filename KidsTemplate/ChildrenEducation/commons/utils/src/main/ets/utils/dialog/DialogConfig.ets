import { common } from '@kit.AbilityKit';
import { CommonConstants } from '../../constants/CommonConstants';

export class DialogConfig {
  /**
   * 设置UIAbilityContext
   */
  uiAbilityContext?: common.UIAbilityContext;
  /**
   * 显示时长(1500ms-10000ms)
   */
  toastDuration: number = 2000;
  /**
   * 文字颜色
   */
  toastFontColor: ResourceColor = Color.White;
  /**
   * 背景颜色，建议八位色值前两位为透明度
   */
  toastBackgroundColor: ResourceColor = '#CC000000';
  toastAlignment: Alignment | undefined = undefined;
  /**
   * 弹窗的对齐方式。
   */
  alignment: DialogAlignment = DialogAlignment.Center;
  /**
   * 弹窗相对alignment所在位置的偏移量。默认值：{ dx: 0 , dy: 0 }
   */
  offset: Offset = { dx: 0, dy: 0 };
  /**
   * 弹窗遮蔽层区域，在遮蔽层区域内的事件不透传，在遮蔽层区域外的事件透传。
   */
  maskRect: Rectangle = {
    x: 0,
    y: 0,
    width: CommonConstants.FULL_PERCENT,
    height: CommonConstants.FULL_PERCENT,
  };
  /**
   * 弹窗背板颜色。默认值：Color.Transparent
   */
  backgroundColor: ResourceColor = Color.Transparent;
  /**
   * 弹窗背板模糊材质。默认值：BlurStyle.COMPONENT_ULTRA_THICK
   */
  backgroundBlurStyle: BlurStyle = BlurStyle.COMPONENT_ULTRA_THICK;
  /**
   * 设置弹窗背板的阴影
   */
  shadow?: ShadowOptions | ShadowStyle;
}