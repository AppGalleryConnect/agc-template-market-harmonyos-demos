import { VipCenter } from 'vip_center'
import { PersistenceV2, AppStorageV2 } from '@kit.ArkUI'
import { BarVM, UserInfo, RouterMap } from 'common'
import { phoneRouterControl } from 'oh_router'
import { LoginPageBuilder, LoginRedirectFlag } from './LoginPage'
import { emitter } from '@kit.BasicServicesKit'

/**
 * @usage: VIP会员中心页面，展示会员权益和开通/兑换会员功能。支持会员状态更新和事件通知。
 * 主要数据结构包括UserInfo（用户信息）。包含if逻辑判断登录状态，未登录跳转登录页。
 * @layout: 页面采用NavDestination导航目的地，内部Column垂直布局包含VipCenter会员中心组件。
 * @constraints: 需要登录后才能访问
 * @domain: 翻译工具
 * @fileType: page
 * @isGen: true
 * @zhName: VIP会员中心页面
 * @subPage: LoginPage
 * @component: VipCenter
 * @image: screenshot/person/VipCenterPage.jpg
 */
@Builder
export function VipCenterPageBuilder() {
  VipCenterPage()
}

@ComponentV2
export struct VipCenterPage {
  routerModule: NavPathStack = new NavPathStack()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!

  build() {
    NavDestination() {
      Column() {
        VipCenter({
          userName: this.userInfo.nickName || '华为用户',
          avatar: this.userInfo.avatarUrl as string || '',
          isVip: this.userInfo.isVip,
          statusBarHeight: BarVM.instance.staBarH,
          routerModule: this.routerModule,
          onVerifyNow: () => {
            try {
              // 兑换会员成功，更新VIP状态
              this.userInfo.isVip = true;
              // 发送VIP状态变更事件
              emitter.emit({ eventId: 10001 }, { data: { isVip: true } });
            } catch (err) {
            }
          },
          onVipOpen: () => {
            try {
              // 付款开通会员成功，更新VIP状态
              this.userInfo.isVip = true;
              // 发送VIP状态变更事件
              emitter.emit({ eventId: 10001 }, { data: { isVip: true } });
            } catch (err) {
            }
          },
        })
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;

      // 检查登录状态,如果未登录则跳转到登录页
      if (!this.userInfo.isLogin) {
        // 先pop当前VIP中心页面
        this.routerModule.pop();
        // 设置全局标志,登录后跳转到VIP中心
        const flag = AppStorageV2.connect(LoginRedirectFlag, () => new LoginRedirectFlag())!;
        flag.redirectToVip = true;
        // 跳转到登录页
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        });
      }
    })
    .onBackPressed(() => {
      this.routerModule.pop('back')
      return true
    })
  }
}
