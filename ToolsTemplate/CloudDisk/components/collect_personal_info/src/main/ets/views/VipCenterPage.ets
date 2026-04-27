import { VipCenter } from 'vip_center'
import { PersistenceV2, promptAction } from '@kit.ArkUI'
import { UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';

/**
 * @usage: 用于展示VIP中心页面容器。提供VIP会员中心的页面包装和用户信息传递功能。
 * 关键数据结构包括UserInfo（用户信息模型，支持PersistenceV2持久化，包含nickName昵称、isVip是否为VIP等字段）。
 * 页面通过VipCenter组件展示VIP会员中心内容，并在VIP开通成功后更新用户VIP状态。
 * @layout: 页面采用OHPage容器布局，内部渲染VipCenter组件，传入用户名userName、头像avatar（空字符串）、
 * 路由模块routerModule和VIP开通回调onVipOpen。
 * @constraints: UserInfo使用PersistenceV2持久化存储不可修改；VIP开通成功后会将userInfo.isVip设置为true并显示"兑换成功"提示；
 * 路由模块通过phoneRouterControl.getRouter()获取。
 * @isGen: true
 * @fileType: page
 * @zhName: VIP中心页面
 * @component: OHPage,VipCenter
 */
// vip中心
@ComponentV2
struct VipCenterPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  @Builder
  render() {
    VipCenter({
      userName: this.userInfo.nickName,
      avatar: (this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl : $r('app.media.path2x'),
      routerModule: phoneRouterControl.getRouter(),
      vipType: 'month', // todo 需根据实际开发的vip类型传入
      onVipOpen: () => {
        this.userInfo.isVip = true
        promptAction.showToast({ message: '兑换成功' })
      }
    })
  }
}

@Builder
export function VipCenterPageBuilder() {
  VipCenterPage()
}
