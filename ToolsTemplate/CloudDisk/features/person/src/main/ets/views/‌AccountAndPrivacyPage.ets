import { VipCenterPageBuilder } from 'collect_personal_info';
import { Constants, GlobalContext, HeaderView, PreferenceConstant, PreferenceUtil, RouterMap, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { UserInfoRow } from '../comp/UserInfoRow';
import { ChangePrivateSpacePasswordPageBuilder } from './ChangePrivateSpacePasswordPage'
import { PersistenceV2 } from '@kit.ArkUI';
import { SettingPrivateSpacePasswordPageBuilder } from 'clouddisk_file';

@Builder
export function AccountAndPrivacyPageBulder() {
  AccountAndPrivacyPage()
}


/**
 * @usage: 用于展示账号与安全页面。提供账号安全相关的设置入口，当前包含隐私空间密码修改功能。
 * 关键数据结构包括UserInfoRow（用户信息行组件，包含leftTitle左侧标题和rightOnClick右侧点击回调）。
 * 页面提供隐私空间密码修改入口，点击后跳转到CHANGE_PRIVACY_SPACE_PASSWORD_PAGE修改密码页面。
 * @layout: 页面采用Column垂直布局（间距12vp）。顶部是HeaderView导航栏（标题"账号与安全"和返回按钮，上边距24vp），
 * 主体是UserInfoRow组件（标题"隐私空间密码"，白色背景，圆角16vp，左右内边距16vp）。
 * 页面背景色为bg_color，宽高均为100%。
 * @constraints: 隐私空间密码入口必须保留并跳转到CHANGE_PRIVACY_SPACE_PASSWORD_PAGE；
 * UserInfoRow组件的样式参数（白色背景、圆角16vp）固定；页面背景色bg_color不可修改。
 * @isGen: true
 * @fileType: page
 * @zhName: 账号与安全页面
 * @subPage: ChangePrivateSpacePasswordPage
 * @component: OHPage,HeaderView,UserInfoRow
 */


@ComponentV2
struct AccountAndPrivacyPage {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  // 标记是否在当前页面跳转开通了vip
  private isJumpToOpenVIP: boolean = false

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      }
    })
  }

  private showTipDialog(msg: ResourceStr, sureText: ResourceStr, sureAction: () => void) {
    GlobalContext.getUIContext().showAlertDialog({
      message: msg,
      autoCancel: false,
      alignment: DialogAlignment.Center,
      showInSubWindow: true,
      isModal: true,
      buttonDirection: DialogButtonDirection.HORIZONTAL,
      buttons: [
        {
          value: $r('app.string.dialog_cancel'),
          action: () => {
          }
        },
        {
          value: sureText,
          action: () => {
            sureAction()
          }
        }
      ]
    })

  }

  dealWithBackPress() {
    if (!PreferenceUtil.getInstance().has(PreferenceConstant.PRIVATE_SPACE_PASSWORD_KEY)) {
      // 在当前页面跳转到vip页面且成功开通，跳过提示
      if (this.isJumpToOpenVIP && this.userInfo.isVip) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
          builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
          param: false
        })
        return
      }

      this.showTipDialog($r('app.string.open_private_space_message'), $r('app.string.dialog_sure_open'), () => {
        if (this.userInfo.isVip) {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.OPEN_PRIVATE_SPACE_PAGE,
            builder: wrapBuilder(SettingPrivateSpacePasswordPageBuilder),
            param: false
          })
        } else {
          this.showTipDialog($r('app.string.upgrade_open_private_space'), $r('app.string.goto_upgrade'), () => {
            this.isJumpToOpenVIP = true
            phoneRouterControl.jumpPage({
              pageName: RouterMap.VIP_CENTER_PAGE,
              builder: wrapBuilder(VipCenterPageBuilder)
            })
          })
        }
      })
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.CHANGE_PRIVACY_SPACE_PASSWORD_PAGE,
        builder: wrapBuilder(ChangePrivateSpacePasswordPageBuilder)
      })
    }
  }

  @Builder
  render() {
    Column({ space: 12 }) {
      Column() {
        HeaderView({
          title: $r('app.string.safe_Account'),
          clickBackBtn: () => {
            phoneRouterControl.popPage();
          }
        })
          .margin({ top: 24 })
      }
      .width(Constants.FULL_SIZE)
      .backgroundColor($r('app.color.white'))

      Column() {
        UserInfoRow({
          leftTitle: $r('app.string.private_space_secret'), rightOnClick: () => {
            this.dealWithBackPress()
          }
        })
          .backgroundColor($r('app.color.white'))
          .borderRadius(16)
      }
      .width(Constants.FULL_SIZE)
      .padding({ left: 16, right: 16 })
    }
    .width(Constants.FULL_SIZE)
    .height(Constants.FULL_SIZE)
    .backgroundColor($r('app.color.bg_color'))

  }
}
