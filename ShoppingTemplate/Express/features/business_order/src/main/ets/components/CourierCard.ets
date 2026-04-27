import { TelUtil } from 'module_base';
import { OrderInfoPageVM } from '../viewModels/OrderInfoPageVM';

@ComponentV2
export struct CourierCard {
  vm: OrderInfoPageVM = OrderInfoPageVM.instance

  build() {
    Column() {
      Column() {
        Row() {
          Row() {
            Image(this.vm.orderInfo?.courier.image ? this.vm.orderInfo?.courier.image : $r('app.media.ic_avatar'))
              .width(48)
              .height(48)
              .borderRadius(24)
              .margin({ right: 4 })
              .flexShrink(0)
            Column() {
              Text(this.vm.orderInfo?.courier?.name ?? '')
                .fontSize(14)
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .margin({ bottom: 5 })
              Text(this.vm.orderInfo?.companyName)
                .fontSize(10)
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_secondary'))
            }
            .height(48)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Center)
          }

          Image($r('app.media.tel'))
            .width(32)
            .height(32)
            .onClick(() => {
              if (this.vm.orderInfo?.courier.cellphone) {
                TelUtil.makeCall('联系快递员', this.vm.orderInfo.courier.cellphone);
              }
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height(68)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
      .padding({
        left: 16,
        right: 16
      })
      .borderRadius(16)
    }
    .padding({
      left: 16,
      right: 16
    })
    .margin({ bottom: 12 })
  }
}