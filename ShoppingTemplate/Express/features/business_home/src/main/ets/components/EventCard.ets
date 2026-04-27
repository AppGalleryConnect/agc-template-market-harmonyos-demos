import { HomePageVM } from '../viewModels/HomePageVM';
import { CommonButton } from './CommonButton';
import { ControllerModule, RouterMap } from 'module_base';
import { CommonCard, RouterModule } from 'lib_foundation';

@ComponentV2
export struct EventCard {
  vm: HomePageVM = HomePageVM.instance;

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        CommonCard()

        CommonButton({ text: '去领取' })
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
      .height(40)
      .padding({ left: 12, right: 12 })
      .backgroundImage($r('app.media.banner_vip'))
      .backgroundImageSize(ImageSize.FILL)
      .borderRadius({ topLeft: 16, topRight: 16 })

      Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
        Row() {
          Image($r('app.media.ic_home_Event'))
            .width(24)
            .height(24)
            .margin({ right: 4 })
          Column() {
            Text() {
              Span('实名认证新用户最高')
                .fontColor($r('sys.color.font_primary'))
              Span('24元')
                .fontColor('#0A59F7')
              Span('首寄礼包')
                .fontColor($r('sys.color.font_primary'))
            }
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 4 })

            Text('活动仅剩 30天')
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor('#0A59F7')
          }
          .alignItems(HorizontalAlign.Start)
        }

        CommonButton({ text: this.vm.userInfoModel.realNameAuthFlag === 0 ? '去认证' : '已认证' })
          .onClick(() => {
            if (!this.vm.userInfoModel.isLogin) {
              RouterModule.push({ url: RouterMap.QUICK_LOGIN_PAGE })
              return
            }
            if (this.vm.userInfoModel.realNameAuthFlag === 0) {
              RouterModule.push({ url: RouterMap.REAL_NAME_AUTH_PAGE })
            }
          })
      }
      .height(58)
      .backgroundColor(Color.White)
      .padding({ left: 12, right: 12 })
      .borderRadius({ bottomLeft: 16, bottomRight: 16 })
    }
    .margin({ bottom: 12 })
  }
}