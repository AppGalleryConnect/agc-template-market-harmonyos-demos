import { RouterMap, RouterModule, CommonConstants, FormatUtil } from 'commonlib';
import { OrderClass, OrderTabListItem, OrderInfo } from '../types/Index';
import { MyOrdersVM } from '../viewModels/MyOrdersVM';
import { AlertDialog } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { LengthMetrics } from '@kit.ArkUI';

@Builder
export function MyOrdersBuilder() {
  MyOrders();
}


@ComponentV2
struct MyOrders {
  vm: MyOrdersVM = MyOrdersVM.instance;
  private controller: TabsController = new TabsController();
  dialogControllerConfirm: CustomDialogController = new CustomDialogController({
    builder: AlertDialog({
      content: this.vm.currentIndex === 0 ? '确定要取消预定吗？' : '确定要取消订单吗？',
      primaryButton: {
        value: '取消',
        action: () => {
        },
      },
      secondaryButton: {
        value: '确认',
        role: ButtonRole.ERROR,
        action: () => {
          this.controller.changeIndex(parseInt(OrderClass.INVALIDATION) - 1);
          this.vm.cancelOrder(this.vm.targetOrderNo);
        },
      },
    }),
  });
  callBackFunc: () => void = () => {
    this.vm.initData();
  };

  aboutToAppear(): void {
    emitter.on('refreshTable', this.callBackFunc);
  }

