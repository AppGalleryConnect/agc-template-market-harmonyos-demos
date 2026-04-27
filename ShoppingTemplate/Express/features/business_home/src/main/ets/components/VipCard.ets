import { RouterModule } from 'lib_foundation';
import { ControllerModule, RouterMap } from 'module_base';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct VipCard {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column()
      .width('100%')
      .height(150)
      .margin({ bottom: 24 })
      .backgroundImage($r('app.media.ic_vip_card'))
      .backgroundImageSize(ImageSize.Cover)
      .borderRadius(16)
      .onClick(() => {
        if (!this.vm.userInfoModel.isLogin) {
          RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
          return
        }
        const controller = ControllerModule.get()
        if (controller) {
          controller.changeIndex(2)
        }
      })
  }
}