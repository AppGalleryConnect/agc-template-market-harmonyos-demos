import { CommonHeader, TCLogger } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';

@Builder
export function PairHelpPageBuilder() {
  PairHelpPage()
}

const TAG = 'PairHelpPage';

/**
 * @usage: 设备配对帮助页面，提供设备配对失败时的帮助信息和解决方案。展示设备离线处理方法和重新连接指导，帮助用户解决设备配对问题。
 * 包含帮助文本展示和重新连接操作。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，中间为帮助内容区域包含多个Text组件展示帮助信息，底部为重新连接按钮。
 * 所有内容垂直排列，文本左右边距24。
 * @constraints:
 * @isGen: true
 * @fileType: page
 * @zhName: 配对帮助页面
 * @component:CommonHeader
 */
@ComponentV2
export struct PairHelpPage {
  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: $r('app.string.pair_help_title'),
        onReturnClick: () => {
          phoneRouterControl.popPage()
        },
        leftImageRes: $r('app.media.ic_backward2')
      })

      Blank().height($r('app.float.vp_12'))

      Text($r('app.string.pair_help_offline_tip'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.Black)

      Blank().height($r('app.float.vp_12'))

      Text($r('app.string.pair_help_offline'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.color_666'))
        .maxLines(3)
        .lineHeight($r('app.float.vp_20'))

      Blank().height($r('app.float.vp_30'))

      Text($r('app.string.pair_help_again_tip'))
        .fontSize($r('sys.float.Body_L'))
        .fontColor(Color.Black)

      Blank().height($r('app.float.vp_12'))

      Text($r('app.string.pair_help_again'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('app.color.color_666'))
        .maxLines(3)
        .lineHeight($r('app.float.vp_20'))

      Blank().height($r('app.float.vp_50'))

      Button($r('app.string.pair_help_again_connect'))
        .width('100%')
        .height($r('app.float.vp_40'))
        .fontColor($r('sys.color.font_emphasize'))
        .fontSize($r('sys.float.Body_L'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor($r('app.color.color_14117CFF'))
        .onClick(() => {
          TCLogger.info(TAG, `on confirm`);
          phoneRouterControl.popPage()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('app.color.color_F1F3F5'))
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }
}
