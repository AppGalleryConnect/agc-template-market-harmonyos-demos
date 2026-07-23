import { common } from '@kit.AbilityKit';
import { CARD_TYPE_OPTIONS, Constant, GridRowColSetting, Logger } from 'common';
import { GetOrderDetailRequest, https } from 'network';
import { TicketOrderInfo, TouristInfo } from 'types';
import { FullLoadingComponent, TitleBar } from 'uicomponents';
import { mapTicketOrderDetail, mapTouristList } from '../mapper/Index';
import { ORDER_INFO_MAP, OrderType } from '../model/OrderModuleInfo';
import { OrderPageVM } from '../viewmodel/OrderPageVM';


@Builder
export function TicketOrderDetailBuilder() {
  TicketOrderDetail();
}

@Extend(Text)
function labelText() {
  .fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_secondary'));
}

@Extend(Text)
function valueText() {
  .fontSize($r('sys.float.Body_S')).fontColor($r('sys.color.font_primary'));
}

@Extend(Text)
function itemTitle() {
  .fontSize($r('sys.float.Subtitle_L'))
  .fontWeight(FontWeight.Bold)
  .fontColor($r('sys.color.font_primary'))
  .alignSelf(ItemAlign.Start)
  .margin({ top: 8, bottom: 8 });
}

@Extend(Row)
function itemRow() {
  .width(Constant.FULL_PERCENT).justifyContent(FlexAlign.SpaceBetween);
}

@Extend(Column)
function itemColumn() {
  .width(Constant.FULL_PERCENT).padding({
    top: 16,
    bottom: 16,
    left: 12,
    right: 12,
  }).borderRadius(16).backgroundColor($r('sys.color.comp_background_primary'));
}

@Extend(Button)
function operationBtn(isCancel: boolean) {
  .fontColor(isCancel ? $r('sys.color.font_primary') : $r('sys.color.font_on_primary'))
  .backgroundColor(isCancel ? $r('sys.color.comp_background_tertiary') : $r('sys.color.multi_color_04'))
  .constraintSize({ maxWidth: Constant.MAX_WIDTH })
  .layoutWeight(1);
}

