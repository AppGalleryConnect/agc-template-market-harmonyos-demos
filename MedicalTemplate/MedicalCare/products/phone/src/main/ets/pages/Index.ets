import { AuthenticationUtil, BaseError, LogUtil, RouterUtil } from 'common';
import { NotificationPage } from 'notification';
import { HomePage } from '../components/HomePage';
import { MyPage } from '../components/MyPage';
import { AppointmentStatusWidgetViewModel } from '../viewmodel/AppointmentStatusWidgetViewModel';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0
  private appointmentStatusWidgetViewModel = new AppointmentStatusWidgetViewModel()

  aboutToAppear(): void {
    AuthenticationUtil.silentLogin().then((credential) => {
      LogUtil.info(`Silent login success, ${JSON.stringify(credential)}`)
    }).catch((error: BaseError) => {
      LogUtil.error(`Failed to login. errCode is ${error.code}, errMessage is ${error.message}`);
    });

    this.appointmentStatusWidgetViewModel.getAppointmentStatusInfo()
  }

  build() {
    Navigation(RouterUtil.navPathStack) {
      Tabs({ barPosition: BarPosition.End }) {
        TabContent() {
          HomePage()
        }
        .tabBar(this.tabBarBuilder('首页', 0, $r('app.media.ic_home_selected'), $r('app.media.ic_home')))

        TabContent() {
          NotificationPage()
        }
        .tabBar(this.tabBarBuilder('消息', 1, $r('app.media.ic_message_selected'), $r('app.media.ic_message')))

        TabContent() {
          MyPage()
        }
        .tabBar(this.tabBarBuilder('我的', 2, $r('app.media.ic_my_selected'), $r('app.media.ic_my')))
      }
      .scrollable(false)
      .backgroundColor($r('sys.color.ohos_id_color_bottom_tab_sub_bg'))
      .onChange((index: number) => {
        this.currentIndex = index
      })
    }
    .hideTitleBar(true)
    .hideBackButton(true)
    .mode(NavigationMode.Auto)
  }

  @Builder
  tabBarBuilder(title: string, targetIndex: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === targetIndex ? selectedImg : normalImg)
        .size({ width: 21, height: 21 })
      Text(title)
        .fontColor(this.currentIndex === targetIndex ? $r('sys.color.ohos_id_color_bottom_tab_text_on') :
        $r('sys.color.ohos_id_color_bottom_tab_text_off'))
        .fontSize(14)
        .margin({ top: 5 })

    }
    .width('100%')
    .height(50)
    .justifyContent(FlexAlign.Center)
  }
}
