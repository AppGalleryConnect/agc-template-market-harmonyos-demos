import { Constant, copyText, Logger, triggerForCall } from 'common';
import { TitleBar } from 'components';
import { GetOrderDetailRequest, https } from 'network';
import { CommodityOrderInfo } from 'types';
import { mapCommodityOrderDetail } from '../mapper/Index';
import { COMMODITY_ORDER_INFO_MAP } from '../model/CommodityOrderInfo';
import { OrderType } from '../model/OrderModuleInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Builder
export function CommodityOrderDetailBuilder() {
  CommodityOrderDetail();
}

@Extend(Button)
function operationBtn(isCancel: boolean) {
  .fontSize(14)
  .fontColor(isCancel ? '#64BB5C' : Color.White)
  .backgroundColor(isCancel ? Color.White : '#64BB5C')
  .border({ radius: 20, color: isCancel ? '#64BB5C' : Color.Transparent })
  .width(150)
  .padding(12);
}

@Extend(Column)
function itemColumn() {
  .width(Constant.FULL_PERCENT)
  .justifyContent(FlexAlign.SpaceBetween)
  .padding(12)
  .borderRadius(8)
  .backgroundColor(Color.White);
}

@Extend(Text)
function itemText(opa: number) {
  .fontSize(12).opacity(opa);
}

@ComponentV2
export struct CommodityOrderDetail {
  vm: OrderPageVM = OrderPageVM.instance;
  @Local format: string = 'HH:mm:ss';
  @Local count: number = 0;
  textTimerController: TextTimerController = new TextTimerController();
  @Local commodityOrderInfo: CommodityOrderInfo = new CommodityOrderInfo();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  modifyOrder(isCancel: boolean) {
    let param: GetOrderDetailRequest = {
      category: 1,
      orderNo: this.commodityOrderInfo.orderNo,
      orderStatus: isCancel ? OrderType.COMPLETED : OrderType.TO_USE,
    };
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        this.mainPathStack.pop();
        if (!isCancel) {
          this.mainPathStack.pushPathByName('PaySuccess', {
            category: 1,
            orderNo: this.commodityOrderInfo.orderNo,
          } as GetOrderDetailRequest);
        } else {
          this.vm.getOrderList();
        }
      }
    });
  }

  modifySilent() {
    this.commodityOrderInfo.orderStatus = OrderType.COMPLETED;
    let param = {
      category: 1,
      orderNo: this.commodityOrderInfo.orderNo,
      orderStatus: this.commodityOrderInfo.orderStatus,
    } as GetOrderDetailRequest;
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        Logger.info('update order status success');
      }
    });
  }

  getRemainCount() {
    let curStamp = new Date().getTime();
    let createStamp = new Date(this.commodityOrderInfo.orderTime).getTime();
    this.count = createStamp + Constant.MAX_TO_PAY_TIME - curStamp;
    // 倒计时结束取消订单
    if (this.count < 0) {
      this.modifySilent();
    }
    Logger.info('count time is' + this.count);
  }

  @Computed
  get statusObj() {
    return COMMODITY_ORDER_INFO_MAP[this.commodityOrderInfo.orderStatus];
  }

  @Builder
  OrderInfoBuilder() {
    Column() {
      Row() {
        Image($r('app.media.mall')).size({ width: 24, height: 24 });
        Text('文创特产').fontSize(12).opacity(0.9);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Start);

      Divider();

      Row() {
        Image(this.commodityOrderInfo.banner)
          .size({ width: 68, height: 68 })
          .margin({ right: 14 })
          .borderRadius(8);
        Column() {
          Text(this.commodityOrderInfo.productName).fontWeight(500).maxLines(1).width(200)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(this.commodityOrderInfo.spuName).fontSize(12).opacity(0.4);
        }.alignItems(HorizontalAlign.Start).justifyContent(FlexAlign.SpaceBetween).width(Constant.FULL_PERCENT);
      }.backgroundColor(Color.White);
    }.itemColumn().height(140);
  }

  @Builder
  PaymentBuilder() {
    Column() {
      Text('付款信息').fontSize(14).fontWeight(500).alignSelf(ItemAlign.Start);

      Divider();

      Row() {
        Text('订单号').itemText(0.6);
        Row({ space: 2 }) {
          Text(this.commodityOrderInfo.orderNo).itemText(0.9);
          Text('复制')
            .padding(4)
            .fontSize(10)
            .fontColor('#64BB5C')
            .border({ width: 1, color: '#64BB5C', radius: 24 })
            .onClick(() => {
              copyText(this.commodityOrderInfo.orderNo);
            });
        };
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('数量').itemText(0.6);
        Text(`${this.commodityOrderInfo.count}`).fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('下单时间').itemText(0.6);
        Text(this.commodityOrderInfo.orderTime).fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('实付款').itemText(0.6);
        Text(`${this.commodityOrderInfo.amount}`).fontSize(12);
      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

      Row() {
        Text('客服电话').itemText(0.6);
        Row({ space: 2 }) {
          Text(`${this.commodityOrderInfo.phone}`).fontSize(12);
          Image($r('app.media.phone')).size({ width: 24, height: 24 }).onClick(() => {
            triggerForCall(this.commodityOrderInfo.phone);
          });
        };

      }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
    }
    .itemColumn().height(200);
  }

  @Builder
  OperationBuilder() {
    Row({ space: 16 }) {
      Button('取消订单').operationBtn(true).onClick(() => {
        this.modifyOrder(true);
      });

      Button('立即支付').operationBtn(false).onClick(() => {
        this.modifyOrder(false);
      });
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center).margin({ top: 12 });
  }

  @Builder
  StatusBarBuilder() {
    Row() {
      Text(this.statusObj?.text)
        .fontSize(24)
        .fontWeight(500)
        .opacity(0.9);

      if (this.commodityOrderInfo.orderStatus === OrderType.TO_PAY && this.count > 0) {
        Row() {
          Text('还有').opacity(0.4).fontSize(12);
          TextTimer({ isCountDown: true, count: this.count, controller: this.textTimerController })
            .format(this.format)
            .fontColor(Color.Black)
            .fontSize(12)
            .opacity(0.4)
            .fontColor('#E84026')
            .onTimer((utc: number, elapsedTime: number) => {
              Logger.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime);
              if ((elapsedTime + 1) * 1000 >= this.count) {
                // 再请求更新
                this.modifySilent();
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            });
          Text('订单自动取消').opacity(0.4).fontSize(12);
        };
      } else if (this.commodityOrderInfo.orderStatus === OrderType.TO_USE) {
        Text('请尽快使用').fontSize(12).opacity(0.9);
      }
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '订单详情', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column({ space: 12 }) {
          this.StatusBarBuilder();
          this.OrderInfoBuilder();
          this.PaymentBuilder();
        }.padding({ left: 12, right: 12 });

        if (this.commodityOrderInfo.orderStatus === OrderType.TO_PAY) {
          this.OperationBuilder();
        }
      }.backgroundColor('#F1F3F5').height(Constant.FULL_PERCENT);
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as GetOrderDetailRequest;
      https.getOrderDetail(params).then((res: ESObject) => {
        this.commodityOrderInfo = mapCommodityOrderDetail(res.data[0]);
        this.getRemainCount();
        Logger.info('commodity info is ' + this.commodityOrderInfo);
      });
    });
  }
}