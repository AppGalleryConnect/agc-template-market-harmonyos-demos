import { FormatUtil, RouterMap } from 'commonlib'
import { MinePageVM } from '../viewModels/MinePageVM'

@ComponentV2
export struct LoginAvatarCard {
  vm: MinePageVM = MinePageVM.instance

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Flex() {
          Image(this.vm.avatar ? this.vm.avatar : $r('app.media.ic_avatar'))
            .width(48)
            .height(48)
            .borderRadius(24)
            .margin({ right: 16 })
            .flexShrink(0)
          if (this.vm.isLogin) {
            Column() {
              Text(this.vm.nickname ?? '华为用户')
                .fontSize(18)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .height(48)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
          } else {
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
          }
        }

        Image($r('app.media.arrow_right'))
          .width(12)
          .height(24)
      }
      .onClick(() => {
        if (this.vm.isLogin) {
          FormatUtil.jumpToNext(RouterMap.PERSONAL_INFORMATION_PAGE)
        } else {
          FormatUtil.jumpToNext(RouterMap.QUICK_LOGIN_PAGE)
        }
      })
    }
    .width('100%')
    .height(72)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .padding({
      left: 16,
      right: 16
    })
    .borderRadius(16)
  }
}