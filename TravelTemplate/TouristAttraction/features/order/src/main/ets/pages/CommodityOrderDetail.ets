import { Constant, GridRowColSetting, Logger, SystemUtil } from 'common';
import { GetOrderDetailRequest, https } from 'network';
import { CommodityOrderInfo } from 'types';
import { TitleBar } from 'uicomponents';
import { mapCommodityOrderDetail } from '../mapper/Index';
import { ORDER_INFO_MAP, OrderType } from '../model/OrderModuleInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@Builder
export function CommodityOrderDetailBuilder() {
  CommodityOrderDetail();
}

@Extend(Button)
function operationBtn(isCancel: boolean) {
  .fontColor(isCancel ? $r('sys.color.font_primary') : $r('sys.color.font_on_primary'))
  .backgroundColor(isCancel ? $r('sys.color.comp_background_tertiary') : $r('sys.color.multi_color_04'))
  .layoutWeight(1);
}

@Extend(Text)
function labelText() {
  .fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function valueText() {
  .fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
}

@ComponentV2
export struct CommodityOrderDetail {
  vm: OrderPageVM = OrderPageVM.instance;
  @Local format: string = 'HH:mm:ss';
  @Local count: number = 0;
  textTimerController: TextTimerController = new TextTimerController();
  @Local commodityOrderInfo: CommodityOrderInfo = new CommodityOrderInfo();
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Computed
  get statusObj() {
    return ORDER_INFO_MAP[this.commodityOrderInfo.orderStatus];
  }

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
            category: 1, orderNo: this.commodityOrderInfo.orderNo,
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
      category: 1, orderNo: this.commodityOrderInfo.orderNo, orderStatus: this.commodityOrderInfo.orderStatus,
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
    this.count = createStamp + Constant.MAX_TO_PAY_TIME - curStamp; // 倒计时结束取消订单
    if (this.count < 0) {
      this.modifySilent();
    }
    Logger.info('count time is' + this.count);
  }

  getFriendlySpecString(): string {
    if (!this.commodityOrderInfo.specValues || this.commodityOrderInfo.specValues.length === 0) {
      return this.commodityOrderInfo.spuName;
    }

    const specStrings = this.commodityOrderInfo.specValues.map((spec) => spec.value);
    return specStrings.join(' / ');
  }

  @Builder
  OrderInfoBuilder() {
    Column({ space: 12 }) {
      Row({ space: 8 }) {
        Row({ space: 4 }) {
          Image($r('app.media.mall')).size({ width: 24, height: 24 });
          Text('文创特产').fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
        };

        Divider().vertical(true).height(12);
        Text(this.commodityOrderInfo.orderNo.toString())
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('sys.color.font_secondary'));
      }.width(Constant.FULL_PERCENT);

      Row({ space: 12 }) {
        Image(this.commodityOrderInfo.banner).size({ width: 56, height: 56 }).borderRadius(8);
        Column({ space: 2 }) {
          Text(this.commodityOrderInfo.productName)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('sys.color.font_primary'))
            .fontSize($r('sys.float.Body_L'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
          Text(this.getFriendlySpecString()).fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
        }.alignItems(HorizontalAlign.Start).width(Constant.FULL_PERCENT).height(56);
      };
    }
    .width(Constant.FULL_PERCENT)
    .padding(12)
    .borderRadius(16)
    .backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Builder
  PaymentBuilder() {
    Column() {
      Text('付款信息')
        .fontSize($r('sys.float.Subtitle_L'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8, bottom: 8 });

      Column({ space: 12 }) {
        Row() {
          Text('订单号').labelText();
          Row({ space: 8 }) {
            Text(this.commodityOrderInfo.orderNo).valueText();
            Text('复制')
              .fontSize(10)
              .fontColor($r('sys.color.multi_color_04'))
              .height(20)
              .padding({ left: 10, right: 10 })
              .border({ width: 1, color: $r('sys.color.multi_color_04'), radius: 24 })
              .onClick(() => {
                SystemUtil.copyText(this.getUIContext(), this.commodityOrderInfo.orderNo);
              });
          };
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text('数量').labelText();
          Text(`${this.commodityOrderInfo.count}`).valueText();
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text('下单时间').labelText();
          Text(this.commodityOrderInfo.orderTime).valueText();
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text('实付款').labelText();
          Text(`￥${this.commodityOrderInfo.amount}`).valueText();
        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);

        Row() {
          Text('客服电话').labelText();
          Row({ space: 8 }) {
            Text(`${this.commodityOrderInfo.phone}`).valueText();
            Text('拨号')
              .fontSize(10)
              .fontColor($r('sys.color.multi_color_04'))
              .height(20)
              .padding({ left: 10, right: 10 })
              .border({ width: 1, color: $r('sys.color.multi_color_04'), radius: 24 })
              .onClick(() => {
                SystemUtil.triggerForCall(this.getUIContext(), this.commodityOrderInfo.phone);
              });
          };

        }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
      };

    }.width(Constant.FULL_PERCENT).padding({
      top: 16,
      bottom: 16,
      left: 12,
      right: 12,
    }).borderRadius(16).backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Builder
  OperationBuilder() {
    Row({ space: 16 }) {
      if (this.commodityOrderInfo.orderStatus === OrderType.TO_PAY) {
        Button('取消订单').operationBtn(true).onClick(() => {
          this.modifyOrder(true);
        });

        Button('立即支付').operationBtn(false).onClick(() => {
          this.modifyOrder(false);
        });
      } else if (this.commodityOrderInfo.orderStatus === OrderType.TO_USE) {
        Button('申请退款').operationBtn(true).onClick(() => {
          this.modifyOrder(true);
        });
      }
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center).padding({
      top: 8,
      bottom: 8 + this.windowBottomHeight,
      left: 16,
      right: 16,
    }).backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Builder
  StatusBarBuilder() {
    Column({ space: 4 }) {
      Text(this.statusObj?.text)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'));

      if (this.commodityOrderInfo.orderStatus === OrderType.TO_PAY && this.count > 0) {
        Row() {
          Text('还剩').fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M'));
          TextTimer({ isCountDown: true, count: this.count, controller: this.textTimerController })
            .format(this.format)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.warning'))
            .onTimer((utc: number, elapsedTime: number) => {
              Logger.info('textTimer notCountDown utc is：' + utc + ', elapsedTime: ' + elapsedTime);
              if ((elapsedTime + 1) * 1000 >= this.count) { // 先更新本地,再更新云端
                this.modifySilent();
              }
            })
            .onAppear(() => {
              this.textTimerController.start();
            });
          Text('订单自动取消').fontColor($r('sys.color.font_secondary')).fontSize($r('sys.float.Body_M'));
        };
      } else if (this.commodityOrderInfo.orderStatus === OrderType.TO_USE) {
        Text('请尽快使用').fontSize($r('sys.float.Body_M')).fontColor($r('sys.color.font_secondary'));
      }
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '购物订单', clickEvent: () => {
            const arr = this.mainPathStack.getPathStack();
            if (arr.length >= 2 && arr[arr.length - 2].name === 'PaySuccess') {
              this.mainPathStack.pushPathByName('Main', '');
            } else {
              this.mainPathStack.pop();
            }
          },
        });
        GridRow({
          columns: GridRowColSetting.GRID_ROW_OPTIONS_COLUMNS,
          breakpoints: {
            value: GridRowColSetting.BREAK_POINT_VALUE,
            reference: BreakpointsReference.WindowSize,
          },
          gutter: {
            x: GridRowColSetting.GRID_ROW_OPTIONS_GUTTER_X,
          },
          direction: GridRowDirection.Row,
        }) {
          GridCol({
            offset: GridRowColSetting.DEFAULT_CENTER_COL_OFFSET,
            span: GridRowColSetting.DEFAULT_CENTER_COL_SPAN,
          }) {
            Column({ space: 12 }) {
              this.StatusBarBuilder();
              this.OrderInfoBuilder();
              this.PaymentBuilder();
            }.layoutWeight(1).padding({
              left: 16,
              right: 16,
              top: 8,
              bottom: 8,
            }).align(Alignment.Top);
          };
        }
        .layoutWeight(1);

        this.OperationBuilder();
      }.backgroundColor($r('sys.color.background_secondary'));
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as GetOrderDetailRequest;
      https.getOrderDetail(params).then((res: ESObject) => {
        this.commodityOrderInfo = mapCommodityOrderDetail(res.data[0]);
        this.getRemainCount();
        Logger.info('commodity info is ' + this.commodityOrderInfo);
      });
    }).onBackPressed(() => {
      const arr = this.mainPathStack.getPathStack();
      if (arr.length >= 2 && arr[arr.length - 2].name === 'PaySuccess') {
        this.mainPathStack.pushPathByName('Main', '');
        return true;
      } else {
        return false;
      }
    });
  }
}