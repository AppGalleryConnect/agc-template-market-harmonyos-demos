
import { ShopCardModel } from '../model/ShopModel'
import { BusinessError } from '@kit.BasicServicesKit'
import { call } from '@kit.TelephonyKit'
import { PromptActionClass, CommonModel, CommonConstants, LocateUtil} from '@ohos_agcit/car_beauty_care_commonlib'
import { ComponentContent } from '@kit.ArkUI';
import { LocationVM } from '../model/LocationVM'

@Builder
function callDialog(callPhone:Function) {
  Column() {
    Row() {
      Text($r('app.string.phone_number'))
        .fontSize(16)
        .margin({
          top:24,
        })
    }
    .width(CommonConstants.FULL_WIDTH)
    .justifyContent(FlexAlign.Center)
    Row() {
      Text($r('app.string.phone_call'))
        .onClick(() => {
          callPhone();
          PromptActionClass.closeDialog();
        })
        .width('50%')
        .height(64)
        .fontColor('#EE3B55')
        .fontSize(16)
        .textAlign(TextAlign.Center)
      Text($r('app.string.phone_cancel'))
        .width('50%')
        .height(64)
        .fontSize(16)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          PromptActionClass.closeDialog();
        })
    }
    .width(CommonConstants.FULL_WIDTH)
  }
  .width(328)
  .height(116)
  .borderRadius(32)
  .backgroundColor(Color.White)
}

@ComponentV2
export struct ShowCardView {
  locationVM: LocationVM = LocationVM.instance;
  vm:CommonModel = CommonModel.instance;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();

  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<object> = new ComponentContent(this.ctx,wrapBuilder(callDialog), this.callPhone)
  @Param useShopDetail: boolean = false;
  @Param card: ShopCardModel = this.locationVM.selectShopData;
  @Param showMark: boolean = true;
  @Param imgRect: number = 80;
  @Param showLine: boolean = false;
  @Param showToggle: boolean = false;

  callPhone() {
    // 如果设备支持呼叫能力，则继续跳转到拨号界面，并显示拨号的号码
    call.makeCall('180xxxxxxxx', (err: BusinessError) => {
      if (!err) {
        console.log('make call success.');
      } else {
        console.log('make call fail, err is:' + JSON.stringify(err));
      }
    });
  }

  showCallDialog() {
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({alignment:DialogAlignment.Center,offset:{dx:0, dy:0}})
    PromptActionClass.openDialog();
  }

  build() {
    Row() {
      if (!this.useShopDetail) {
        Image(this.card.coverImg)
          .width(this.imgRect)
          .height(this.imgRect)
          .borderRadius(8)
          .margin({
            right: 12
          })
      }

      Column() {
        Row() {
          Text(this.card.name)
            .fontSize(this.useShopDetail?16:14)
            .fontColor('#000')
            .fontWeight(FontWeight.Medium)

          if (this.showToggle) {
            Image($r('app.media.toggle'))
              .height(16)
              .width(16)
              .margin({
                left:10
              })
              .onClick(() => {
                this.appPathStack.pushPathByName('shop', true)
              })
          }

        }
        .width(CommonConstants.FULL_WIDTH)
        .justifyContent(FlexAlign.Start)

        Row() {
          Text(`${this.card.serviceTimes}单`)
            .fontSize(12)
            .fontColor('#999')
          Row() {
            Image($r('app.media.ic_telephone'))
              .width(24)
              .height(24)
              .onClick(() => {
                this.showCallDialog()
              })

            Image($r('app.media.ic_location'))
              .width(24)
              .height(24)
              .margin({
                left:10
              })
              .onClick(() => {
                this.appPathStack.pushPathByName('shopMap',this.card.location)
              })
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Bottom)
        .width(CommonConstants.FULL_WIDTH)

        Row() {
          Text(this.card.address)
            .fontSize(12)
            .fontColor('#999')
          Blank()
          if (this.vm.allowGetPosition) {
            Text(`${this.card.distance}km`)
              .fontSize(12)
              .fontColor('#999')
          }
        }
        .width(CommonConstants.FULL_WIDTH)
        .margin({
          top:4
        })

        if (this.showMark) {
          Flex({wrap:FlexWrap.Wrap}) {
            ForEach(this.card.mark, (item:string) => {
              Text(item)
                .fontSize(10)
                .fontColor('#000')
                .padding(4)
                .backgroundColor('#F1F3F5')
                .borderRadius(4)
                .layoutWeight(1)
                .margin({
                  right:8,
                  top:8
                })

            })
          }
          .width(CommonConstants.FULL_WIDTH)
        }
        if (this.showLine) {
          Divider()
            .margin({
              top:10
            })
        }
      }
      .layoutWeight(1)
    }
    .width(CommonConstants.FULL_WIDTH)
    .alignItems(VerticalAlign.Top)
    .onClick(() => {
      this.vm.curIndex = 1;
      this.locationVM.updataSelectShop(this.card.id)
      this.appPathStack.clear()
    })
  }
}