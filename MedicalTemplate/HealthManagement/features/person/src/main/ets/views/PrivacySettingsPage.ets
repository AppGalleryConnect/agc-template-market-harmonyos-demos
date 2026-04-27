import { window } from '@kit.ArkUI';
import { ProtocolData, ProtocolRouterParams, ProtocolWebViewBuilder, protocolWebViewName } from 'aggregated_login';
import { CommonHeader, RouterMap } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { GenericCard } from '../comp/GenericCard';
import { UserInfoRow } from '../comp/UserInfoRow';
import { Privacy3rdPartySharePageBuilder } from './Privacy3rdPartySharePage';
import { PrivacyInfoCollectPageBuilder } from './PrivacyInfoCollectPage';


@ComponentV2
export struct PrivacySettingsPage {
  @Local bottomHeight: number = 0;

  aboutToAppear(): void {
    try {
      window.getLastWindow(getContext(), (_err, data) => {
        const avoidAreaBottom = data.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
        this.bottomHeight = avoidAreaBottom.bottomRect.height;
      })
    } catch (err) {
    }
  }

  @Builder
  line() {
    Divider()
      .strokeWidth('1px')
      .width('100%')
      .color($r('sys.color.comp_divider'))
      .padding({ left: $r('app.float.vp_12'), right: $r('app.float.vp_12') })
  }

  // 页面内容渲染
  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.person_privacy_settings_title'),
      leftImageRes: $r('app.media.ic_backward2'),
      onReturnClick: () => {
        phoneRouterControl.popPage();
      },
    })

    Column() {
      GenericCard() {
        UserInfoRow({
          leftTitle: '用户协议',
          rightOnClick: () => {
            phoneRouterControl.jumpPage({
              pageName: protocolWebViewName,
              param : {
                content: ProtocolData.termOfServiceProtocol,
                isSheet: false,
              } as ProtocolRouterParams,
              builder: wrapBuilder(ProtocolWebViewBuilder)
            })
          }
        })
        this.line()
        UserInfoRow({
          leftTitle: '隐私政策',
          rightOnClick: () => {
            phoneRouterControl.jumpPage({
              pageName: protocolWebViewName,
              param : {
                content: ProtocolData.privacyProtocol,
                isSheet: false,
              } as ProtocolRouterParams,
              builder: wrapBuilder(ProtocolWebViewBuilder)
            })
          }
        })
      }

      GenericCard() {
        UserInfoRow({
          leftTitle: '第三方信息共享清单',
          rightOnClick: () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.PRIVACY_3RD_PARTY_SHARE_PAGE,
              builder: wrapBuilder(Privacy3rdPartySharePageBuilder)
            })
          }
        })
        this.line()
        UserInfoRow({
          leftTitle: '个人信息收集清单',
          rightOnClick: () => {
            phoneRouterControl.jumpPage({
              pageName: RouterMap.PRIVACY_INFO_COLLECT_PAGE,
              builder: wrapBuilder(PrivacyInfoCollectPageBuilder)
            })
          }
        })
      }
    }
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .layoutWeight(1)
    .padding({
      bottom: this.bottomHeight
    })
    .backgroundColor($r('sys.color.comp_background_gray'))
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

@Builder
export function PrivacySettingsPageBuilder() {
  PrivacySettingsPage()
}