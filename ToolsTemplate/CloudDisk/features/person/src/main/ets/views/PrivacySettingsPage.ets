import { ProtocolRouterParams, ProtocolWebViewBuilder } from 'aggregated_login';
import { HeaderView, RouterMap, BreakpointModel } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { Privacy3rdPartySharePageBuilder } from './Privacy3rdPartySharePage';
import { PrivacyInfoCollectPageBuilder } from './PrivacyInfoCollectPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { ProtocolData } from './LoginPage';
import { GenericCard } from '../comp/GenericCard';

/**
 * @usage: 用于展示隐私设置页面。提供隐私相关协议和信息清单的查看入口，包括用户协议、隐私政策、第三方信息共享清单、
 * 个人信息收集清单等功能。关键数据结构包括BreakpointModel（断点模型，用于响应式布局的pagePadding）、
 * ProtocolRouterParams（协议路由参数，包含content内容和isSheet是否弹窗）、ProtocolData（协议数据，
 * 包含termOfServiceProtocol用户协议和privacyProtocol隐私政策）。
 * @layout: 页面采用Column垂直布局（间距12vp）。顶部是HeaderView导航栏（标题"隐私设置"和返回按钮，高度82vp，底部对齐），
 * 主体是GenericCard卡片容器（圆角16vp），包含4个UserInfoRow设置项（用户协议、隐私政策、第三方信息共享清单、
 * 个人信息收集清单），每项之间有Divider分割线（1px宽度，左右内边距16vp）。页面左右内边距使用breakPointModel.pagePadding。
 * @constraints: 用户协议和隐私政策内容从ProtocolData获取不可修改；
 * 用户协议和隐私政策跳转到ProtocolWebViewName协议网页视图页面；第三方信息共享清单跳转到PRIVACY_3RD_PARTY_SHARE_PAGE；
 * 个人信息收集清单跳转到PRIVACY_INFO_COLLECT_PAGE；BreakpointModel使用AppStorageV2连接实现响应式布局。
 * @isGen: true
 * @fileType: page
 * @zhName: 隐私设置页面
 * @subPage: ProtocolWebViewName,PRIVACY_3RD_PARTY_SHARE_PAGE,PRIVACY_INFO_COLLECT_PAGE
 * @component: OHPage,HeaderView,UserInfoRow,GenericCard
 */

@ComponentV2
export struct PrivacySettingsPage {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 16, right: 16 })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  @Builder
  render() {
    Column({ space: 12 }) {
      Column() {
        HeaderView({
          title: '隐私设置',
          clickBackBtn: () => {
            phoneRouterControl.popPage();
          }
        })
      }
      .height(82)
      .justifyContent(FlexAlign.End)
      .backgroundColor($r('app.color.white'))

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
          this.line()
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
      .padding({ left: this.breakPointModel.pagePadding, right: this.breakPointModel.pagePadding })
      .justifyContent(FlexAlign.SpaceBetween)
      .width('100%')
      .height('100%')
    }
    .backgroundColor($r('app.color.bg_color'))
  }
}

@Builder
export function PrivacySettingsPageBuilder() {
  PrivacySettingsPage()
}
