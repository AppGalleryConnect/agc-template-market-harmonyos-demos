import { RouterModule } from 'lib_foundation';
import { RouterMap } from 'module_base';
import { HomePageVM } from '../viewModels/HomePageVM';

@ComponentV2
export struct MainService {
  vm: HomePageVM = HomePageVM.instance;

  @Builder
  buttonBuilder(image: ResourceStr, title: string, tip: string, router: RouterMap) {
    Row() {
      Image(image)
        .width(60)
        .height(60)
        .margin({ right: 8 })
      Column() {
        Text(title)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
          .margin({ bottom: 2 })
        Text(tip)
          .fontSize(12)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
    }
    .onClick(() => {
      if (!this.vm.userInfoModel.isLogin) {
        RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
        return
      }
      RouterModule.push({ url: router })
    })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        this.buttonBuilder($r('app.media.ic_car'), '寄快递', '一小时取件', RouterMap.EXPRESS_PAGE)
        this.buttonBuilder($r('app.media.ic_car'), '发物流', '大件/整车/零担', RouterMap.EXPRESS_PAGE)
      }
      .height('100%')
      .backgroundColor(Color.White)
      .padding({ left: 12, right: 12 })
      .borderRadius(16)
    }
    .height(84)
    .margin({ bottom: 12 })
  }
}