@ComponentV2
export struct TicketOrderDetail {
  vm: OrderPageVM = OrderPageVM.instance;
  @Local isLoading: boolean = true;
  @Local ticketOrderInfo: TicketOrderInfo = new TicketOrderInfo();
  @Local touristList: TouristInfo[] = [];
  @Local format: string = 'HH:mm:ss';
  @Local count: number = 0;
  @Local windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  textTimerController: TextTimerController = new TextTimerController();
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  @Computed
  get statusObj() {
    return ORDER_INFO_MAP[this.ticketOrderInfo.orderStatus];
  }

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
            category: 0, orderNo: this.ticketOrderInfo.orderNo,
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
      category: 0, orderNo: this.ticketOrderInfo.orderNo, orderStatus: this.ticketOrderInfo.orderStatus,
    } as GetOrderDetailRequest;
    https.modifyOrderDetail(param).then((res: ESObject) => {
      if (res.code === 0) {
        Logger.info('update order status success');
      }
    });
  }

  @Builder
  StatusBarBuilder() {
    Column({ space: 4 }) {
      Text(this.statusObj?.text)
        .fontSize($r('sys.float.Title_M'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'));

      if (this.ticketOrderInfo.orderStatus === OrderType.TO_PAY && this.count > 0) {
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
      }
    }.width(Constant.FULL_PERCENT).alignItems(HorizontalAlign.Start);
  }

  @Builder
  OrderInfoBuilder() {
    Column() {
      Text('订单信息').itemTitle();

      Column({ space: 12 }) {
        Row() {
          Text('订单号码').labelText();
          Text(this.ticketOrderInfo.orderNo).valueText();
        }.itemRow();

        Row() {
          Text('下单时间').labelText();
          Text(this.ticketOrderInfo.orderTime).valueText();
        }.itemRow();

        Row() {
          Text('联系信息').labelText();
          Text(this.touristList[0].phone).valueText();
        }.itemRow();
      };
    }.itemColumn();
  }

  @Builder
  UseVouchersBuilder() {
    Column() {
      Text('使用凭证').itemTitle();
      Column({ space: 12 }) {
        QRCode(this.ticketOrderInfo.orderNo).width(120).height(120);

        Row() {
          Text('游客信息').labelText();
          Text(this.touristList[0].cardNo).valueText();
        }.itemRow();

        Row() {
          Text('使用状态').labelText();
          Text('待使用').valueText().fontColor($r('sys.color.multi_color_04'));
        }.itemRow();
      };
    }.itemColumn();
  }

  @Builder
  ProductInfoBuilder() {
    Column({ space: 12 }) {
      Text('产品信息').itemTitle();

      Column({ space: 12 }) {

        Row() {
          Text('产品名称').labelText();
          Text(this.ticketOrderInfo.productName)
            .valueText()
            .width(200)
            .textAlign(TextAlign.End)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis });
        }.itemRow();

        Row() {
          Text('开始日期').labelText();
          Text(this.ticketOrderInfo.startTime).valueText();
        }.itemRow();

        Row() {
          Text('截止日期').labelText();
          Text(this.ticketOrderInfo.endTime).valueText();
        }.itemRow();

        Row() {
          Text('产品单价').labelText();
          Text(`¥${this.ticketOrderInfo.productPrice}`).valueText();
        }.itemRow();

        Row() {
          Text('订单金额').labelText();
          Text(`¥${this.ticketOrderInfo.amount}`).valueText();
        }.itemRow();

        Row() {
          Text('优惠券折扣').labelText();
          Text(`¥${this.ticketOrderInfo.discount}`).valueText();
        }.itemRow();

        Row() {
          Text('实付金额').labelText();
          Text(`¥${this.ticketOrderInfo.amount}`).valueText();
        }.itemRow();

        Row() {
          Text('订单数量').labelText();
          Text(`${this.ticketOrderInfo.count}`).valueText();
        }.itemRow();
      };
    }.itemColumn();
  }

  @Builder
  ContactInfoBuilder() {
    Column({ space: 12 }) {
      Text('联系人信息').itemTitle();

      Column({ space: 12 }) {

        Row() {
          Text('姓名').labelText();
          Text(this.touristList[0].name).valueText();
        }.itemRow();

        Row() {
          Text('手机号码').labelText();
          Text(this.touristList[0].phone).valueText();
        }.itemRow();

        Row() {
          Text('证件类型').labelText();
          Text(CARD_TYPE_OPTIONS[this.touristList[0].cardType]).valueText();
        }.itemRow();

        Row() {
          Text('证件号码').labelText();
          Text(this.touristList[0].cardNo).valueText();
        }.itemRow();
      };
    }.itemColumn().height(160);
  }

  @Builder
  PayOrCancelBuilder() {
    Row({ space: 16 }) {
      Button('取消订单').operationBtn(true).onClick(() => {
        this.modifyOrder(true);
      });

      Button('立即支付').operationBtn(false).onClick(() => {
        this.vm.requestPaymentPromise(this.getUIContext().getHostContext() as common.UIAbilityContext).then(() => {
          this.modifyOrder(false);
        });
      });
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center).padding({
      top: 8,
      bottom: 8 + this.windowBottomHeight,
      left: 16,
      right: 16,
    }).backgroundColor($r('sys.color.comp_background_primary'));
  }

  @Builder
  UseOrCancelBuilder() {
    Row({ space: 16 }) {
      Button('退订').operationBtn(true).onClick(() => {
        this.vm.refundOrder(this.ticketOrderInfo);
      });

      Button(this.ticketOrderInfo.isAddSchedule ? '已添加日程' : '添加日程')
        .fontColor(
          this.ticketOrderInfo.isAddSchedule ? $r('sys.color.font_on_primary') : $r('sys.color.multi_color_04'))
        .backgroundColor(this.ticketOrderInfo.isAddSchedule ? $r('sys.color.multi_color_04') :
          $r('sys.color.comp_background_tertiary'))
        .enabled(this.ticketOrderInfo.isAddSchedule ? false : true)
        .constraintSize({ maxWidth: Constant.MAX_WIDTH })
        .layoutWeight(1)
        .onClick(async () => {
          this.vm.addSchedule(this.ticketOrderInfo, this.getUIContext());
        });
    }.width(Constant.FULL_PERCENT).justifyContent(FlexAlign.Center).padding({
      top: 8,
      bottom: 8 + this.windowBottomHeight,
      left: 16,
      right: 16,
    }).backgroundColor($r('sys.color.font_on_primary'));
  }

  @Builder
  TouristsInfoBuilder() {
    Column() {
      Text('游玩人信息').itemTitle();
      List({ space: 12 }) {
        ForEach(this.touristList, (item: TouristInfo, index: number) => {
          ListItem() {
            Column({ space: 12 }) {
              Row() {
                Text(`姓名${index + 1}`).labelText();
                Text(item.name).valueText();
              }.itemRow();

              Row() {
                Text('手机号码').labelText();
                Text(item.phone).valueText();
              }.itemRow();

              Row() {
                Text('证件类型').labelText();
                Text(CARD_TYPE_OPTIONS[this.touristList[0].cardType]).valueText();
              }.itemRow();

              Row() {
                Text('证件号码').labelText();
                Text(item.cardNo).valueText();
              }.itemRow();
            };

          };
        }, (item: TouristInfo) => 'name is ' + item.name);
      };
    }.itemColumn();
  }

  build() {
    NavDestination() {
      if (this.isLoading) {
        FullLoadingComponent();
      } else {
        Column() {
          TitleBar({
            isShowBack: true, title: '订单详情', clickEvent: () => {
              const arr = this.mainPathStack.getPathStack();
              if (arr.length >= 2 && arr[arr.length - 2].name === 'PaySuccess') {
                this.mainPathStack.pushPathByName('Main', '');
              } else {
                this.mainPathStack.pop();
              }
            },
          });
          Scroll() {
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
                  if (this.ticketOrderInfo.orderStatus === 2) {
                    this.UseVouchersBuilder();
                  }
                  this.ProductInfoBuilder();
                  this.ContactInfoBuilder();
                  this.TouristsInfoBuilder();
                };
              };
            };
          }.scrollBar(BarState.Off).layoutWeight(1).padding({
            left: 16,
            right: 16,
            top: 8,
            bottom: 8,
          }).align(Alignment.Top);

          if (this.ticketOrderInfo.orderStatus === OrderType.TO_PAY) {
            this.PayOrCancelBuilder();
          } else if (this.ticketOrderInfo.orderStatus === OrderType.TO_USE) {
            this.UseOrCancelBuilder();
          }
        }.backgroundColor($r('sys.color.background_secondary'));
      }
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as GetOrderDetailRequest;
      https.getOrderDetail(params).then((res: ESObject) => {
        this.ticketOrderInfo = mapTicketOrderDetail(res.data[0]); // 获取倒计时信息
        this.getRemainCount();
        this.getTourist();
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

  getTourist() {
    https.getTouristList([...this.ticketOrderInfo.touristId]).then(res => {
      this.touristList.push(...mapTouristList(res.data));
      this.isLoading = false;
      Logger.info('the count of tourist is ' + this.touristList.length);
    });
  }
}