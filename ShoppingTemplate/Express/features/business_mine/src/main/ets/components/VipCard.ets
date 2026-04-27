import { CommonCard, RouterModule } from 'lib_foundation'
import { RouterMap } from 'module_base'
import { VipPageVM } from '../viewModels/VipPageVM'

@ComponentV2
export struct VipCard {
  vm: VipPageVM = VipPageVM.instance

  build() {
    Row() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        CommonCard()

        Button('去开通')
          .fontSize($r('sys.float.Body_S'))
          .fontWeight(FontWeight.Medium)
          .height(24)
          .fontColor('#FE543A')
          .backgroundColor('rgba(254,84,58,0.2)')
          .onClick(() => {
            if (!this.vm.userInfoModel.isLogin) {
              RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
              return
            }
            RouterModule.push({ url: RouterMap.PURCHASE_PAGE })
          })
      }
      .height(40)
      .padding({ left: 12, right: 12 })
      .backgroundImage($r('app.media.banner_vip'))
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius(16)
    }
    .width('100%')
    .height(56)
    .margin({ bottom: 8 })
  }
}
