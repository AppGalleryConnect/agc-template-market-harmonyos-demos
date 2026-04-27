import { RouterModule } from 'lib_foundation'
import { CommonUtil, RouterMap } from 'module_base'
import { MinePageVM } from '../viewModels/MinePageVM'

@ComponentV2
export struct LoginAvatarCard {
  vm: MinePageVM = MinePageVM.instance

  build() {
    Column() {
      Row() {
        Image(this.vm.userInfoModel.avatar ? this.vm.userInfoModel.avatar : $r('app.media.ic_avatar'))
          .width(48)
          .height(48)
          .borderRadius(24)
          .margin({ right: 16 })
          .flexShrink(0)
        if (this.vm.userInfoModel.isLogin) {
          Column() {
            Text(this.vm.userInfoModel.nickname ?? '用户')
              .fontSize(18)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
            Row({ space: 8 }) {
              Image($r('app.media.ic_public_phone'))
                .width(16)
                .height(16)
              Text(CommonUtil.encryptPhoneNo(this.vm.userInfoModel.cellphone ?? ''))
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_secondary'))
            }
          }
          .height(48)
          .alignItems(HorizontalAlign.Start)
          .justifyContent(FlexAlign.Center)
        } else {
          Row() {
            Column() {
              Text('点击登录')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .margin({ bottom: 2 })
              Text('登录后享受更多服务')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
            }
            .height(48)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)

            Image($r('app.media.ic_arrow_right'))
              .width(12)
              .height(24)
          }
          .flexGrow(1)
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }
      .width('100%')
      .padding(12)
      .onClick(() => {
        if (this.vm.userInfoModel.isLogin) {
          RouterModule.push({ url: RouterMap.PERSONAL_INFORMATION_PAGE })
        } else {
          RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
        }
      })

      Divider()

      Row() {
        if (this.vm.userInfoModel.isLogin) {
          Row() {
            Text('多种福利任意享')
              .fontSize($r('sys.float.Body_M'))
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
              .onClick(() => {
                RouterModule.push({ url: RouterMap.VIP_PAGE })
              })

            Row()
              .width(6)
              .height(6)
              .borderRadius(3)
              .backgroundColor('#E84026')

            Image($r('app.media.ic_arrow_right_second'))
              .width(12)
              .height(24)
          }
        }

        Button('会员中心')
          .controlSize(ControlSize.SMALL)
          .onClick(() => {
            if (this.vm.userInfoModel.isLogin) {
              RouterModule.push({ url: RouterMap.PURCHASE_PAGE })
            } else {
              RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
            }
          })
      }
      .justifyContent(this.vm.userInfoModel.isLogin ? FlexAlign.SpaceBetween : FlexAlign.End)
      .width('100%')
      .padding(12)
    }
    .width('100%')
    .backgroundColor(Color.White)
    .borderRadius(16)
    .margin({ bottom: 12 })
  }
}