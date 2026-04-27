import { batteryInfo } from '@kit.BasicServicesKit';

@ComponentV2
export struct Battery {
  @Local percent: number = batteryInfo.batterySOC

  aboutToAppear(): void {
    this.percent = batteryInfo.batterySOC
  }

  build() {
    Row() {
      Row() {
        Row() {
          Row()
            .width(`${this.percent}%`)
            .height('100%')
            .margin({ left: 1, right: 1 })
            .backgroundColor(Color.White)
        }
        .width('calc(100% - 2vp)')
        .height('calc(100% - 2vp)')
      }
      .width(24)
      .height(12)
      .borderWidth(1)
      .borderColor(Color.White)
      .borderRadius(3)

      Row()
        .width(2)
        .height(6)
        .backgroundColor(Color.White)
    }
    .accessibilityGroup(true)
    .accessibilityLevel('yes')
    .accessibilityText('电量百分之' + this.percent)
  }
}