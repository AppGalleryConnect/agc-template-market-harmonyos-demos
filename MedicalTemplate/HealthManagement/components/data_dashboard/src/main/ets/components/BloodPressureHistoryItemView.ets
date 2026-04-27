import { BloodPressureHistoryItem } from '../types/BloodPressureTypes';

@ComponentV2
export struct BloodPressureHistoryItemView {
  @Param item: BloodPressureHistoryItem = {
    systolic: 0,
    diastolic: 0,
    pulse: 0,
    status: '',
    dateTime: ''
  };

  build() {
    Row() {
      Column({ space: 6 }) {
        Row({ space: 4 }) {
          Text(`${this.item.systolic}/${this.item.diastolic}`)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('mmHg')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Text(this.item.status)
          .fontSize($r('sys.float.Body_S'))
          .fontColor(this.item.status === '正常高值' ? '#FF6B00' : '#00d2b9')
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.item.dateTime)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.mask_secondary'))
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      top: 16,
      bottom: 16
    })
  }
}
