import {
  CommonFuncResult,
  Constants,
  DataStorage,
  formatMMDD,
  getDayLabel,
  LoadingStatus,
  maskCertificate,
  maskPhone,
  OrderApi,
  OrderListResult,
  OrderInfo,
  PassengerInfo,
  pasteText,
  CardMap,
  AppRouter,
  DayFormat,
} from 'common';
import { AppStorageV2 } from '@kit.ArkUI';
import { BaseTitle, GlobalDialog } from 'components';

@Builder
export function orderDetailPageBuilder() {
  OrderDetailPage()
}

@ComponentV2
export struct OrderDetailPage {
  // 应用全局UI状态存储
  @Local dataStorage: DataStorage = AppStorageV2.connect(DataStorage, 'DataStorage', () => new DataStorage())!;
  @Local loadingStatus: LoadingStatus = LoadingStatus.OFF;
  // 滚动距离
  @Local scrollY: number = 0;
  private offsetValue: number = 0;
  // 订单编号
  @Local orderNo: string = '';
  // 订单详情信息
  @Local orderDetail: OrderInfo = new OrderInfo();
  // 订单状态
  @Local orderStatus: number = -1;
  // 订单支付的最迟时间
  @Local payOrderTime: string = '';
  // 订单支付倒计时
  @Local payCountdown: number = 0;
  private textTimerController: TextTimerController = new TextTimerController();
  @Local textTimerFormat: string = 'mm:ss';
  // 乘机人信息
  @Local passengerList: PassengerInfo[] = [];
  private orderStatusLabel: string[] = [
    '已取消', '待出行', '待出票', '已出票', '退改票',
  ];

  getOrderDetail() {
    this.loadingStatus = LoadingStatus.LOADING;
    GlobalDialog.showLoadingDialog();
    OrderApi.getOrderDetail(this.orderNo).then((res) => {
      let result = res.result as OrderListResult;
      if (result.ret.code === 0) {
        if (result.result.length) {
          this.orderDetail = result.result[0];
          this.orderStatus = this.orderDetail.status;
          this.passengerList = JSON.parse(this.orderDetail.passengerList) as PassengerInfo[];
        }
        // 获取订单支付倒计时，模拟支付倒计时取消订单
        this.getPayCountDown();
      }
    }).finally(() => {
      this.loadingStatus = LoadingStatus.SUCCESS;
      GlobalDialog.close();
    });
  }

  getPayCountDown() {
    let now = new Date().getTime();
    let payOrderTime = new Date(this.dataStorage.payOrderTime).getTime();
    this.payCountdown = payOrderTime - now;
    // 如果小于15分钟，则可以支付，否则取消支付
    if (this.payCountdown >= Constants.PAY_COUNT_DOWN) {
      this.cancelOrder();
    }
  }

  // 获取状态对应的不同文案
  getStatusSubText(): string {
    if (this.orderStatus === 0) {
      return '订单已取消，如需出行请重新预订';
    }
    if (this.orderStatus === 1) {
      let downTime = new DayFormat(new Date(this.dataStorage.payOrderTime)).format('HH:mm')
      return `因航班价格变动频繁，请尽快在${downTime}前完成支付，否则订单将被取消`;
    }
    if (this.orderStatus === 2) {
      return '正在出票中';
    }
    if (this.orderStatus === 3) {
      return '如无法出行，请及时进行退票';
    }
    return '';
  }

  // 获取价格
  getPrice(): number {
    let price = this.passengerList.length *
      (this.orderDetail.includeTaxPrice + this.orderDetail.airportConstructionPrice + this.orderDetail.fuelPrice);
    return price;
  }

  // 获取出发日期是星期几
  getWeekDay(): string {
    return `${getDayLabel(new Date(this.orderDetail.takeoffTime))}`;
  }

