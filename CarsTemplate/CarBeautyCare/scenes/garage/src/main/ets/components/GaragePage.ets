import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib';
import { SettingCard } from './SettingCard'
import { VehicleVM } from '../model/VehicleVM'
import { promptAction } from '@kit.ArkUI'
import { CarKeyboard } from '@ohos_agcit/car_beauty_care_keyboard'

@Builder
export function GaragePageBuilder() {
  GaragePage();
}

@ComponentV2
struct GaragePage {
  scroller: Scroller = new Scroller();
  vehicleVM: VehicleVM = VehicleVM.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  topRectHeight: number = 0;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    if (this.vehicleVM.vehicle !== null) {
      this.vehicleModel = this.vehicleVM.vehicle.vehiclemode || '';
      this.mileage = this.vehicleVM.vehicle.mileage || '';
      this.roadTime = this.vehicleVM.vehicle.roadtime || '';
      this.vin = this.vehicleVM.vehicle.identifynumber || '';
      this.engineNumber = this.vehicleVM.vehicle.engine || '';
      this.licenseElement = this.vehicleVM.vehicle.license?.split('') || [];
    }
  }

  @Monitor('vehicleVM.vehicle')
  changeDate() {
    if (this.vehicleVM.vehicle === null) {
      this.vehicleModel = '';
      this.mileage = '';
      this.roadTime = '';
      this.vin = '';
      this.engineNumber = '';
      this.licenseElement = [];
    }
  }

  @Local licenseElement:string[] = []; // 车牌号输入框的值
  @Local vehicleModel: string = ''; // 车辆型号
  @Local mileage: string = ''; // 当前里程
  @Local roadTime: string = ''; // 上路时间
  @Local vin: string = ''; // 车辆识别号
  @Local engineNumber: string = ''; // 发动机号

  saveCarMessage() {
    this.vehicleVM.updateCarMessage(this.licenseElement.join(''),this.vehicleModel,this.mileage,this.roadTime,this.vin,this.engineNumber)
    promptAction.showToast({message:$r('app.string.saveSuccess')})
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          if (this.vehicleVM.vehicle === null) {
            Column() {
              Image($r('app.media.ic_car_setting'))
                .width(64)
                .height(64)
                .margin({
                  bottom:8
                })
              Button($r('app.string.addLoveCar'))
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
                .onClick(() => {
                  this.appPathStack.pushPathByName('carSelect', true)
                })
            }
            .width(CommonConstants.FULL_WIDTH)
            .height(187)
            .borderRadius(16)
            .backgroundColor(Color.White)
            .justifyContent(FlexAlign.Center)
          } else {
            SettingCard()

            Row() {
              Text($r('app.string.basicInfo'))
                .fontSize(18)
                .fontFamily($r('app.string.font_regular'))
                .fontWeight(FontWeight.Bold);


              Text($r('app.string.completeInfo'))
                .fontSize(14)
                .fontColor(Color.Gray)
                .margin({ left: 8 });
            }
            .width(CommonConstants.FULL_WIDTH)
            .margin({ top: 4 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .margin({
              top:26,
              bottom:16
            })

            Column() {
              Column() {
                Text($r('app.string.licenseNum'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
                  .fontFamily($r('app.string.font_regular'))
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .margin({ bottom: 4, left: 1 });

                CarKeyboard({
                  keyboardHeight: 300,
                  licenseElement: this.licenseElement,
                  changeLicense:(index:number, element:string) => {
                    this.licenseElement[index] = element;
                  }
                })
              }
              .width(CommonConstants.FULL_WIDTH)
              .margin({ bottom: 8 })
              .alignItems(HorizontalAlign.Start);


              Divider()
                .strokeWidth(1)
                .color('#F1F3F5');


              Column() {
                Text($r('app.string.vehicleModel'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
                  .fontFamily($r('app.string.font_regular'))
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .margin({ bottom: 4 });

                TextInput({ placeholder: $r('app.string.writeVehicleModel'), text: this.vehicleModel})
                  .height(30)
                  .placeholderFont({ size: 14 })
                  .padding(0)
                  .backgroundColor(Color.White)
                  .onChange((val:string) => {
                    this.vehicleModel = val;
                  })
              }
              .height(30)
              .width(CommonConstants.FULL_WIDTH)
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 8 });


              Divider()
                .strokeWidth(1)
                .color('#F1F3F5')
                .margin({ top: 20 });

              Column() {
                Text($r('app.string.mileagekm'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .margin({ bottom: 4 });

                TextInput({ placeholder: $r('app.string.mileageInput'), text: this.mileage})
                  .height(30)
                  .placeholderFont({ size: 14 })
                  .padding(0)
                  .backgroundColor(Color.White)
                  .onChange((val:string) => {
                    this.mileage = val;
                  })
              }
              .height(30)
              .width(CommonConstants.FULL_WIDTH)
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 8 });


              Divider()
                .strokeWidth(1)
                .color('#F1F3F5')
                .margin({ top: 24 });

              Column() {
                Text($r('app.string.roadTime'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .margin({ bottom: 4 });

                TextInput({ placeholder: $r('app.string.roadTimeInput'), text: this.roadTime})
                  .height(30)
                  .placeholderFont({ size: 14 })
                  .padding(0)
                  .backgroundColor(Color.White)
                  .onChange((val:string) => {
                    this.roadTime = val;
                  })
              }
              .height(30)
              .width(CommonConstants.FULL_WIDTH)
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 8 });


              Divider()
                .strokeWidth(1)
                .color('#F1F3F5')
                .margin({ top: 24 });

              Column() {
                Text($r('app.string.identifyNumber'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .margin({ bottom: 4 });

                TextInput({ placeholder: $r('app.string.identifyNumber'), text: this.vin })
                  .height(30)
                  .placeholderFont({ size: 14 })
                  .padding(0)
                  .backgroundColor(Color.White)
                  .onChange((val:string) => {
                    this.vin = val;
                  })
              }
              .height(30)
              .width(CommonConstants.FULL_WIDTH)
              .alignItems(HorizontalAlign.Start)
              .margin({ bottom: 8 });

              Divider()
                .strokeWidth(1)
                .color('#F1F3F5')
                .margin({ top: 24 });

              Column() {
                Text($r('app.string.engineNum'))
                  .fontSize(12)
                  .fontColor('rgba(0,0,0,0.6)')
                  .fontWeight(FontWeight.Regular)
                  .lineHeight(22)
                  .margin({ bottom: 4 });

                TextInput({
                  placeholder: $r('app.string.engineNumInput'),
                  text: this.engineNumber,
                })
                  .height(30)
                  .placeholderFont({ size: 14 })
                  .padding(0)
                  .backgroundColor(Color.White)
                  .onChange((val:string) => {
                    this.engineNumber = val;
                  })
              }
              .height(30)
              .width(CommonConstants.FULL_WIDTH)
              .alignItems(HorizontalAlign.Start)

              Divider()
                .strokeWidth(1)
                .color('#F1F3F5')
                .margin({ top: 24 })
            }
            .width(CommonConstants.FULL_WIDTH)
            .padding(10)
            .backgroundColor(Color.White)
            .borderRadius(16)

            Button($r('app.string.save'))
              .width(CommonConstants.FULL_WIDTH)
              .height(40)
              .margin({ top: 10, bottom: 10 })
              .fontColor(Color.White)
              .backgroundColor($r('app.color.lightRed'))
              .fontSize(16)
              .fontWeight(FontWeight.Regular)
              .onClick(() => {
                this.saveCarMessage()
              })
          }
        }
        .width(CommonConstants.FULL_WIDTH)
        .height(CommonConstants.FULL_WIDTH)
        .padding(16)
      }
      .edgeEffect(EdgeEffect.Spring)
    }
    .title('添加车辆')
    .linearGradient({
      angle: 180,
      colors: [['#D0E1F5', 0], ['#F1F3F5', 1]],
    })
    .margin({
      top: px2vp(this.topRectHeight),
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    });

  }
}