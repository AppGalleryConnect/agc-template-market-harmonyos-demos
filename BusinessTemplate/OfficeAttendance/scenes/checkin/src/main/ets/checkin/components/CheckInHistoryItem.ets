import { CheckInHistoryDetailDataItem } from '../../types/Types';
import { CheckInTimeDetail } from './CheckInTimeDetail';

@Preview
@ComponentV2
export struct CheckInHistoryItem {
  @Param dayDesc: string | Resource = '';
  @Param day: string = '';
  @Param index: number = 0;
  @Param details: CheckInHistoryDetailDataItem[] = [];
  @Local dividerHeight: Length = '30vp'
  @Provider('isHistoryChecked') isChecked: boolean = false;

  build() {
    Flex({ alignItems: ItemAlign.Center }) {
      Text(this.dayDesc)
        .fontSize(14)
        .fontColor($r('app.string.black_40'))
        .width(28)
        .maxLines(1)
        .flexShrink(0);
      Column() {
        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r('app.string.black_20'))
          .height(this.dividerHeight);
        Stack() {
          Circle()
            .width(20)
            .height(20)
            .stroke(this.index === 0 ? $r('app.color.checkin_background') : $r('app.string.black_40'))
            .fill(Color.Transparent);
          Text(this.day)
            .fontSize(14)
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
            .fontColor(this.index === 0 ? $r('app.color.checkin_background') : $r('app.string.black_40'));
        }.align(Alignment.Center)

        Divider()
          .vertical(true)
          .strokeWidth(1)
          .color($r('app.string.black_20'))
          .height(this.dividerHeight);
      }.margin({ left: 14 }).width(20).flexShrink(0)

      Column() {
        Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
          CheckInTimeDetail({ 'checkinTimeDetailItemList': this.details }).flexGrow(1);
          Image(this.isChecked ? $r('app.media.single_arrow_up') : $r('app.media.single_arrow_down'))
            .width(24)
            .height(24).margin({ left: 8 });
        }.align(Alignment.Center)

        Divider()
          .strokeWidth(1)
          .color($r('app.string.black_20')).alignSelf(ItemAlign.End).margin({ top: 8 })
      }
      .flexGrow(1)
      .margin({ left: 18 })
      .onAreaChange((oldValue, newValue) => {
        this.dividerHeight = (newValue.height as number - 20) / 2;
      })
      .onClick(() => {
        this.isChecked = !this.isChecked
      })
    }
  }
}