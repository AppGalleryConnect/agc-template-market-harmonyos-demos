import { SleepHistoryItem } from '../types/SleepTypes';

@ComponentV2
export struct SleepHistoryItemView {
  @Param item: SleepHistoryItem = {
    duration: '',
    dateTime: ''
  };
  @Param onItemClick: () => void = () => {
  };

  build() {
    Row() {
      Text(this.item.duration)
        .fontWeight(FontWeight.Medium)
        .layoutWeight(1)
        .fontColor($r('sys.color.font_primary'))
        .fontSize($r('sys.float.Subtitle_S'))

      Row({ space: 8 }) {
        Text(this.item.dateTime)
          .fontColor($r('sys.color.mask_secondary'))
          .fontSize($r('sys.float.Body_L'))


        Image($r('sys.media.ohos_ic_public_arrow_right'))
          .height(18)
          .width(18)
          .fillColor($r('sys.color.mask_secondary'))
      }
    }
    .width('100%')
    .padding({
      top: 20,
      bottom: 20,
      left: 16,
      right: 16
    })
    .onClick(() => {
      this.onItemClick();
    })
  }
}
