import { BarVM } from '@agctemplate/widgets';
import { ProtocolWebView } from '../component/ProtocolWebView';

@Builder
export function Privacy3rdPartySharePageBuilder() {
  Privacy3rdPartySharePage();
}

@ComponentV2
export struct Privacy3rdPartySharePage {
  thirdPartyInfo: string = 'privacy.html'

  build() {
    NavDestination() {
      ProtocolWebView({ content: this.thirdPartyInfo })
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .hideTitleBar(true)
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
  }
}