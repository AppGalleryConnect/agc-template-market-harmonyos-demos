import { Constant, Logger } from 'common';
import { FullLoadingComponent, TitleBar } from 'components';
import { GetOrderDetailRequest, https } from 'network';
import { TicketOrderInfo, TouristInfo, cardTypeOptions } from 'types';
import { mapTicketOrderDetail, mapTouristList } from '../mapper/Index';
import { OrderType } from '../model/OrderModuleInfo';
import { TICKET_ORDER_INFO_MAP } from '../model/TicketOrderInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Builder
export function TicketOrderDetailBuilder() {
  TicketOrderDetail();
}

@Extend(Text)
function itemText(opa: number) {
  .fontSize(12).opacity(opa);
}

@Extend(Text)
function itemTitle() {
  .fontSize(14).fontWeight(500).alignSelf(ItemAlign.Start);
}

@Extend(Row)
function itemRow() {
  .width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
}

@Extend(Column)
function itemColumn() {
  .width(Constant.FULL_PERCENT)
  .justifyContent(FlexAlign.SpaceBetween)
  .padding(12)
  .borderRadius(8)
  .backgroundColor(Color.White);
}

@Extend(Button)
function operationBtn(isCancel: boolean) {
  .fontSize(14)
  .fontColor(isCancel ? '#64BB5C' : Color.White)
  .backgroundColor(isCancel ? Color.White : '#64BB5C')
  .border({ width: 1, radius: 20, color: isCancel ? '#64BB5C' : Color.Transparent })
  .width(150)
  .padding(12);
}

@ComponentV2
export struct TicketOrderDetail {
  vm: OrderPageVM = OrderPageVM.instance;
  @Local isLoading: boolean = true;
  @Local ticketOrderInfo: TicketOrderInfo = new TicketOrderInfo();
  @Local touristList: TouristInfo[] = [];
  @Local format: string = 'HH:mm:ss';
  @Local count: number = 0;
  textTimerController: TextTimerController = new TextTimerController();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  getRemainCount() {
    let curStamp = new Date().getTime();
    let createStamp = new Date(this.ticketOrderInfo.orderTime).getTime();
    this.count = createStamp + Constant.MAX_TO_PAY_TIME - curStamp;
    if (this.count < 0) {
      this.modifySilent();
    }
    Logger.info('total count time is ' + this.count);
  }

