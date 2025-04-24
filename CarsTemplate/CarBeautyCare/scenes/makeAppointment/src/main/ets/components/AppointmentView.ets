import { ShowCardView, LocationVM ,ShopCardModel} from '@ohos_agcit/car_beauty_care_shop'
import { AddCar } from '@ohos_agcit/car_beauty_care_componentlib'
import { AppointmentCard } from './AppointmentCard'
import { AppointmentVM } from '../mode/AppointmentVM'
import { BTN_TYPE } from '../mode/AppointmentModel'
import { PromptAction } from '@kit.ArkUI'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function AppointmentViewBuilder() {
  AppointmentView()
}

@ComponentV2
struct AppointmentView {
  private uiContext: UIContext = this.getUIContext()
  private promptAction: PromptAction = this.uiContext.getPromptAction()
   locationVM: LocationVM = LocationVM.instance;
   appointmentVM: AppointmentVM = AppointmentVM.instance;
   scroller: Scroller = new Scroller();
   @Local shopCardList:ShopCardModel[] = this.locationVM.shopCardList;
   @Consumer('appPathStack') appPathStack:NavPathStack = new NavPathStack();
   @Styles
   imgStyle() {
     .height(16)
     .width(16)
     .margin({
       right:4
     })
   }

   @Styles
   btnStyle() {
     .height(28)
     .width(72)
     .borderRadius(14)
   }

