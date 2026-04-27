import { CommonHeader, ProtocolWebView, BarVM } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { personalInfoCollection } from '../constants/Constants';

@Builder
export function PrivacyInfoCollectPageBuilder() {
  PrivacyInfoCollectPage();
}


@ComponentV2
export struct PrivacyInfoCollectPage {
  // 页面内容渲染
  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.person_personal_information_collection_title'),
      onReturnClick: () => {
        phoneRouterControl.popPage();
      },
      leftImageRes: $r('app.media.ic_backward2')
    })

    ProtocolWebView({ content: personalInfoCollection })
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