  modifyOrder(isCancel: boolean) {
    let param: GetOrderDetailRequest = {
      category: 0,
      orderNo: this.ticketOrderInfo.orderNo,
      orderStatus: isCancel ? OrderType.COMPLETED : OrderType.TO_USE,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.mainPathStack.pop();
        if (!isCancel) {
          this.mainPathStack.pushPathByName('PaySuccess', {
            category: 0,
            orderNo: this.ticketOrderInfo.orderNo,
          } as GetOrderDetailRequest);
        } else {
          this.vm.getOrderList();
        }
      }
    });
  }

  modifySilent() {
    this.ticketOrderInfo.orderStatus = OrderType.COMPLETED;
    let param = {
      category: 0,
      orderNo: this.ticketOrderInfo.orderNo,
      orderStatus: this.ticketOrderInfo.orderStatus,
    } as GetOrderDetailRequest;
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        Logger.info('update order status success');
      }
    });
  }

  @Computed
  get statusObj() {
    return TICKET_ORDER_INFO_MAP[this.ticketOrderInfo.orderStatus];
  }

  @Builder
  StatusBarBuilder() {
    Row() {
      Text(this.statusObj?.text)
        .fontSize(24)
        .fontWeight(500)
        .opacity(0.9);

      if (this.ticketOrderInfo.orderStatus === OrderType.TO_PAY && this.count > 0) {
        Row() {
          Text('还有').opacity(0.4).fontSize(12);
          TextTimer({ isCountDown: true, count: this.count, controller: this.textTimerController })
            .format(this.format)
            .fontColor(Color.Black)
            .fontSize(12)
            .fontColor('#E84026')
            .opacity(0.4)
            .onTimer((utc: number, elapsedTime: number) => {
              Logger.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime);
              if ((elapsedTime + 1) * 1000 >= this.count) {
                // 先更新本地,再更新云端
                this.modifySilent();
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            });
          Text('关闭订单').opacity(0.4).fontSize(12);
        };
      } else if (this.ticketOrderInfo.orderStatus === OrderType.TO_USE) {
        Text('请尽快使用').fontSize(12).opacity(0.9);
      }
    }.itemRow();
  }

  @Builder
  OrderInfoBuilder() {
    Column() {
      Text('订单信息').itemTitle();

      Divider();

      Row() {
        Text('订单编号').itemText(0.6);
        Text(this.ticketOrderInfo.orderNo).itemText(0.9);
      }.itemRow();

      Row() {
        Text('下单时间').itemText(0.6);
        Text(this.ticketOrderInfo.orderTime).itemText(0.9);
      }.itemRow();

      Row() {
        Text('联系信息').itemText(0.6);
        Row({ space: 8 }) {
          Text(this.touristList[0].name).itemText(0.9);
          Text(this.touristList[0].phone).itemText(0.9);
        };
      }.itemRow();
    }
    .itemColumn().height(140);
  }

  @Builder
  UseVouchersBuilder() {
    if (this.ticketOrderInfo.orderStatus === 2) {
      Column() {
        Text('使用凭证').itemTitle();

        QRCode(this.ticketOrderInfo.orderNo).width(120).height(120);

        Row() {
          Text('游客信息').itemText(0.6);
          Row({ space: 8 }) {
            Text(this.touristList[0].name).itemText(0.9);
            Text(this.touristList[0].phone).itemText(0.9);
          };
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text('使用状态').itemText(0.6);
          Text('待使用').fontColor('#64BB5C').fontSize(12);
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
      }
      .itemColumn()
      .height(240);
    }
  }

  @Builder
  ProductInfoBuilder() {
    Column({ space: 12 }) {
      Text('产品信息').itemTitle();

      Divider();

      Row() {
        Text('产品名称').itemText(0.6);
        Text(this.ticketOrderInfo.productName)
          .itemText(0.9)
          .width(200)
          .textAlign(TextAlign.End)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('开始日期').itemText(0.6);
        Text(this.ticketOrderInfo.startTime).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('截止日期').itemText(0.6);
        Text(this.ticketOrderInfo.endTime).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('产品单价').itemText(0.6);
        Text(`¥${this.ticketOrderInfo.productPrice}`).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('订单金额').itemText(0.6);
        Text(`¥${this.ticketOrderInfo.amount}`).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('优惠券折扣').itemText(0.6);
        Text(`¥${this.ticketOrderInfo.discount}`).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('实付金额').itemText(0.6);
        Text(`¥${this.ticketOrderInfo.amount}`).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('订单数量').itemText(0.6);
        Text(`${this.ticketOrderInfo.count}`).fontColor('#64BB5C').fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
    }
    .itemColumn().height(280);
  }

  @Builder
  ContactInfoBuilder() {
    Column({ space: 12 }) {
      Text('联系人信息').itemTitle();

      Divider();

      Row() {
        Text('姓名').itemText(0.6);
        Text(this.touristList[0].name).itemText(0.9);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('手机号码').itemText(0.6);
        Text(this.touristList[0].phone).itemText(0.9);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('证件类型').itemText(0.6);
        Text(cardTypeOptions[this.touristList[0].cardType]).itemText(0.9);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('证件号码').itemText(0.6);
        Text(this.touristList[0].cardNo).itemText(0.9);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
    }
    .itemColumn().height(160);
  }

  @Builder
  PayOrCancelBuilder() {
    Row({ space: 16 }) {
      Button('取消订单').operationBtn(true).onClick(() => {
        this.modifyOrder(true);
      });

      Button('立即支付').operationBtn(false).onClick(() => {
        this.modifyOrder(false);
      });
    }
    .width(Constant.FULL_PERCENT)
    .justifyContent(FlexAlign.Center)
    .height('10%')
    .position({ y: '90%' })
    .backgroundColor(Color.White);
  }

  @Builder
  TouristsInfoBuilder() {
    Column() {
      Text('游玩人信息').itemTitle();

      Divider().margin({ top: 12, bottom: 12 });

      List({ space: 12 }) {
        ForEach(this.touristList, (item: TouristInfo, index: number) => {
          ListItem() {
            Column() {
              Row() {
                Text(`游客${index + 1}`).itemText(0.6);
                Text(item.name).itemText(0.9);
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

              Row() {
                Text('身份证').itemText(0.6);
                Text(item.cardNo).itemText(0.9);
              }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
            };

          };
        }, (item: TouristInfo) => 'name is ' + item.name);
      };
    }
    .itemColumn();
  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        FullLoadingComponent();
      } else {
        Column() {
          TitleBar({
            isShowBack: true, title: '订单详情', clickEvent: () => {
              this.mainPathStack.pop();
            },
          });

          Scroll() {
            Column({ space: 12 }) {
              this.StatusBarBuilder();
              this.OrderInfoBuilder();
              this.UseVouchersBuilder();
              this.ProductInfoBuilder();
              this.ContactInfoBuilder();
              this.TouristsInfoBuilder();
            }.padding(12);
          }
          .scrollBar(BarState.Off)
          .backgroundColor('#F1F3F5')
          .height(this.ticketOrderInfo.orderStatus === OrderType.TO_PAY ? '80%' : '90%')
          .align(Alignment.Top);

          if (this.ticketOrderInfo.orderStatus === OrderType.TO_PAY) {
            this.PayOrCancelBuilder();
          }
        };
      }
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as GetOrderDetailRequest;
      https.getOrderDetail(params).then((res: ESObject) => {
        this.ticketOrderInfo = mapTicketOrderDetail(res.data[0]);
        // 获取倒计时信息
        this.getRemainCount();
        this.getTourist();
      });
    });
  }

  getTourist() {
    https.getTouristList([...this.ticketOrderInfo.touristId]).then(res => {
      this.touristList.push(...mapTouristList(res.data));
      this.isLoading = false;
      Logger.info('the count of tourist is ' + this.touristList.length);
    });
  }
}