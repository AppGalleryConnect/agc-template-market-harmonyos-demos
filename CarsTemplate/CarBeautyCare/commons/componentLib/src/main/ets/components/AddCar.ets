
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'
import { VehicleVM } from '@ohos_agcit/car_beauty_care_garage'

@ComponentV2
export struct AddCar {
  vehicleVM: VehicleVM = VehicleVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  hasDefaultCar: boolean = false;
  build() {
    Row() {
      if (this.vehicleVM.vehicle === null) {
        Image($r('app.media.car'))
          .width(32)
          .height(32)
          .margin({
            right:4
          })
        Text($r('app.string.add_your_car'))
          .fontSize(12)
        Blank()
        Button($r('app.string.add_car'))
          .fontSize(12)
          .height(28)
          .width(72)
          .borderWidth(1)
          .borderColor('#ee3b55')
          .backgroundColor('#fff')
          .fontColor('#ee3b55')
          .padding({
            left:8,
            right:8
          })
          .onClick(()=>{
            this.appPathStack.pushPathByName('carSelect', true)
          })
      } else {
        Row() {
          Image(this.vehicleVM.vehicle.brandingMessage.logoUrl)
            .width(36)
            .height(36)
            .padding(2)
            .margin({
              right:8
            })
          Column() {
            Row() {
              Text(this.vehicleVM.vehicle.brandingMessage.name)
                .fontSize(12)
                .fontColor('#000')
              Image($r('app.media.ic_edit_lined'))
                .height(12)
                .width(12)
            }
            .width(CommonConstants.FULL_WIDTH)
            .justifyContent(FlexAlign.Start)
            Text(this.vehicleVM.vehicle.vehiclemode)
              .fontSize(10)
              .fontColor('#666')
              .margin({
                top:8
              })
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          Blank()
          Image($r('app.media.beautifulcar'))
            .height(30)
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_HEIGHT)
        .onClick(()=>{
          this.appPathStack.pushPathByName('garagePage', true)
        })

      }
    }
    .width(CommonConstants.FULL_WIDTH)
    .height(72)
    .backgroundColor('#fff')
    .borderRadius(16)
    .padding({
      left:12,
      right:12
    })
  }
}