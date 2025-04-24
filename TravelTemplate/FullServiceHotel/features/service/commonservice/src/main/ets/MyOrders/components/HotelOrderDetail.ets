import { CheckInItem } from '../types';
import { OrderDetailPageVM } from '../viewModels/OrderDetailPageVM';

@ComponentV2
export struct HotelOrderDetail {
  vm: OrderDetailPageVM = OrderDetailPageVM.instance;

  build() {
    Column({ space: '16lpx' }) {
      this.hotelInfoCardBuilder();
      this.checkInInfoCardBuilder();

    }
    .backgroundColor($r('app.color.system_color_background_auxiliary'))
    .borderRadius({
      topLeft: $r('app.string.border_radius_16'),
      topRight: $r('app.string.border_radius_16'),
    })
    .padding($r('app.string.padding_s'))
    .flexGrow(1)
  }

  @Builder
  hotelInfoCardBuilder() {
    if (this.vm.hotelOrderItem) {
      Column() {
        Text(this.vm.hotelOrderItem.hotelName)
          .fontSize($r('app.string.font_size_32'))
          .fontWeight(500)

        this.dividerBuilder();

        Flex({ alignItems: ItemAlign.Start }) {
          Image(this.vm.hotelOrderItem.cover)
            .width(80)
            .aspectRatio(4 / 3)
            .objectFit(ImageFit.Cover)
            .borderRadius($r('app.string.border_radius_8'))
            .margin({ right: $r('app.string.margin_s') })
          Column() {
            Text(this.vm.hotelOrderItem.roomName)
              .fontSize($r('app.string.font_size_28'))
              .margin({ bottom: $r('app.string.margin_s') })
            Text(`${this.vm.hotelOrderItem.nights}晚 ${this.vm.hotelOrderItem.rmQty}间`)
              .labelTextStyle()
              .fontSize($r('app.string.font_size_24'))
            Text(`${this.vm.hotelOrderItem.arrDate} 至 ${this.vm.hotelOrderItem.depDate}`)
              .labelTextStyle()
              .fontSize($r('app.string.font_size_24'))
          }
          .alignItems(HorizontalAlign.Start)
          .flexGrow(1)

          Column() {
            Text(`¥${this.vm.hotelOrderItem.actualPaidPrice}`)
              .margin({ bottom: $r('app.string.margin_s') })
              .fontSize($r('app.string.font_size_28'))
          }
          .width(80)
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(HorizontalAlign.End)
        }

        this.dividerBuilder();

        Column() {
          Row() {
            Text('支付方式').labelTextStyle()
            Text(this.vm.hotelOrderItem.payMethod).detailTextStyle()
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          this.dividerBuilder();
          Row() {
            Text('订单编号').labelTextStyle()
            Text(this.vm.hotelOrderItem.orderNo).detailTextStyle()
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          this.dividerBuilder();
          Row() {
            Text('下单时间').labelTextStyle()
            Text(this.vm.hotelOrderItem.createTime).detailTextStyle()
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          this.dividerBuilder();

          Row() {
            Text('总价').labelTextStyle()
            Text(`¥${this.vm.hotelOrderItem.actualPaidPrice}`)
              .detailTextStyle()
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .padding($r('app.string.padding_xs'))
      }
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.string.padding_m'),
        bottom: $r('app.string.padding_m'),
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
      })
      .borderRadius($r('app.string.border_radius_16'))
      .alignItems(HorizontalAlign.Start)
    }
  }

  @Builder
  checkInInfoCardBuilder() {
    if (this.vm.hotelOrderItem) {
      Column() {
        Text('入住人信息')
          .fontSize($r('app.string.font_size_32'))
          .fontWeight(500)

        this.dividerBuilder();
        ForEach(this.vm.hotelOrderItem.checkInList, (item: CheckInItem) => {
          Column({ space: '8lpx' }) {
            Row() {
              Text('入住人').labelTextStyle()
              Text(item.checkInName).detailTextStyle()
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Text('联系电话').labelTextStyle()
              Text(item.checkInTel).detailTextStyle()
            }
            .width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
          .width('100%')
        }, (item: CheckInItem) => JSON.stringify(item))
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor(Color.White)
      .padding({
        top: $r('app.string.padding_m'),
        bottom: $r('app.string.padding_s'),
        left: $r('app.string.padding_s'),
        right: $r('app.string.padding_s'),
      })
      .borderRadius($r('app.string.border_radius_16'))
    }
  }

  @Builder
  dividerBuilder() {
    Divider().color($r('app.color.system_color_grey_level1'))
      .margin({
        top: $r('app.string.margin_s'),
        bottom: $r('app.string.margin_m'),
      })
  }
}

@Extend(Text)
function labelTextStyle() {
  .fontColor($r('app.color.icon_color_level3'))
  .margin({ bottom: $r('app.string.margin_s') })
  .fontSize($r('app.string.font_size_28'));
}

@Extend(Text)
function detailTextStyle() {
  .margin({ bottom: $r('app.string.margin_s') })
  .fontSize($r('app.string.font_size_28'));
}

@Extend(Text)
function highlightTextStyle() {
  .fontSize($r('app.string.font_size_32'))
  .fontColor($r('app.color.system_color_highlight'))
  .fontWeight(500);
}