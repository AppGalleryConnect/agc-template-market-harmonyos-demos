import { NavBarInfo, NavBarListView } from 'uicomponents';
import { Constants } from 'utils';

@Builder
export function AboutUsPageBuilder(name: string, param: Object) {
  AboutUsPage();
}

@ComponentV2
export struct AboutUsPage {
  pathStack: NavPathStack = new NavPathStack();
  navBarList: NavBarInfo[] = [
    {
      image: '',
      text: '隐私政策',
      pageName: 'PrivacyPolicyPage',
    },
    {
      image: '',
      text: '用户协议',
      pageName: 'TermsOfServicePage',
    },
  ];

  @Builder
  BuildVersion() {
    Column() {
      Image($r('app.media.app_icon'))
        .size({ width: 100 });
      Text('V1.0.0')
        .margin({ top: 5 });
    }
    .margin({ top: 20 });
  }

  @Builder
  BuildBar() {
    NavBarListView({ pathStack: this.pathStack, navBarList: this.navBarList })
      .margin({ top: 30 });
  }

  build() {
    NavDestination() {
      Column() {
        this.BuildVersion();
        this.BuildBar();
      }
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM]);
    }
    .title('关于我们')
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