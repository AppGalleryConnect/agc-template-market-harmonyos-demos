import { ShowCardView, ShopCardModel } from '@ohos_agcit/car_beauty_care_shop'
import { AppointmentVM } from '../mode/AppointmentVM'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'

@Builder
export function AppointSuccessBuilder() {
  AppointSuccess()
}

@ComponentV2
export struct AppointSuccess {
  appointmentVM: AppointmentVM = AppointmentVM.instance;
  topRectHeight: number = 0;
  @Local appointTime: string = '';
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Styles
  cardStyle() {
    .backgroundColor(Color.White)
    .borderRadius(16)
    .padding(12)
    .width(CommonConstants.FULL_WIDTH)
  }

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.setAppointTime()
  }

  setAppointTime() {
    const data = this.appointmentVM.selectedData.date.date.split('.');
    this.appointTime = `${data[0]}月${data[1]}日`

  }

  build() {
    NavDestination() {
      Column({space:12}) {
        Column() {
          Image($r('app.media.ic_success'))
            .width(48)
            .height(48)
            .fillColor('#89CB83')

          Text($r('app.string.reserve_success'))
            .fontSize(16)
            .fontColor('rgba(0,0,0,0.9)')
            .lineHeight(21)
            .margin({
              bottom:8
            })

          Text($r('app.string.arrive_early'))
            .fontSize(12)
            .fontColor('rgba(0,0,0,0.4)')
            .textAlign(TextAlign.Center)
        }
        .cardStyle()
        .padding({
          top:24,
          left:12,
          right:12,
          bottom:12
        })

        Column({space:12}) {
          Row() {
            Text('预约时间')
              .fontSize(12)
              .fontColor('rgba(0,0,0,0.9)')
            Blank()
            Text(`${this.appointTime} ${this.appointmentVM.selectedData.time.label}`)
              .fontSize(12)
              .fontColor('rgba(0,0,0,0.6)')
          }
          .width(CommonConstants.FULL_WIDTH)
          Row() {
            Text($r('app.string.reserve_project'))
              .fontSize(12)
              .fontColor('rgba(0,0,0,0.9)')
            Blank()
            Text('保养')
              .fontSize(12)
              .fontColor('rgba(0,0,0,0.6)')
          }
          .width(CommonConstants.FULL_WIDTH)
        }
        .cardStyle();

        Column() {
          Text($r('app.string.reserve_shop'))
            .fontSize(18)
            .fontColor('rgba(0,0,0,0.9)')
            .margin({
              bottom: 16
            })
          ShowCardView({
            card: this.appointmentVM.selectedData.card,
            showMark:false,
            imgRect:72,
            showLine: true
          })
        }
        .cardStyle()
        .alignItems(HorizontalAlign.Start)
        .padding({
          top:24,
          left:12,
          right:12,
          bottom:12
        })
      }
      .margin(16)
    }
    .title('预约')
    .backgroundColor('#F1F3F5')
    .margin({
      top: px2vp(this.topRectHeight)
    })
  }
}