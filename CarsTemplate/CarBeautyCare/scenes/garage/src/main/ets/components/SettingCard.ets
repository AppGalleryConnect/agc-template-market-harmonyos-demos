import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'
import { VehicleVM } from '../model/VehicleVM'

@ComponentV2
export struct SettingCard {
  vehicleVM: VehicleVM = VehicleVM.instance;
  build() {
    Row() {
      Column() {
        Row() {
          Image($r(
            'app.media.delete'))
            .height(16)
            .width(16)
            .margin({
              right:2
            })
          Text('删除')
            .fontSize(12)
            .fontColor('rgba(0,0,0,0.9)')
        }
        .margin({
          bottom:14
        })
        .onClick(() => {
          this.vehicleVM.deleteCar();
        })

        Text(this.vehicleVM.vehicle?.license || '暂无车牌')
          .fontSize(12)
          .fontColor('rgba(0,0,0,0.4)')
          .margin({
            bottom:1
          })

        Text(this.vehicleVM.vehicle?.brandingMessage.name)
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.9)')
      }
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)

      Image($r('app.media.beautifulcar'))
        .width(100)
        .height(100)
        .objectFit(ImageFit.Contain)
        .alignSelf(ItemAlign.End);

    }
    .width(CommonConstants.FULL_WIDTH)
    .height(187)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .alignItems(VerticalAlign.Top)
  }
}