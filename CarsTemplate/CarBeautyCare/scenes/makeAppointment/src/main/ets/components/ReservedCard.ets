import { LocationVM, ShopCardModel, ShowCardView } from '@ohos_agcit/car_beauty_care_shop';
import { SelectedData } from '../mode/AppointmentModel';
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'
import { AppointmentVM } from '../mode/AppointmentVM';

@ComponentV2
export struct ReservedCard {
  locationVM: LocationVM = LocationVM.instance;
  @Param card: ShopCardModel = this.locationVM.shopCardList[0];
  appointmentVM: AppointmentVM = AppointmentVM.instance; // 预约数据信息
  @Param reservedCard: SelectedData = this.appointmentVM.appointmentOrder[0]; // 选中包含店铺信息的预约数据信息

  @Param onCancelClick: () => void = () => {};
  @Local selected: boolean = false;

  // 格式化日期
  private formatDate(dateStr: string): string {
    const parts = dateStr.split('.');
    const month = parts[0];
    const day = parts[1];
    return `${month}月${day}日`;
  }

  build() {
    Column() {
      Column() {
        Row() {
          Row() {
            Text(this.formatDate(this.reservedCard.date.date))
              .align(Alignment.Start)
              .fontSize(14)
              .fontFamily($r('app.string.font_regular'))
              .fontWeight(FontWeight.Medium);

            Text(this.reservedCard.time.label)
              .align(Alignment.Start)
              .fontSize(14)
              .fontFamily($r('app.string.font_regular'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: 2 });
          }
          .layoutWeight(1)
          .justifyContent(FlexAlign.Start);

          Text(this.reservedCard.licenseNumber)
            .fontSize(14)
            .fontFamily($r('app.string.font_regular'))
            .fontWeight(FontWeight.Medium)
            .align(Alignment.End);
        }
        .width(CommonConstants.FULL_WIDTH)
        .margin({ bottom: 5 })
        .justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text($r('app.string.maintain_reserve'))
            .fontSize(12)
            .fontFamily($r('app.string.font_regular'))
            .fontWeight(FontWeight.Regular)
            .fontColor(Color.Gray)
            .align(Alignment.Start)
            .layoutWeight(1)
        }
        .width(CommonConstants.FULL_WIDTH);
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding(12);

      Divider()
        .margin({ bottom: 8 });

      ShowCardView({
        card: this.card,
        showMark: false,
        imgRect: 72,
        showLine: true,
      })
        .width(CommonConstants.FULL_WIDTH);

      Row() {
        Text($r('app.string.reserve_cancel'))
          .fontSize(12)
          .fontColor(Color.Black)
          .backgroundColor(Color.White)
          .padding({
            top: 8,
            bottom: 8,
            left: 16,
            right: 16,
          })
          .border({ width: 1, color: Color.Gray })
          .borderRadius(14)
          .onClick(() => {
            this.onCancelClick();
          });
      }
      .justifyContent(FlexAlign.End)
      .width(CommonConstants.FULL_WIDTH)
      .margin({ top: 10 });
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(216)
    .borderRadius(16)
    .backgroundColor(Color.White)
    .padding(10);
  }
}