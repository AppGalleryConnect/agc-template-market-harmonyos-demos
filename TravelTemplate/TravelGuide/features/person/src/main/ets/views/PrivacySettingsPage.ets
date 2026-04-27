import { ProtocolRouterParams, ProtocolWebViewBuilder } from 'aggregated_login';
import { BarVM, BreakpointModel, CommonHeader, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { Privacy3rdPartySharePageBuilder } from './Privacy3rdPartySharePage';
import { PrivacyInfoCollectPageBuilder } from './PrivacyInfoCollectPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { ProtocolData } from './LoginPage';
import { GenericCard } from '../comp/GenericCard';

@ComponentV2
export struct PrivacySettingsPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 12, right: 12 })
  }

  build() {
    NavDestination() {
      Column() {
        CommonHeader({
          title: '隐私设置',
          onReturnClick: () => {
            phoneRouterControl.popPage();
          },
        })

        Column() {
          Column() {
            GenericCard() {
              UserInfoRow({
                leftTitle: '用户协议',
                rightOnClick: () => {
                  phoneRouterControl.jumpPage({
                    pageName: RouterMap.PROTOCOL_WEB_VIEW_NAME,
                    param: {
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
                    pageName: RouterMap.PROTOCOL_WEB_VIEW_NAME,
                    param: {
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
          .height(388)

        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width('100%')
        .height('100%')
        .backgroundColor($r('sys.color.comp_background_gray'))
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
    }
    .backgroundColor($r('sys.color.comp_background_gray'))
    .hideTitleBar(true)
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding,
      top: BarVM.instance.staBarH,
      bottom: BarVM.instance.aiBarH
    })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}

@Builder
export function PrivacySettingsPageBuilder() {
  PrivacySettingsPage()
}
