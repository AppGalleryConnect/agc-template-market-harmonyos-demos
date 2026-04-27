import { RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base'
import { MinePageVM } from '../viewModels/MinePageVM'

@ComponentV2
export struct Welfare {
  vm: MinePageVM = MinePageVM.instance

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_checkmark_calendar_fill'))
          .width(16)
          .height(16)
          .margin({ right: 4 })
        Text('签到可领取积分兑换好券')
          .fontSize(14)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_primary'))
      }

      Image($r('app.media.ic_arrow_right'))
        .width(14)
        .height(14)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.SpaceBetween)
    .backgroundColor(Color.White)
    .margin({ bottom: 12 })
    .padding({
      left: 12,
      right: 12,
    })
    .borderRadius(16)
    .onClick(() => {
      if (this.vm.userInfoModel.isLogin) {
        RouterModule.push({ url: RouterMap.VIP_PAGE })
      } else {
        RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
      }
    })
  }
}