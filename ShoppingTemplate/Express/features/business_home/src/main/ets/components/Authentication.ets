import { RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base'
import { ExpressPageVM } from '../viewModels/ExpressPageVM'

@ComponentV2
export struct Authentication {
  vm: ExpressPageVM = ExpressPageVM.instance

  build() {
    Row() {
      Row() {
        Image($r('app.media.ic_warning'))
          .width(12)
          .height(12)
          .margin({ right: 4 })
        Text('根据相关法律法规，寄件须实名认证。建议您提前实名认证。')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor(Color.White)
      }

      Image($r('app.media.ic_arrow_right'))
        .width(12)
        .height(12)
    }
    .width('100%')
    .height(30)
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 12, right: 12 })
    .borderRadius(16)
    .backgroundColor('#0A59F7')
    .margin({ top: 8, bottom: 12 })
    .onClick(() => {
      if (this.vm.userInfoModel.realNameAuthFlag === 0) {
        RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
      }
    })
  }
}