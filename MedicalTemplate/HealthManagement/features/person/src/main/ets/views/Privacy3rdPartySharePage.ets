import { CommonHeader, ProtocolWebView, BarVM } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { thirdPartyInfo } from '../constants/Constants';

@Builder
export function Privacy3rdPartySharePageBuilder() {
  Privacy3rdPartySharePage();
}


@ComponentV2
export struct Privacy3rdPartySharePage {
  // 页面内容渲染
  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.person_third_party_list_title'),
      onReturnClick: () => {
        phoneRouterControl.popPage();
      },
      leftImageRes: $r('app.media.ic_backward2')
    })

    ProtocolWebView({ content: thirdPartyInfo })
      .padding({ bottom: BarVM.instance.aiBarH })
      .layoutWeight(1)
      .width('100%')
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