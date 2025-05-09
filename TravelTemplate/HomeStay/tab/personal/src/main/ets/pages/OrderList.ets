import { AccountUtil } from 'account';
import { https, UpdateOrderRequest } from 'network';
import { Constants, NavPathName, OrderTabBarType } from 'constant';
import { OrderPageVM } from '../viewmodel/OrderPageVM';
import { Order, OrderParam } from 'type';
import { OrderTabBar, OrderTypesTabBar, ORDER_TABS_INFO, ORDER_TYPES, ORDER_TYPES_INFO } from '../model/OrderTabInfo';
import { CommonBlank, TitleBar } from 'component';
import { Logger } from 'util';

@Builder
export function OrderListBuilder() {
  OrderList();
}

@Component
export struct OrderList {
  vm: OrderPageVM = OrderPageVM.instance;
  @Consume('orderTabIndex') orderTabIndex: number;
  @State orderTypeTabIndex: number = 0;
  @State index: number = 0;
  controller: TabsController = new TabsController();
  @State openId: string | undefined = AccountUtil.getOpenId();
  @Consume('mainPathStack') mainPathStack: NavPathStack;

  aboutToAppear() {
    this.vm.getOrderList();
  }

  @Builder
  TabBuilder(item: OrderTabBar, index: number) {
    Column() {
      Text(item.title)
        .fontColor(this.orderTabIndex === index ? Color.Black : Color.Gray)
        .fontSize(12)
        .fontWeight(this.orderTabIndex === index ? 600 : 400);
    }.onClick(() => {
      this.orderTabIndex = index;
      this.vm.getOrdersByType(this.orderTabIndex, this.orderTypeTabIndex);
    });
  }

  getOrderType(orderItem: Order): string | undefined {
    let orderType = ORDER_TYPES.find((item) => item.status === orderItem.orderStatus);
    return orderType?.text;
  }

  @Builder
  OrderItemBuilder(orderItem: Order) {
    Column({ space: 8 }) {
      Row() {
        Row({ space: 12 }) {
          Image(orderItem.orderType === 0 ? orderItem.roomTypeBanner : orderItem.goodsBanner)
            .objectFit(ImageFit.Fill)
            .size({ width: 80, height: 80 })
            .borderRadius(8);
          Column({ space: 18 }) {
            Text(orderItem.orderName)
              .fontSize(14)
              .width(200)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1);

            if (orderItem.orderType === 0) {
              Text(`共${orderItem.dayCount}晚`).fontSize(12).fontColor(Color.Gray);
            } else {
              Text(`x${orderItem.goodsCount}`).fontSize(12).fontColor(Color.Gray);
            }
          }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Start);
        };

        Column({ space: 18 }) {
          Text(this.getOrderType(orderItem))
            .fontSize(12)
            .fontColor($r('app.color.keyword_type_font_color'));
          Text(`￥${orderItem.amount}`)
            .textAlign(TextAlign.End)
            .fontSize(14)
            .fontWeight(600);
        }.justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.End);
      }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.SpaceBetween);

      if (orderItem.orderStatus === 1) {
        Row({ space: 12 }) {
          Button('取消订单')
            .size({ width: 64, height: 24 })
            .padding(4)
            .border({ width: 1, radius: 4, color: '#DDDDDD' })
            .backgroundColor(Color.White)
            .fontColor($r('sys.color.font_primary'))
            .margin({ top: 8 })
            .onClick(async () => {
              this.vm.orderList.map((item => {
                if (item.orderSn === orderItem.orderSn) {
                  item.orderStatus = 3;
                }
              }));
              const res =
                await https.updateOrder({ orderSn: orderItem.orderSn, orderStatus: 3 } as UpdateOrderRequest);
              if (res.code === 200) {
                Logger.info('pay success in order list');
              }
              this.orderTabIndex = 3;
            });

          Button('立即支付')
            .size({ width: 64, height: 24 })
            .padding(4)
            .border({ width: 1, radius: 4, color: '#007DFF' })
            .backgroundColor(Color.White)
            .fontColor('#007DFF')
            .margin({ top: 8 })
            .onClick(async () => {
              let desIndex: number = orderItem.orderType === 1 ? OrderTabBarType.READY : OrderTabBarType.TO_USE;
              this.vm.orderList.map((item => {
                if (item.orderSn === orderItem.orderSn) {
                  item.orderStatus = desIndex;
                }
              }));
              const res =
                await https.updateOrder({ orderSn: orderItem.orderSn, orderStatus: 2 } as UpdateOrderRequest);
              if (res.code === 200) {
                Logger.info('pay success in order list');
              }
              this.orderTabIndex = desIndex;
            });
        }.width(Constants.FULL_SCREEN).justifyContent(FlexAlign.End);
      }
    }
    .padding(16)
    .borderWidth({ top: 1, bottom: 1 })
    .borderColor('#F5F6FA')
    .onClick(() => {
      this.mainPathStack.pushPathByName(orderItem.orderType === 0 ? NavPathName.ROOM_ORDER_DETAIL :
      NavPathName.COMMODITY_ORDER_DETAIL,
        orderItem, (popInfo: ESObject) => {
          this.orderTabIndex = popInfo.result.orderStatus;
          this.vm.getOrdersByType(this.orderTabIndex, this.orderTypeTabIndex);
        });
    });
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '我的订单', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          Row() {
            ForEach(ORDER_TYPES_INFO, (item: OrderTypesTabBar, index: number) => {
              Row() {
                Text(item.title)
                  .fontColor(this.orderTypeTabIndex === index ? Color.White : '#007DFF')
                  .backgroundColor(this.orderTypeTabIndex === index ? '#007DFF' : Color.White)
                  .fontSize(12)
                  .fontWeight(this.orderTypeTabIndex === index ? 500 : 400)
                  .padding({
                    left: 24,
                    right: 24,
                    top: 6,
                    bottom: 6,
                  });
              }
              .onClick(() => {
                this.orderTypeTabIndex = index;
                this.vm.getOrdersByType(this.orderTabIndex, this.orderTypeTabIndex);
              });
            }, (item: OrderTypesTabBar) => item.title.toString());
          }.justifyContent(FlexAlign.Center).border({ width: 1, color: '#007DFF', radius: 4 });

          Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.orderTabIndex }) {
            ForEach(ORDER_TABS_INFO, (item: OrderTabBar, index: number) => {
              TabContent() {
                if (this.vm.orders.length !== 0) {
                  List() {
                    ForEach(this.vm.orders, (item: Order) => {
                      ListItem() {
                        this.OrderItemBuilder(item);
                      };
                    }, (item: Order) => item.orderSn,
                    );
                  }.align(Alignment.Top).height(Constants.FULL_SCREEN).scrollBar(BarState.Off);
                } else {
                  CommonBlank();
                }
              }.tabBar(this.TabBuilder(item, index));
            }, (item: OrderTabBar) => item.title.toString());
          }
          .scrollable(false)
          .animationDuration(0)
          .width(Constants.FULL_SCREEN)
          .onChange((value: number) => {
            this.orderTabIndex = value;
            this.vm.getOrdersByType(this.orderTabIndex, this.orderTypeTabIndex);
          });
        }.align(Alignment.Top).height('90%');
      };
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      let orderParam: OrderParam = context.pathInfo.param as OrderParam;
      this.orderTabIndex = orderParam.orderStatus;
      this.orderTypeTabIndex = orderParam.orderType;
      this.vm.getOrdersByType(this.orderTabIndex, this.orderTypeTabIndex);
    });
  }
}