  // 取消订单
  cancelOrder(showToast: boolean = true) {
    this.orderDetail.status = 0;
    OrderApi.cancelOrder(this.orderDetail).then((res) => {
      let result = res.result as CommonFuncResult;
      if (result.ret.code === 0) {
        if (result.result) {
          this.orderStatus = 0;
          if (showToast) {
            GlobalDialog.showToast('取消成功');
          }
        }
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        BaseTitle({
          title: '订单详情',
          showBackBtn: true,
          scrollY: this.scrollY,
          isScrollY: true,
          bgColor: '#007DFF',
          onBack: () => {
            AppRouter.pop();
          },
        });
        Scroll() {
          if (this.loadingStatus === LoadingStatus.SUCCESS) {
            Stack({ alignContent: Alignment.Top }) {
              Image($r('app.media.ic_order_bg')).width('100%').height(140).objectFit(ImageFit.Fill);
              Column({ space: 14 }) {
                Text(this.orderStatusLabel[this.orderStatus])
                  .fontSize(18).fontColor($r('sys.color.white')).fontWeight(600)
                  .visibility(this.orderStatusLabel[this.orderStatus] ? Visibility.Visible : Visibility.Hidden);
                Text(this.getStatusSubText())
                  .fontSize(12).fontColor($r('sys.color.white')).fontWeight(400);

                Column({ space: 14 }) {
                  Row() {
                    Text() {
                      Span('在线支付');
                      Span(' ');
                      Span(Constants.RMB + this.getPrice()).fontColor(Color.Red);
                    }.fontWeight(600);

                    Row() {
                      Text('费用明细').fontColor('#cc007dff').fontWeight(400).fontSize(13);
                      Image($r('app.media.ic_right_arrow')).width(14).height(14).fillColor('#cc007dff');
                    }
                    .onClick(() => {
                      GlobalDialog.showDialogForCostDetail({
                        title: '费用明细',
                        totalCost: String(this.getPrice()),
                        taxPrice: this.orderDetail.includeTaxPrice + '',
                        airportConstructionPrice: this.orderDetail.airportConstructionPrice + '',
                        fuelPrice: this.orderDetail.fuelPrice + '',
                        passengerNum: (JSON.parse(this.orderDetail.passengerList) ?? []).length,
                      });
                    });
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.SpaceBetween);

                  Row({ space: 6 }) {
                    Text('订单编号').fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontSize(13);
                    Text(this.orderNo).fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontSize(13);
                    Image($r('app.media.ic_copy')).width(14).height(14)
                      .onClick(() => {
                        // 复制订单编号
                        pasteText(this.orderNo);
                      });
                  };

                  if (this.orderStatus === 1) {
                    Row({ space: 10 }) {
                      Button({ type: ButtonType.Normal, stateEffect: true }) {
                        Column() {
                          Text('去支付').fontSize(12).fontColor($r('sys.color.white')).fontWeight(400);
                          TextTimer({
                            isCountDown: true,
                            count: this.payCountdown,
                            controller: this.textTimerController,
                          })
                            .format(this.textTimerFormat)
                            .fontColor($r('sys.color.white'))
                            .fontSize(10)
                            .onTimer((utc: number, elapsedTime: number) => {
                              let count = Math.floor(this.payCountdown / 1000);
                              if (count === elapsedTime) {
                                this.textTimerController.pause();
                                this.cancelOrder(false);
                              }
                            })
                            .onAppear(() => {
                              this.textTimerController.start();
                            });
                        };
                      }
                      .padding({
                        left: 14,
                        top: 6,
                        bottom: 6,
                        right: 14,
                      })
                      .backgroundColor(Color.Red)
                      .borderRadius(4)
                      .onClick(() => {
                        AppRouter.push({
                          url: 'PayPage',
                          param: this.orderDetail
                        })
                      });

                      Button({ type: ButtonType.Normal, stateEffect: true }) {
                        Text('取消订单').fontSize(12).fontColor($r('sys.color.white')).fontWeight(400);
                      }
                      .padding({
                        left: 14,
                        top: 6,
                        bottom: 6,
                        right: 14,
                      })
                      .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
                      .borderRadius(4)
                      .onClick(() => {
                        this.cancelOrder();
                      });
                    };
                  }

                }
                .width('100%')
                .padding(14)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor($r('sys.color.white'))
                .borderRadius(4);

                Column({ space: 14 }) {
                  Row({ space: 6 }) {
                    // 单程
                    Text('单程')
                      .fontSize(10)
                      .fontColor($r('sys.color.white'))
                      .padding({
                        left: 4,
                        right: 4,
                        top: 2,
                        bottom: 2,
                      })
                      .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
                      .borderRadius(3);

                    // 出发日期
                    Text(formatMMDD(this.orderDetail.takeoffTime)).fontSize(12);
                    // 星期几
                    Text(this.getWeekDay()).fontSize(12);

                    // 起降地
                    Text() {
                      Span(this.orderDetail.departureCity);
                      Span(' - ');
                      Span(this.orderDetail.destinationCity);
                    }.fontSize(12);

                    Blank();

                    Text('退改签及行李额').fontColor('#cc007dff').fontWeight(400).fontSize(13);
                  }
                  .width('100%')
                  .justifyContent(FlexAlign.Start)
                  .alignItems(VerticalAlign.Center);

                  Row({ space: 10 }) {
                    Column({ space: 14 }) {
                      Text(new DayFormat(this.orderDetail.takeoffTime).format('HH:mm')).fontSize(13).fontWeight(600);
                      Text(new DayFormat(this.orderDetail.landingTime).format('HH:mm')).fontSize(13).fontWeight(600);
                    };

                    Divider()
                      .vertical(true)
                      .strokeWidth(3)
                      .color($r('sys.color.ohos_id_color_button_divider'))
                      .height(32);

                    Column({ space: 14 }) {
                      Text(this.orderDetail.departureAirport).fontSize(13).fontWeight(600);
                      Text(this.orderDetail.destinationAirport).fontSize(13).fontWeight(600);
                    };
                  };

                  Row({ space: 8 }) {
                    Text(this.orderDetail.airlineName + this.orderDetail.flightNo)
                      .fontSize(10).fontColor('#999');
                    Divider()
                      .vertical(true)
                      .strokeWidth(1)
                      .height(10)
                      .color($r('sys.color.ohos_id_color_button_divider'));
                    Text(this.orderDetail.aircraftType)
                      .fontSize(10).fontColor('#999');
                    Divider()
                      .vertical(true)
                      .strokeWidth(1)
                      .height(10)
                      .color($r('sys.color.ohos_id_color_button_divider'));
                    Text(this.orderDetail.mealType)
                      .fontSize(10).fontColor('#999');
                  };

                  Divider().strokeWidth(0.5).color($r('sys.color.ohos_id_color_button_divider')).width('100%');

                  List({ space: 12 }) {
                    ForEach(this.passengerList, (item: PassengerInfo) => {
                      ListItem() {
                        Column({ space: 6 }) {
                          Text(item.name).fontColor($r('sys.color.ohos_id_color_text_primary')).fontSize(13);
                          Row({ space: 4 }) {
                            Text(CardMap[item.certificateType])
                              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                              .fontSize(12)
                              .fontWeight(400);
                            Text(maskCertificate(item.certificateNo, item.certificateType))
                              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                              .fontSize(12)
                              .fontWeight(400);
                          };

                          Row({ space: 4 }) {
                            Text('手机号')
                              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                              .fontSize(12)
                              .fontWeight(400);
                            Text('+86')
                              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                              .fontSize(12)
                              .fontWeight(400);
                            Text(maskPhone(item.phone))
                              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                              .fontSize(12)
                              .fontWeight(400);
                          };
                        }
                        .width('100%')
                        .alignItems(HorizontalAlign.Start);
                      };
                    });
                  }
                  .width('100%')
                  .constraintSize({ maxHeight: 140 })
                  .scrollBar(BarState.Off);
                }
                .width('100%')
                .padding(14)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor($r('sys.color.white'))
                .borderRadius(4);

                Column({ space: 14 }) {
                  Text('联系人').fontSize(14).fontColor($r('sys.color.ohos_id_color_text_primary'));

                  Column({ space: 4 }) {
                    Text(this.orderDetail.contactName)
                      .fontColor($r('sys.color.ohos_id_color_text_primary'))
                      .fontSize(13);
                    Row({ space: 4 }) {
                      Text('手机号').fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontSize(12).fontWeight(400);
                      Text('+86').fontColor($r('sys.color.ohos_id_color_text_tertiary')).fontSize(12).fontWeight(400);
                      Text(maskPhone(this.orderDetail.contactPhone))
                        .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
                        .fontSize(12)
                        .fontWeight(400);
                    };
                  }
                  .alignItems(HorizontalAlign.Start);
                }
                .width('100%')
                .padding(14)
                .alignItems(HorizontalAlign.Start)
                .backgroundColor($r('sys.color.white'))
                .borderRadius(4);

                Column() {
                  Row() {
                    Image($r('app.media.ic_safe')).width(18).height(18);
                    Text() {
                      Span('安心预订');
                      Span(' ');
                      Span('放心出行');
                    }
                    .fontSize(16)
                    .fontColor($r('sys.color.ohos_id_color_emphasize'))
                    .fontWeight(600);
                  };
                }
                .height(240)
                .width('100%')
                .padding(16);
              }
              .width('100%')
              .padding(14)
              .alignItems(HorizontalAlign.Start);
            };
          }
        }
        .layoutWeight(1)
        .align(Alignment.TopStart)
        .scrollBar(BarState.Off)
        .onWillScroll((xOffset: number, yOffset: number) => {
          this.offsetValue += yOffset;
          this.scrollY = vp2px(this.offsetValue);
        });
      }
      .width('100%')
      .height('100%');
    }
    .hideTitleBar(true)
    .backgroundColor('#fff5f3f3')
    .onReady((cxt) => {
      this.orderNo = cxt.pathInfo.param as string;
    })
    .onWillShow(() => {
      // 获取订单详情
      this.getOrderDetail();
    });
  }
}