import { HeartRateHistoryItem } from '../types/HeartRateTypes';

@ComponentV2
export struct HeartRateHistoryItemView {
  @Param item: HeartRateHistoryItem = {
    range: '',
    dateTime: ''
  };
  @Param onItemClick: () => void = () => {
  };

  build() {
    Row() {
      Text(this.item.range)
        .fontSize($r('sys.float.Subtitle_S'))
        .fontColor($r('sys.color.font_primary'))
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)

      Row({ space: 8 }) {
        Text(this.item.dateTime)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.mask_secondary'))

        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .width(18)
          .height(18)
          .fillColor($r('sys.color.mask_secondary'))
      }
    }
    .width('100%')
    .padding({
      left: 16,
      right: 16,
      bottom: 20,
      top: 20
    })
    .onClick(() => {
      this.onItemClick();
    })
  }
}
