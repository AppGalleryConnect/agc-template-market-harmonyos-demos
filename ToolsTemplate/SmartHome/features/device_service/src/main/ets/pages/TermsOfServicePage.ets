import { Constants } from 'utils';

@Builder
export function TermsOfServicePageBuilder(name: string, param: Object) {
  TermsOfServicePage();
}

@ComponentV2
export struct TermsOfServicePage {
  pathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        Text('当你使用智慧家居APP时，我们会在获得或确保设备第三方获取你的授权同意后，以及其他符合法律法规的情形下共享对应信息。' +
          '你可以通过本清单相关信息了解第三方设备会如何处理你的个人信息。我们也会保障你的个人信息安全。')
          .lineHeight(25)
          .padding({top:15})
      }
      .height('100%')
      .width('90%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('用户协议')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop(); // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo));
      return true;
    })
    .backgroundColor(Constants.NAV_DESTINATION_BACKGROUND_COLOR);
  }
}