import { BarVM } from '@agctemplate/widgets';
import { ProtocolWebView } from '../component/ProtocolWebView';

@Builder
export function PrivacyInfoCollectPageBuilder() {
  PrivacyInfoCollectPage();
}

@ComponentV2
export struct PrivacyInfoCollectPage {
  personalInfoCollection: string = 'privacy2.html'

  build() {
    NavDestination(){
        ProtocolWebView({content:this.personalInfoCollection})
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .hideTitleBar(true)
    .padding({ top: BarVM.instance.staBarH, bottom: BarVM.instance.aiBarH })
  }
}