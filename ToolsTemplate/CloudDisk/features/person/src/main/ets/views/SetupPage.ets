import { Constants, HeaderView, RouterMap, TCLogger } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router';
import { UserInfoRow } from '../comp/UserInfoRow';
import { PrivacySettingsPageBuilder } from './PrivacySettingsPage';
import { AccountAndPrivacyPageBulder } from './‌AccountAndPrivacyPage';
import { AboutPageBuilder } from './AboutPage';
import { DownLoadNetworkPriceViewModel } from '../viewmodel/DownLoadNetworkPriceViewModel';
import { EquipmentManagementPageBuilder } from './EquipmentManagementPage';
import { SettingAboutVM } from '../viewmodel/SetUpVM';
import { GenericCard } from '../comp/GenericCard';

const TAG = 'SetUpPage'

/**
 * @usage: 用于展示设置页面。提供应用设置和账号管理功能，包括账号安全、设备管理、下载更新、缓存清理、版本更新、关于应用、
 * 隐私设置和退出登录等功能入口。关键数据结构包括SettingAboutVM（设置视图模型，包含cacheSize缓存大小、
 * getClearSize获取缓存方法、checkAppUpdate版本检查方法、clearUserInfo清除用户信息方法）、
 * DownLoadNetworkPriceViewModel（下载网络价格视图模型，包含setDownLoadNetworkPrice设置下载开关方法）、
 * UserInfo（用户信息模型，包含isLogin登录状态）。包含if逻辑：根据vm.userInfo.isLogin判断是否允许退出登录，
 * 未登录时显示"未登录"提示。
 * @layout: 页面采用Column垂直布局（间距12vp）。顶部是HeaderView导航栏（标题"设置"和返回按钮，上边距24vp），
 * 主体是GenericCard卡片容器（圆角16vp），包含7个UserInfoRow设置项（账号安全、设备管理、下载更新开关、清理缓存、版本更新、
 * 关于应用、隐私设置，每项高度60vp），每项之间有Divider分割线（1px宽度，左右内边距16vp）。
 * 底部是"退出登录"按钮（红色文字#FF4B2F，白色背景，圆角16vp，高度60vp，居中对齐）。
 * @constraints: UserInfo用户信息模型的登录状态不可手动修改；缓存大小由vm.getClearSize()计算不可修改；
 * 退出登录需要验证登录状态（vm.userInfo.isLogin）；版本更新检查由vm.checkAppUpdate()执行；
 * 下载更新开关状态由downloadNetworkVM.setDownLoadNetworkPrice()控制；清理缓存需要弹出确认对话框vm.showAlert()。
 * @isGen: true
 * @fileType: page
 * @zhName: 设置页面
 * @subPage: AccountAndPrivacyPage,EquipmentManagementPage,AboutPage,PrivacySettingsPage
 * @component: OHPage,HeaderView,UserInfoRow,GenericCard
 * @image: screenshot/Person/SetUp.jpg
 */

@ComponentV2
export struct SetUpPage {
  vm: SettingAboutVM = new SettingAboutVM();
  downloadNetworkVM = new DownLoadNetworkPriceViewModel()

  aboutToAppear(): void {
    this.vm.init()
    this.vm.getClearSize()
  }

  @Builder
  line() {
    Divider().strokeWidth('1px').width('100%').color($r('sys.color.comp_divider')).padding({ left: 16, right: 16 })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      pageBackgroundColor: Color.White
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      Column() {
        HeaderView({
          title: $r('app.string.setting'),
          clickBackBtn: () => {
            phoneRouterControl.popPage();
          }
        })
      }
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('app.color.white'))

      Column({ space: 12 }) {
        Column() {
          GenericCard() {
            UserInfoRow({
              leftTitle: $r('app.string.safe_Account'), rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.ACCOUNT_AND_PRIVACY_PAGE,
                  builder: wrapBuilder(AccountAndPrivacyPageBulder)
                })
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: $r('app.string.device_manage'), rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.EQUIPMENT_MANAGEMENT_PAGE,
                  builder: wrapBuilder(EquipmentManagementPageBuilder)
                })
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: $r('app.string.download_update'), isSwitch: true, switchButton: (isOn: boolean) => {
                TCLogger.debug(TAG, `${isOn}`)
                this.downloadNetworkVM.setDownLoadNetworkPrice(isOn)
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: $r('app.string.clear_cache'), rightContent: this.vm.cacheSize, rightOnClick: () => {
                this.vm.showAlert()
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: $r('app.string.version_update'), rightContent: '发现新版本', rightOnClick: () => {
                this.vm.checkAppUpdate()
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: $r('app.string.about_app'), rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.ABOUT_PAGE,
                  builder: wrapBuilder(AboutPageBuilder)
                })
              }
            })
            this.line()
            UserInfoRow({
              leftTitle: $r('app.string.private_setting'), rightOnClick: () => {
                phoneRouterControl.jumpPage({
                  pageName: RouterMap.PRIVACY_SETTINGS_PAGE,
                  builder: wrapBuilder(PrivacySettingsPageBuilder)
                })
              }
            })
          }
        }
        .width('100%')

        Text($r('app.string.exit_login'))
          .borderRadius(16)
          .fontColor($r('app.color.red_color_FF4B2F'))
          .backgroundColor($r('app.color.white'))
          .fontSize(15)
          .textAlign(TextAlign.Center)
          .fontWeight(500)
          .width('100%')
          .height(60)
          .onClick(() => {
            if (this.vm.userInfo.isLogin) {
              this.vm.clearUserInfo()
              this.getUIContext().getPromptAction().showToast({ message: '退出成功', duration: 2000 });
              phoneRouterControl.popPage()
            } else {
              this.getUIContext().getPromptAction().showToast({ message: $r('app.string.not_login'), duration: 2000 });
            }
          })
      }
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)
      .width('100%')
      .margin({ top: 12 })
      .padding({
        left: 16,
        right: 16,
      })
      .backgroundColor($r('sys.color.comp_background_gray'))
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.comp_background_gray'))
  }
}


@Builder
export function SetUpPageBuilder() {
  SetUpPage()
}
