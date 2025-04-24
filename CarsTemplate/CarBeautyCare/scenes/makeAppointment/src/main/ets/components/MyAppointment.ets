import { AppointmentVM } from '../mode/AppointmentVM';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function MyAppointmentBuilder() {
  MyAppointment()
}

@ComponentV2
export struct MyAppointment {
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;
  appointmentVM: AppointmentVM = AppointmentVM.instance;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {

          Column() {
            Image($r('app.media.noappointment'))
              .width(120)
              .height(120)
              .margin({ bottom: 12 });

            Text($r('app.string.reserve_none'));
          }
          .margin({ top: 100 })
          .padding(15);
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
        .backgroundColor($r('app.color.lightGrey'));
      };
    }
    .title('我的预约')
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });

  }
}
