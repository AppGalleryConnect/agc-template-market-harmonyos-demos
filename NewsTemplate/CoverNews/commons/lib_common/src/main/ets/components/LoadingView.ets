import { UIDialog } from '@hw-agconnect/ui-dialog';
import { CommonConstants } from '../constants/CommonConstants'

export interface LoadStyle {
  loadColor?: ResourceColor;
  textColor?: ResourceColor;
  maskColor?: ResourceColor;
  autoCancel?: boolean;
  text?: string;
}

@Builder
export function loadingView(style?: LoadStyle) {
  Column({ space: CommonConstants.SPACE_M }) {
    LoadingProgress()
      .width(72)
      .height(72)
      .color(style?.loadColor ?? $r('sys.color.icon_secondary'))
    Text(style?.text ?? '加载中')
      .fontColor(style?.textColor ?? $r('sys.color.font_secondary'))
      .textAlign(TextAlign.Center)
      .fontSize(16)
  }
  .width(150)
  .aspectRatio(1)
  .justifyContent(FlexAlign.Center)
  .borderRadius(12)
}

@Builder
export function loadingPage() {
  Column() {
    loadingView()
  }
  .layoutWeight(1)
  .justifyContent(FlexAlign.Center)
  .padding({
    bottom: 100,
  })
}

/**
 * 全局Loading弹窗打开关闭
 */
export class CommonLoadingDialog {
  /**
   * 打开loading
   */
  public static show(style?: LoadStyle) {
    UIDialog.open({
      contentBuilder: loadingView(style),
    })
  }

  /**
   * 关闭loading
   */
  public static close() {
    UIDialog.closeLast()
  }
}