  aboutToDisappear(): void {
    emitter.off('refreshTable', this.callBackFunc);
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Text(name)
        .fontColor(this.vm.fontColor)
        .fontSize(CommonConstants.FONT_SIZE_M)
        .fontWeight(this.vm.selectedIndex === index ? 500 : 400)
        .height(19)
        .margin({ bottom: 6, top: 7 });
      Divider()
        .strokeWidth(2)
        .color(this.vm.selectedFontColor)
        .opacity(this.vm.selectedIndex === index ? 1 : 0)
        .width(48);
    }.width('100%').backgroundColor(CommonConstants.BG_COLOR_WHITE).height(40);
  }

  @Builder
  orderItemBuilder(item: OrderInfo) {
    Column() {
      Row() {
        Text(this.vm.getLabel(item.status)).commonTagStyle();
      }.height(14);

      Row() {
        Text('展览名称:').commonLabelStyle();
        Text(item.performanceName).commonValueStyle();
      }.height(39);

      Divider().strokeWidth(0.5);
      Row() {
        Text('参观时间:').commonLabelStyle();
        Text(item.visitTime).commonValueStyle();
      }.height(39);

      Divider().strokeWidth(0.5);
      Row() {
        Text('参观人:').commonLabelStyle();
        Text(item.visitor + '人').commonValueStyle();
      }.height(39);

      Divider().strokeWidth(0.5);
      if (this.vm.currentIndex !== 4) {
        Row() {
          Text('预约时间:').commonLabelStyle();
          Text(item.orderTime).commonValueStyle();
        }.height(39);

        Divider().strokeWidth(0.5);
      }
      if (this.vm.currentIndex === 4 && item.cancelTime) {
        Row() {
          Text('取消时间:').commonLabelStyle();
          Text(item.cancelTime).commonValueStyle();
        }.height(39);

        Divider().strokeWidth(0.5);
      }

      if ((this.vm.currentIndex === 0 || this.vm.currentIndex === 2) && item.actualPay) {
        Row() {
          Text('实付款:').commonLabelStyle();
          Text('¥' + item.actualPay.toString()).commonValueStyle();
        }.height(39);

        Divider().strokeWidth(0.5);
      }
      if ((this.vm.currentIndex === 1 || this.vm.currentIndex === 3) && item.orderAmount) {
        Row() {
          Text('订单金额:').commonLabelStyle();
          Text('¥' + item.orderAmount.toString()).commonValueStyle();
        }.height(39);

        Divider().strokeWidth(0.5);
      }
      if (this.vm.currentIndex === 0) {
        Row() {
          Button('取消预定')
            .fontWeight(500)
            .width(72)
            .height(28)
            .backgroundColor('#0C000000')
            .fontColor(CommonConstants.FONT_COLOR_BLACK)
            .fontSize(CommonConstants.FONT_SIZE_M)
            .padding(0)
            .hitTestBehavior(HitTestMode.Block)
            .onClick(() => {
              this.vm.targetOrderNo = item.orderNo;
              this.dialogControllerConfirm.open();
            });
        }.justifyContent(FlexAlign.End).width('100%').margin({ top: 10 });
      }
      if (this.vm.currentIndex === 1) {
        Row() {
          Button('取消')
            .fontWeight(500)
            .width(72)
            .height(28)
            .backgroundColor('#0C000000')
            .fontSize(CommonConstants.FONT_SIZE_M)
            .padding(0)
            .hitTestBehavior(HitTestMode.Block)
            .fontColor(CommonConstants.FONT_COLOR_BLACK)
            .onClick(() => {
              this.vm.targetOrderNo = item.orderNo;
              this.dialogControllerConfirm.open();
            })
            .margin({ right: 10 });
          Button('去付款')
            .fontWeight(500)
            .width(72)
            .height(28)
            .backgroundColor(CommonConstants.FONT_COLOR_GREEN)
            .fontSize(CommonConstants.FONT_SIZE_M)
            .padding(0)
            .hitTestBehavior(HitTestMode.Block)
            .onClick(() => {
              this.vm.toPay(item.orderStr as string);
            });
        }.justifyContent(FlexAlign.End).width('100%').margin({ top: 10 });
      }

    }
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: 10,
      right: 10,
      bottom: 10,
      top: 10,
    })
    .borderRadius(8)
    .backgroundColor(CommonConstants.BG_COLOR_WHITE)
    .onClick(() => {
      RouterModule.push({ url: RouterMap.TICKET_DETAIL, param: { orderNo: item.orderNo } });
    });
  }

  build() {
    NavDestination() {
      Column() {
        Divider().width('100%').color(CommonConstants.DIVIDER_GRAY).strokeWidth(0.5);
        Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
          ForEach(this.vm.orderTabList, (item: OrderTabListItem, index) => {
            TabContent() {
              if (this.vm.isLoading) {
                LoadingProgress().width(40);
              } else {
                if (this.vm.orderTabList.length) {
                  Scroll() {
                    Column({ space: 10 }) {
                      ForEach(this.vm.orderList, (item: OrderInfo, index) => {
                        this.orderItemBuilder(item);
                      }, (item: OrderInfo, index) => item.orderNo);
                      if (this.vm.orderList.length === 0) {
                        Row() {
                          Divider().strokeWidth(1).width(40);
                          Text('没有更多了').fontColor('#ccc');
                          Divider().strokeWidth(1).width(40);
                        }.margin({ top: 15 });
                      }

                    }.width('100%').constraintSize({
                      minHeight: '100%',
                    }).padding(10);
                  }.scrollBar(BarState.Off)
                  .visibility(this.vm.currentIndex === index ? Visibility.Visible : Visibility.Hidden);
                } else {
                  Text('暂无数据').fontSize(CommonConstants.FONT_SIZE_M);
                }
              }

            }.tabBar(this.tabBuilder(index, item.label));
          }, (item: OrderTabListItem, index) => item.label);
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barHeight(40)
        .animationDuration(400)
        .onChange((index: number) => {
          // currentIndex控制TabContent显示页签
          this.vm.currentIndex = index;
          this.vm.selectedIndex = index;
          this.vm.getOrderList();
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return;
          }
          // selectedIndex控制自定义TabBar内Image和Text颜色切换
          this.vm.selectedIndex = targetIndex;
        });

      }.width('100%').backgroundColor(CommonConstants.BG_COLOR_GRAY);
    }.title('我的订单', { paddingStart: LengthMetrics.vp(16) });

  }
}


@Extend(Text)
function commonTagStyle() {
  .width('100%')
  .textAlign(TextAlign.End)
  .fontSize(CommonConstants.FONT_SIZE_S)
  .fontColor(CommonConstants.FONT_COLOR_GREEN);
}

@Extend(Text)
function commonValueStyle() {
  .fontColor(CommonConstants.FONT_COLOR_BLACK).fontSize(CommonConstants.FONT_SIZE_M);
}

@Extend(Text)
function commonLabelStyle() {
  .fontColor(CommonConstants.FONT_COLOR_BLACK).width(70).fontSize(CommonConstants.FONT_SIZE_M);
}
