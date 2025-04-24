import { AppointmentViewModel } from '../viewmodel/AppointmentViewModel';
import { DepartmentSelectPage } from './DepartmentSelectPage';
import { DoctorSelectPage } from './DoctorSelectPage';
import { CommonNavDestination } from 'common';

/**
 * 挂号科室选择、医生选择页面
 */
@Builder
export function AppointmentMainPageBuilder() {
  CommonNavDestination({ title: '挂号' }) {
    AppointmentMainPage()
  }
}

@Entry
@ComponentV2
struct AppointmentMainPage {
  @Local appointmentViewModel: AppointmentViewModel = AppointmentViewModel.getInstance()
  @Local currentIndex: number = 0

  build() {
    Tabs({ barPosition: BarPosition.Start }) {
      TabContent() {
        DepartmentSelectPage()
      }
      .tabBar(this.tabBarBuilder('按科室', 0))

      TabContent() {
        DoctorSelectPage()
      }
      .tabBar(this.tabBarBuilder('按医生', 1))
    }
    .width('100%')
    .height('100%')
    .barBackgroundColor($r('sys.color.ohos_id_color_bottom_tab_bg'))
    .scrollable(false)
    .animationDuration(0)
    .onChange((index: number) => {
      this.currentIndex = index
    })
  }

  @Builder
  tabBarBuilder(title: string, targetIndex: number) {
    Flex({ justifyContent: FlexAlign.Start, direction: FlexDirection.Column, alignItems: ItemAlign.Center }) {
      Text(title)
        .fontSize(16)
        .fontWeight(targetIndex === this.currentIndex ? 500 : 400)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))

      if (targetIndex === this.currentIndex) {
        Divider()
          .width(70)
          .height(4)
          .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
          .margin({
            top: 4
          })
      }
    }
    .width('100%')
    .height(25)
  }
}