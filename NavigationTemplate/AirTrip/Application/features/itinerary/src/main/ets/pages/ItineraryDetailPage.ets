import { AppRouter, Constants, DayFormat, ItineraryApi, LoadingStatus, Trip, TripListResult } from 'common'
import { BaseTitle, GlobalDialog } from 'components';

@Builder
export function itineraryDetailPageBuilder() {
  ItineraryDetailPage()
}

@ComponentV2
export struct ItineraryDetailPage {
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  // 行程详情
  @Local tripDetail: Trip = new Trip()

  getTripDetail(id: string) {
    GlobalDialog.showLoadingDialog()
    ItineraryApi.getTripDetail(id).then((res) => {
      let result = res.result as TripListResult
      if (result.ret.code === 0) {
        if (result.result?.[0]) {
          this.tripDetail = result.result[0]
        }
      }
    }).finally(() => {
      GlobalDialog.close()
      this.loadingStatus = LoadingStatus.SUCCESS
    })
  }

  // 出发时间
  takeoffTime(): string {
    return this.tripDetail.status === '1' ?
    new DayFormat(this.tripDetail.planTakeoffTime).format('HH:mm') :
    new DayFormat(this.tripDetail.actualTakeoffTime).format('HH:mm')
  }

  // 到达时间
  landingTime(): string {
    return this.tripDetail.status === '1' ?
    new DayFormat(this.tripDetail.planLandingTime).format('HH:mm') :
    new DayFormat(this.tripDetail.actualLandingTime).format('HH:mm')
  }

  getFlyDuration(flight: Trip) {
    let start = new Date(flight.planTakeoffTime).getTime()
    let end = new Date(flight.planLandingTime).getTime()
    let diff = end - start
    const totalMinutes = Math.floor(diff / (1000 * 60));
    const hours = Math.floor(totalMinutes / 60);
    const minutes = totalMinutes % 60;
    return `${hours}h${minutes}min`;
  }

  // 判断是否是次日
  isNextDay(item: Trip): boolean {
    const depDate = new Date(item.planTakeoffTime).toDateString();
    const arrDate = new Date(item.planLandingTime).toDateString();
    return depDate !== arrDate;
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '行程详情',
          showBackBtn: true,
          bgColor: $r('sys.color.white'),
          onBack: () => {
            AppRouter.pop()
          },
        })

        if (this.loadingStatus === LoadingStatus.SUCCESS) {
          Column({ space: 12 }) {
            Column({ space: 8 }) {
              Row({ space: 4 }) {
                Image($r('app.media.ic_air_logo_trans')).width(24).height(24)
                Text(this.tripDetail.airlineName)
                  .fontSize(12).fontWeight(FontWeight.Medium)
                Text(this.tripDetail.flightNo)
                  .fontSize(8).fontWeight(FontWeight.Regular)
                Text(new DayFormat(this.tripDetail.planTakeoffTime).format('YYYY-MM-DD'))
                  .fontSize(8).fontWeight(FontWeight.Regular)

                Text('单程').fontSize(10).fontWeight(FontWeight.Regular)
                  .fontColor($r('sys.color.white'))
                  .padding({left:6, right: 6, top:2, bottom: 2})
                  .backgroundColor('#466DFA')
                  .borderRadius(8)
                  .position({right: 0})
              }
              .width(Constants.FULL_PERCENT_WIDTH)

              Divider().color($r('sys.color.comp_divider')).width('100%')

              Row() {
                Column({ space: 8 }) {
                  Text(this.takeoffTime())
                    .fontSize(16).fontWeight(FontWeight.Medium)
                  Text(this.tripDetail.departureAirport)
                    .fontSize(10).fontWeight(FontWeight.Regular)
                    .fontColor('#99000000')
                }

                Column({ space: 8 }) {
                  Text(this.getFlyDuration(this.tripDetail))
                    .fontSize(8)
                    .fontColor('#466DFA')
                    .backgroundColor('#DAE2FE')
                    .padding({
                      left: 8,
                      right: 8,
                      top: 2,
                      bottom: 2,
                    })
                    .borderRadius(8)
                  Image($r('app.media.ic_flight_tip')).width(60).height(12)
                }

                Column({ space: 8 }) {
                  Row() {
                    Text(this.landingTime())
                      .fontSize(16).fontWeight(FontWeight.Medium)
                    if(this.isNextDay(this.tripDetail)) {
                      Text('次日')
                        .fontSize(8).fontWeight(FontWeight.Medium)
                    }
                  }
                  Text(this.tripDetail.destinationAirport)
                    .fontSize(10).fontWeight(FontWeight.Regular)
                    .fontColor('#99000000')
                }
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceAround)

              Scroll() {
                Row({ space: 8 }) {
                  this.FlyInfoItemView(this.tripDetail.flyMiles)
                  this.FlyInfoItemView(this.tripDetail.flyDuration)
                  this.FlyInfoItemView(this.tripDetail.aircraftType)
                  this.FlyInfoItemView('机龄' + this.tripDetail.aircraftAge)
                }
                .width(Constants.FULL_PERCENT_WIDTH)
                .justifyContent(FlexAlign.SpaceAround)
              }
            }
            .width(Constants.FULL_PERCENT_WIDTH)
            .alignItems(HorizontalAlign.Start)
            .padding(14)
            .backgroundColor($r('sys.color.white'))
            .borderRadius(16)
            .shadow(ShadowStyle.OUTER_DEFAULT_XS)

            Column({ space: 14 }) {
              Row() {
                this.TripTicketInfoItemView('含税票价:', Constants.RMB + this.tripDetail.includeTaxPrice)
                this.TripTicketInfoItemView('舱位等级:',
                  this.tripDetail.spaceType === 'ECONOMY_CLASS' ? '经济舱' : '公务舱')
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                this.TripTicketInfoItemView('座位号:', this.tripDetail.seatNo || '--')
                this.TripTicketInfoItemView('餐食:', this.tripDetail.mealType)
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                this.TripTicketInfoItemView('客票号:', this.tripDetail.ticketNo)
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)

              Row() {
                this.TripTicketInfoItemView('客票状态:', this.tripDetail.status === '1' ? '未使用' : '已使用')
              }
              .width(Constants.FULL_PERCENT_WIDTH)
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width(Constants.FULL_PERCENT_WIDTH)
            .alignItems(HorizontalAlign.Start)
            .padding(14)
            .backgroundColor($r('sys.color.white'))
            .borderRadius(16)
            .shadow(ShadowStyle.OUTER_DEFAULT_XS)
          }
          .width(Constants.FULL_PERCENT_WIDTH)
          .padding({ left: 16, right: 16, top: 24 })
        }
      }
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.gray_01'))
    .onReady((cxt) => {
      let tripData = cxt.pathInfo.param as Trip
      this.getTripDetail(tripData.id)
    })
  }

  @Builder
  FlyInfoItemView(text: string) {
    Text(text)
      .fontSize(10)
      .fontWeight(FontWeight.Regular)
      .padding({
        left: 10,
        right: 10,
        top: 8,
        bottom: 8,
      })
      .backgroundColor('#F1F3F5')
      .borderRadius(16)
  }

  @Builder
  TripTicketInfoItemView(label: string, text: string) {
    Row({ space: 10 }) {
      Text(label)
        .fontSize(12).fontWeight(FontWeight.Medium).fontColor('#99000000')
      Text(text)
        .fontSize(12).fontWeight(FontWeight.Regular)
    }
  }
}