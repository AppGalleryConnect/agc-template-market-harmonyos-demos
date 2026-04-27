import { VipCenter } from 'vip_center'
import { PersistenceV2, promptAction } from '@kit.ArkUI'
import { UserInfo } from 'common';

@Builder
export function VipCenterPageBuilder() {
  VipCenterPage()
}

/**
 * @usage: 用于展示VIP会员中心页面，提供会员权益展示和开通功能。
 * 关键参数：userName用户名称，avatar用户头像，onVipOpen会员开通回调。
 * @layout: 页面采用Navigation导航布局，内部嵌套VipCenter组件。
 * @constraints:
 * @zhName: VIP会员中心
 * @fileType: page
 * @isGen: true
 * @subPage:
 * @component: VipCenter
 */
@ComponentV2
export struct VipCenterPage {
  routerModule: NavPathStack = new NavPathStack()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  build() {
    NavDestination() {
      VipCenter({
        userName: this.userInfo.nickName,
        avatar: (this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl : $r('app.media.path2x'),
        routerModule: this.routerModule,
        onVipOpen: () => {
          promptAction.showToast({ message: '兑换成功' })
          this.userInfo.isVIP = true
        },
      })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
    })
    .onBackPressed(() => {
      this.routerModule.pop()
      return true
    })
  }
}
