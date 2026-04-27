/**
 * @usage: VIP会员中心页面,用户从个人中心或音频编辑首页点击VIP相关入口后跳转到此页面。
 * 展示会员权益、套餐选择、会员开通等功能。支持查看会员权益、选择套餐(月卡/半年卡/终身卡)、
 * 开通/续费会员等操作。根据用户当前VIP等级显示不同的套餐推荐。
 * @layout: 页面采用NavDestination导航容器包裹VipCenter组件,展示用户信息(头像、昵称、VIP状态),
 * 中间为会员权益展示区域,下方为套餐选择卡片(月卡、半年卡、终身卡),底部为开通/续费按钮。
 * @constraints: 需要登录后才能访问。开通会员需要支付功能支持。
 * VIP用户可升级为超级VIP,超级VIP用户不需要再次开通。
 * @domain: 音频编辑
 * @zhName: VIP会员中心页面
 * @isGen: true
 * @fileType: page
 * @subPage: 
 * @component: VipCenter
 * @image: screenshots/person/vipCenter.jpg
 */
import { VipCenter, VipPackageItem } from 'vip_center'
import { PersistenceV2, promptAction } from '@kit.ArkUI'
import { UserInfo } from 'common';
import { phoneRouterControl } from 'oh_router';

@Builder
export function VipCenterPageBuilder() {
  VipCenterPage()
}

@ComponentV2
export struct VipCenterPage {
  routerModule: NavPathStack = new NavPathStack()
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local selectedDuration: string = '';

  build() {
    NavDestination() {
      VipCenter({
        userName: this.userInfo.nickName,
        avatar: (this.userInfo.avatarUrl !== '') ? this.userInfo.avatarUrl : $r('app.media.path2x'),
        routerModule: this.routerModule,
        isVip: this.userInfo.vipLevel > 0,
        vipType: this.userInfo.vipLevel === 1 ? 'month' : (this.userInfo.vipLevel === 2 ? 'perpetual' : ''),
        currentDuration: this.selectedDuration,
        onVipOpen: () => {
          if (this.selectedDuration === 'month' || this.selectedDuration === 'halfYear') {
            this.userInfo.vipLevel = 1;
          } else if (this.selectedDuration === 'perpetual') {
            this.userInfo.vipLevel = 2;
          }
          PersistenceV2.save(UserInfo);
          this.getUIContext().getPromptAction().showToast({ message: '兑换成功' })
        },
        packageChange: (item: VipPackageItem) => {
          this.selectedDuration = item.duration;
        }
      })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
    .onReady((context) => {
      // 获取参数
      this.routerModule = context.pathStack;
      const params = context.pathInfo.param as Record<string, Object>;
      if (params && params.isPerpetual) {
         this.selectedDuration = 'perpetual';
      } else {
         // 如果 vipLevel 为 1，默认选中终身卡，否则默认选中月卡
         if (this.userInfo.vipLevel === 1) {
            this.selectedDuration = 'perpetual';
         } else {
            this.selectedDuration = 'month';
         }
      }
    })
    .onBackPressed(() => {
      this.routerModule.pop('back')
      return true
    })
  }
}