   @Local selectType: BTN_TYPE = BTN_TYPE.MAINTENANCE;
  topRectHeight: number = 0;

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.initShopCardData();
  }
  initShopCardData() {
    this.shopCardList = this.locationVM.shopCardList.filter((item:ShopCardModel) => {
        return item.mark.indexOf(this.selectType) !== -1
    })
    this.shopCardList = [...this.shopCardList]
    this.appointmentVM.setShowSubmitBtn(false);
    this.appointmentVM.updateSelectedType(this.selectType)
  }

   build() {
     NavDestination() {
       Stack({ alignContent: Alignment.Bottom }) {
         Column() {
           Row() {
             Row() {
               Image($r('app.media.ic_appointment'))
                 .imgStyle()

               Text($r('app.string.reserve_project'))
                 .fontSize(12)
                 .fontColor('rgba(0,0,0,0.9)')
             }
             Text('>>')
             Row() {
               Image($r('app.media.ic_repair_border'))
                 .imgStyle()

               Text($r('app.string.shop_service'))
                 .fontSize(12)
                 .fontColor('rgba(0,0,0,0.9)')
             }
             Text('>>')

             Row() {
               Image($r('app.media.ic_success'))
                 .imgStyle()

               Text($r('app.string.pay_done'))
                 .fontSize(12)
                 .fontColor('rgba(0,0,0,0.9)')
             }
           }
           .width(CommonConstants.FULL_WIDTH)
           .justifyContent(FlexAlign.SpaceEvenly)
           .margin({
             top: 16
           })

           AddCar()
             .margin(16)

           Row() {
             Button(BTN_TYPE.MAINTENANCE)
               .btnStyle()
               .fontSize(12)
               .fontColor(this.selectType === BTN_TYPE.MAINTENANCE?'#fff':'rgba(0,0,0,0.9)')
               .backgroundColor(this.selectType === BTN_TYPE.MAINTENANCE?'#EE3B55':'rgba(0,0,0,0.05)')
               .onClick(() => {
                 this.selectType = BTN_TYPE.MAINTENANCE;
                 this.initShopCardData()
               })
             Button(BTN_TYPE.REPAIRS)
               .btnStyle()
               .fontSize(12)
               .fontColor(this.selectType === BTN_TYPE.REPAIRS?'#fff':'rgba(0,0,0,0.9)')
               .backgroundColor(this.selectType === BTN_TYPE.REPAIRS?'#EE3B55':'rgba(0,0,0,0.05)')
               .onClick(() => {
                 this.selectType = BTN_TYPE.REPAIRS;
                 this.initShopCardData()
               })
             Button(BTN_TYPE.TIRE)
               .btnStyle()
               .fontSize(12)
               .fontColor(this.selectType === BTN_TYPE.TIRE?'#fff':'rgba(0,0,0,0.9)')
               .backgroundColor(this.selectType === BTN_TYPE.TIRE?'#EE3B55':'rgba(0,0,0,0.05)')
               .onClick(() => {
                 this.selectType = BTN_TYPE.TIRE;
                 this.initShopCardData()
               })
             Button(BTN_TYPE.BEAUTY)
               .btnStyle()
               .fontSize(12)
               .fontColor(this.selectType === BTN_TYPE.BEAUTY?'#fff':'rgba(0,0,0,0.9)')
               .backgroundColor(this.selectType === BTN_TYPE.BEAUTY?'#EE3B55':'rgba(0,0,0,0.05)')
               .onClick(() => {
                 this.selectType = BTN_TYPE.BEAUTY;
                 this.initShopCardData();
               })
           }
           .width(CommonConstants.FULL_WIDTH)
           .justifyContent(FlexAlign.SpaceEvenly)
           .backgroundColor('transparent')
           .padding({
             bottom:12
           })

           Column() {
             Text($r('app.string.time_choose'))
               .fontSize(18)
               .fontColor('rgba(0,0,0,0.9)')
               .fontWeight(FontWeight.Bold)
               .margin({
                 bottom:16,
                 left:16,
                 right: 16
               })

             List({space:12, scroller: this.scroller}) {
               ForEach(this.shopCardList,(item:ShopCardModel) => {
                 ListItem() {
                   AppointmentCard({card:item})
                 }
               })
             }
             .padding({
               left:16,
               right:16
             })
           }
           .backgroundColor(Color.White)
           .width(CommonConstants.FULL_WIDTH)
           .borderRadius({
             topLeft: 16,
             topRight: 16
           })
           .padding({
             top:24,
             bottom: 24,
           })
           .layoutWeight(1)
           .alignItems(HorizontalAlign.Start)
         }
         .height(CommonConstants.FULL_WIDTH)

         if (this.appointmentVM.showSubmitBtn) {
           Row() {
             Text('')
               .width(16)
             Row() {
               Column() {
                 Text(`保养 ${this.appointmentVM.selectedData.date.date}(${this.appointmentVM.selectedData.date.label}) ${this.appointmentVM.selectedData.time.label}`)
                   .fontColor(Color.White)
                   .fontSize(12)
                 Text(`${this.appointmentVM.selectedData.card.name}`)
                   .fontColor(Color.White)
                   .fontSize(12)
               }
               .alignItems(HorizontalAlign.Start)
               .margin({
                 left:16
               })

               Button($r('app.string.reserve_immediately'))
                 .backgroundColor('#EE3B55')
                 .height(CommonConstants.FULL_WIDTH)
                 .onClick(() => {
                   if (this.appointmentVM.makeAppointOrder()) {
                     this.appPathStack.pushPathByName('appointSuccess', true)
                   } else {
                     this.promptAction.showToast({
                       message: $r('app.string.reserve_already'),
                       duration: 2000
                     });
                   }
                 })

             }
             .justifyContent(FlexAlign.SpaceBetween)
             .width(CommonConstants.FULL_WIDTH)
             .height(40)
             .backgroundColor('rgba(0,0,0,0.9)')
             .borderRadius(20)
             .layoutWeight(1)
             Text('')
               .width(16)
           }
           .width(CommonConstants.FULL_WIDTH)
           .margin({
             bottom:30
           })
         }
       }

    }
    .title('免费预约')
     .margin({
       top: px2vp(this.topRectHeight)
     })
     .onBackPressed(() => {
       this.appPathStack.pop();
       return true;
     })
     .linearGradient({
       angle:135,
       colors:[['#D2E2F5', 0.0], ['#F1F3F5', 0.4]]
     })

  }
}
