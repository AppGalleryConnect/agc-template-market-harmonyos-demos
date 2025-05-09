import {
  AppRouter,
  CommonFuncResult,
  Constants,
  DataStorage,
  DayFormat,
  generateRandomFlightTime,
  getDayLabel,
  ItineraryApi,
  OrderApi,
  OrderInfo,
  Trip,
} from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { MinePageModel, PayTypeData, SpaceType } from '../model/MinePageModel';
import { Decimal } from '@kit.ArkTS';
import { BaseTitle, GlobalDialog } from 'components';

@Builder
export function payPageBuilder() {
  PayPage()
}

@ComponentV2
export struct PayPage {
  // 应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!;
  // 支付方式
  @Local payTypeList: PayTypeData[] = MinePageModel.getPayTypeList();
  // 选择的支付方式
  @Local selectedPay: PayTypeData = this.payTypeList[0];
  // 订单信息
  @Local orderData: OrderInfo = new OrderInfo();

  onBackEvent() {
    GlobalDialog.showDialogForPayOrder({
      exit: () => {
        GlobalDialog.close();
        AppRouter.clear();
      },
      pay: () => {
        GlobalDialog.close();
      },
    });
  }

  payOrder() {
    // 需要根据业务实现支付
    this.orderData.status = 2;
    OrderApi.payOrder(this.orderData).then((res) => {
      let result = res.result as CommonFuncResult;
      if (result.ret.code === 0) {
        if (result.result) {
          // 添加行程
          this.addTrip();
          GlobalDialog.showToast('支付成功');
          AppRouter.clear();
        }
      }
    });
  }

  // 添加行程
  addTrip() {
    // 模拟生成行程信息
    let ags: number[] = [0.2, 0.5, 0.8, 1.0, 1.1, 1.5, 2.0, 2.3];
    let data = {
      id: 'tripId_' + new Date().getTime(),
      flightNo: this.orderData.flightNo,
      airlineName: this.orderData.airlineName,
      aircraftType: this.orderData.aircraftType,
      aircraftAge: ags[Math.floor(Number(Decimal.random()) * 8)] + '年',
      flyMiles: `${Math.floor(Number(Decimal.random()) * (20000 - 1000 + 1)) + 1000}公里`,
      flyDuration: generateRandomFlightTime(),
      planTakeoffTime: this.orderData.takeoffTime,
      planLandingTime: this.orderData.landingTime,
      departureCity: this.orderData.departureCity,
      departureAirport: this.orderData.departureAirport,
      destinationCity: this.orderData.destinationCity,
      destinationAirport: this.orderData.destinationAirport,
      mealType: this.orderData.mealType,
      spaceType: this.orderData.spaceType,
      includeTaxPrice: this.orderData.includeTaxPrice,
      ticketNo: 'ticketNo_' + new Date().getTime(),
      status: '1',
    } as Trip;
    ItineraryApi.addTrip(data).then((res) => {
    });
  }

  // 获取价格
  getTotalPrice(): string {
    let price = (JSON.parse(this.orderData.passengerList ?? '[]')).length *
      (this.orderData.includeTaxPrice + this.orderData.airportConstructionPrice + this.orderData.fuelPrice);
    return price + '';
  }

  // 提示支付信息
  getPayTip() {
    let time = new Date()
    if (this.dataStorage.payOrderTime) {
      time = new Date(this.dataStorage.payOrderTime)
    } else {
      let now = new Date().getTime();
      time = new Date(now + Constants.PAY_COUNT_DOWN)
    }
    let payDate = new DayFormat(time).format('HH:mm')
    return `${payDate}`
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '订单支付',
          showBackBtn: true,
          bgColor: $r('sys.color.white'),
          onBack: () => {
            this.onBackEvent()
          },
        })

        List({ space: 20 }) {
          ListItem() {
            Column({ space: 20 }) {
              Text(Constants.RMB + this.getTotalPrice())
                .fontSize(20)
                .fontColor('#E84026')
                .fontWeight(FontWeight.Medium)
                .margin({ top: 30 })

              Text() {
                Span('请在 ').fontColor('#99000000')
                Span(this.getPayTip()).fontColor('#E84026')
                Span(' 前支付，超时订单将取消').fontColor('#99000000')
              }
              .fontSize(14)
              .fontWeight(FontWeight.Regular)

              Column({ space: 8 }) {
                Row({ space: 4 }) {
                  Text(this.orderData.departureAirport).fontSize(14).fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontWeight(FontWeight.Regular)
                  Image($r('app.media.ic_goto')).width(16).height(16)
                  Text(this.orderData.destinationAirport).fontSize(14).fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontWeight(FontWeight.Regular)
                }

                Row({ space: 6 }) {
                  Text(new DayFormat(new Date(this.orderData.takeoffTime)).format('YYYY-MM-DD'))
                    .fontSize(14).fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  Text(getDayLabel(new Date(this.orderData.takeoffTime)))
                    .fontSize(14).fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  Text(new DayFormat(new Date(this.orderData.takeoffTime)).format('HH:mm'))
                    .fontSize(14).fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                }

                Row({ space: 6 }) {
                  Text(this.orderData.airlineName).fontSize(10).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                    .fontWeight(FontWeight.Medium)
                  Text(this.orderData.flightNo).fontSize(10).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                    .fontWeight(FontWeight.Medium)
                  Text(this.orderData.aircraftType).fontSize(10).fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                    .fontWeight(FontWeight.Medium)
                  Text(SpaceType[this.orderData.spaceType])
                    .fontSize(10).fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                }
              }
              .width('100%')
              .padding(12)
              .backgroundColor($r('sys.color.white'))
              .alignItems(HorizontalAlign.Start)
              .borderRadius(16)

              Column() {
                ForEach(this.payTypeList, (item: PayTypeData) => {
                  Row() {
                    Row({ space: 10 }) {
                      Image(item.icon).width(20).height(20);
                      Text(item.label);
                    };

                    if (this.selectedPay.type === item.type) {
                      Image($r('app.media.ic_checked')).width(20).height(20);
                    } else {
                      Image($r('app.media.ic_radio_unselect')).width(20).height(20);
                    }
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween)
                  .padding({ top: 14, bottom: 14 })
                  .onClick(() => {
                    this.selectedPay = item;
                  });
                });
              }
              .width('100%')
              .padding({ left: 14, right: 14 })
              .backgroundColor($r('sys.color.white'))
              .alignItems(HorizontalAlign.Start)
              .borderRadius(16);
            }
            .margin({bottom: 20})
            .justifyContent(FlexAlign.Start)
          }

          ListItem() {
            Button({ type: ButtonType.Capsule, stateEffect: true }) {
              Text('立即支付').fontSize(16).fontColor($r('sys.color.white')).fontWeight(FontWeight.Medium)
            }
            .padding(12)
            .width('100%')
            .backgroundColor('#476CFA')
            .onClick(() => {
              this.payOrder();
            })
          }
          .position({left: 0, bottom: 0})
        }
        .width(Constants.FULL_PERCENT_WIDTH)
        .layoutWeight(1)
        .padding({ left: 14, right: 14 })
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.None)
      }
      .width('100%')
      .height('100%')
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.gray_01'))
    .onReady((cxt) => {
      this.orderData = cxt.pathInfo.param as OrderInfo;
    })
    .onBackPressed((): boolean => {
      this.onBackEvent();
      return true;
    });
  }
}