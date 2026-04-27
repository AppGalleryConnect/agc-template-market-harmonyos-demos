import { BaseNavTitle } from 'base_apis';
import { ThemeVM } from '../viewModel/ThemeController';

@Builder
export function TermsOfServicePageBuilder() {
  TermsOfServicePage()
}

@ComponentV2
export struct TermsOfServicePage {
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local themeVM: ThemeVM = ThemeVM.instance;


  build() {
    NavDestination() {
      BaseNavTitle({
        title: '用户协议',
        titleColor: this.themeVM.titleColor,
        currentTheme: this.themeVM.selectColor,
        routerModule: this.pathStack,
      })
      Column() {
        Text('当你使用日历模版时，我们会在获得或确保设备第三方获取你的授权同意后，以及其他符合法律法规的情形下共享对应信息。' +
          '你可以通过本清单相关信息了解第三方设备会如何处理你的个人信息。我们也会保障你的个人信息安全。')
          .lineHeight(25)
          .padding({ top: 15 })
      }
      .height('100%')
      .width('90%')
      .margin({ top: 16 })
    }
    .hideTitleBar(true)
    .onReady((ctx) => {
      this.pathStack = ctx.pathStack
    })
  }
}