import { CommonEmptyView } from 'common'

interface BuildTimeSlotButtonParam {
  groupName: string,
  timeSlotList: string[]
}

/**
 * 展示挂号时间段的View
 */
@ComponentV2
export struct TimeSlotView {
  @Param timeSlots: string[] = []
  @Param isClickable: boolean[] = []
  @Local morningTimeSlots: string[] = []
  @Local afternoonTimeSlots: string[] = []
  @Param onTimeSlotClick: (index: number, time: string) => void = () => {
  }

  @Monitor('timeSlots')
  onTimeSlotsChange() {
    this.calculateTimeSlots(this.timeSlots)
  }

  aboutToAppear(): void {
    this.calculateTimeSlots(this.timeSlots)
  }

  calculateTimeSlots(timeSlots: string[]) {
    this.morningTimeSlots = timeSlots.filter((item) => {
      return item.split(':')[0] < '12'
    })

    this.afternoonTimeSlots = timeSlots.filter((item) => {
      return item.split('-')[0].split(':')[0] >= '12'
    })
  }

  build() {
    if (this.timeSlots.length === 0) {
      CommonEmptyView('暂无排班信息')
    } else {
      Column({ space: 16 }) {
        if (this.morningTimeSlots.length > 0) {
          this.buildTimeSlotButtons({ groupName: '上午', timeSlotList: this.morningTimeSlots })
        }

        if (this.afternoonTimeSlots.length > 0) {
          this.buildTimeSlotButtons({ groupName: '下午', timeSlotList: this.afternoonTimeSlots })
        }
      }
    }
  }

  @Builder
  buildTimeSlotButtons(param: BuildTimeSlotButtonParam) {
    Column({ space: 8 }) {
      Text(param.groupName)
        .fontSize(14)
        .textAlign(TextAlign.Start)
        .width('100%')

      GridRow({ columns: 3, gutter: 10 }) {
        ForEach(param.timeSlotList, (item: string, index) => {
          GridCol() {
            Button(item)
              .fontSize(14)
              .fontColor(
                this.isClickable[index] ?
                $r('sys.color.ohos_id_color_text_primary') :
                $r('sys.color.ohos_id_color_text_secondary')
              )
              .backgroundColor($r('sys.color.ohos_id_color_background'))
              .width('100%')
              .padding(6)
              .borderRadius(8)
              .borderWidth(1)
              .borderColor($r('sys.color.ohos_id_color_component_normal'))
              .height(32)
              .enabled(this.isClickable[index])
              .onClick(() => {
                this.onTimeSlotClick(index, item)
              })
          }
        }, (item: string) => item)
      }
    }
  }
}
