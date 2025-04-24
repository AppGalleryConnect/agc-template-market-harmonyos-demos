import { DateTimeElement, TitleBar } from '@ohos_agcit/office_attendance_component_lib';
import { DialogMap, RouterModule } from '@ohos_agcit/office_attendance_common_lib'

@Builder
export function TimeSelectorBuilder() {
  TimeSelector();
}

@ComponentV2
export struct TimeSelector {
  hour: number = 0;
  minute: number = 0;
  @Local selectedTime: Date = new Date()
  @Local heightSize: string = '50%';
  @Local opacityNum: number = 1;
  @Local animateDuration: number = 300;
  @Event callback: (hour: number, minute: number) => void = (hour: number, minute: number) => {
  };

  aboutToAppear(): void {
    let param = RouterModule.getNavParam({ url: DialogMap.TIME_SELECTOR }).param as DateTimeElement;
    if (param?.hour) {
      this.selectedTime.setHours(param.hour as number);
      this.selectedTime.setMinutes(param.minute as number);
    }
  }

  hide() {
    animateTo({
      duration: this.animateDuration,
      curve: Curve.Friction,
      onFinish: () => {
        RouterModule.pop();
      },
    }, () => {
      this.heightSize = '0%';
      this.opacityNum = 0;
    });
  }

  save() {
    RouterModule.closeDialog({ param: { hour: this.hour, minute: this.minute } });
  }

  build() {
    NavDestination() {
      Stack({ alignContent: Alignment.Bottom }) {
        Column() {
        }
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0, 0, 0, 0.3)')
        .opacity(this.opacityNum)
        .transition(
          TransitionEffect.OPACITY.animation({
            duration: this.animateDuration,
            curve: Curve.Friction,
          })
        )
        .onClick(() => {
          this.hide();
        })
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);

        Column() {
          Column() {

          }.alignItems(HorizontalAlign.Center)
          .justifyContent(FlexAlign.Center)
          .width('100%')
          .height(16)

          Row(){
            Column().width('3%')

            TitleBar({
              titleResID:'',
              hide: () => {
                this.hide()
              }, callback: () => {
                this.save()
              }
            }).layoutWeight(1)

            Column().width('3%')
          }


          Column() {
            TimePicker({
              selected: this.selectedTime,
            })
              .useMilitaryTime(true)
              .onChange((value: TimePickerResult) => {
                if (value.hour >= 0) {
                  this.hour = value.hour;
                  this.minute = value.minute;
                }
              })
              .disappearTextStyle({ color: Color.Red, font: { size: 10, weight: FontWeight.Lighter } })
              .textStyle({ color: Color.Black, font: { size: 15, weight: FontWeight.Normal } })
              .selectedTextStyle({ color: Color.Black, font: { size: 15, weight: FontWeight.Bolder } })
          }.height('100%')

        }.height('50%')
        .borderRadius({ topLeft: 32, topRight: 32 })
        .backgroundColor(Color.White)
      }
      .height('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
    }.mode(NavDestinationMode.DIALOG)
    .onBackPressed(() => {
      return false;
    })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .hideTitleBar(true);
  }
}