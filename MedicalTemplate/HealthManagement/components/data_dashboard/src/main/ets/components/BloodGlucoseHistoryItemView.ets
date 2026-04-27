import { BloodGlucoseHistoryItem } from '../types/BloodGlucoseTypes';

@ComponentV2
export struct BloodGlucoseHistoryItemView {
  @Param item: BloodGlucoseHistoryItem = {
    value: 0,
    status: '',
    mealTime: '',
    dateTime: ''
  };

  build() {
    Row() {
      Column({ space: 6 }) {
        Row({ space: 4 }) {
          Text(`${this.item.value.toFixed(1)}`)
            .fontSize($r('sys.float.Subtitle_L'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('sys.color.font_primary'))
          Text('mmol/L')
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.mask_secondary'))
        }

        Row({ space: 8 }) {
          Text(this.item.status)
            .fontSize($r('sys.float.Body_S'))
            .fontColor(this.item.status === '偏低' ? '#FFA800' :
              this.item.status === '偏高' ? '#F44336' : '#64BB5C')
          Text(this.item.mealTime)
            .fontSize($r('sys.float.Body_S'))
            .fontColor($r('sys.color.mask_secondary'))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)

      Text(this.item.dateTime)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('sys.color.mask_secondary'))
    }
    .width('100%')
    .padding({
      bottom: 16,
      right: 16,
      left: 16,
      top: 16
    })
  }
}
