import { Constants } from 'constant';
import { consult, copyText } from 'util';
import { TenantInfo } from '../model/Index';
import { Order } from 'type';
import { OrderFooter } from '../components/OrderFooter';
import { OrderHeader } from '../components/OrderHeader';
import { ConfirmDialog, TitleBar } from 'component';

@Builder
export function RoomOrderDetailBuilder() {
  RoomOrderDetail();
}

@Component
export struct RoomOrderDetail {
  @State tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
  @State order: Order = new Order();
  @State orderNo: string = '';
  @Consume('orderTabIndex') orderTabIndex: number;
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  @State windowBottomHeight: number = AppStorage.get('windowBottomHeight') as number || 28;
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: ConfirmDialog({
      call: () => {
        consult(this.order.servicePhone);
      },
      phone: this.order.servicePhone,
    }),
    customStyle: true,
    autoCancel: true,
  });

  build() {
    NavDestination() {
      Column() {
        Column() {
          TitleBar({
            isShowBack: true, title: '订单详情', clickEvent: () => {
              this.mainPathStack.pop(this.order);
            },
          });

          Column() {
            Column() {
              OrderHeader({ order: this.order });

              Column() {
                Row() {
                  Column() {
                    Image(this.order.roomTypeBanner)
                      .size({ width: 80, height: 80 })
                      .borderRadius(8)
                      .objectFit(ImageFit.Fill);
                  }.justifyContent(FlexAlign.Center);

                  Column() {
                    Text(this.order.orderName).fontSize($r('app.float.order_status_room_name_font_size'));
                    Text(`${this.order.planCheckInDate} 至 ${this.order.planCheckOutDate}`)
                      .fontSize($r('app.float.order_status_room_font_size'))
                      .margin({ top: 8 })
                      .opacity(0.6);
                    Text(`共${this.order.dayCount}晚`)
                      .fontSize($r('app.float.order_status_room_font_size'))
                      .margin({ top: 8 })
                      .opacity(0.6);
                  }.margin({ left: 12 }).alignItems(HorizontalAlign.Start);
                }.width(Constants.FULL_SCREEN);

                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('入住人').fontSize(14).opacity(0.6);
                    Text(this.order.passengerName).fontColor($r('app.color.order_item_detail_font_color')).fontSize(14);
                  };

                  Divider().vertical(false).margin({ top: 16, bottom: 16 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('联系电话').fontSize(14).opacity(0.6);
                    Text(this.order.passengerPhone)
                      .fontColor($r('app.color.order_item_detail_font_color'))
                      .fontSize(14);
                  };

                  Divider().vertical(false).margin({ top: 16, bottom: 16 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('备注').fontSize(14).opacity(0.6);
                    Text(this.order.orderRemark)
                      .fontColor($r('app.color.order_item_detail_font_color'))
                      .fontSize(14);
                  };

                  Divider().vertical(false).margin({ top: 16, bottom: 16 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('订单价格').fontSize(14).opacity(0.6);
                    Text(`￥${this.order.amount}`)
                      .fontColor($r('app.color.order_item_detail_font_color'))
                      .fontSize(14);
                  };

                  Divider().vertical(false).margin({ top: 16, bottom: 16 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('实付金额').fontSize(14).opacity(0.6);
                    Text(`￥${this.order.amount}`)
                      .fontColor($r('app.color.order_item_detail_font_color'))
                      .fontSize(14);
                  };

                  Divider().vertical(false).margin({ top: 16, bottom: 16 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Text('订单编号').fontSize(14).opacity(0.6);
                    Row() {
                      Text(this.order.orderSn).fontColor($r('app.color.order_item_detail_font_color')).fontSize(14);
                      Button('复制', { type: ButtonType.Normal })
                        .size({ width: 36, height: 24 })
                        .fontSize(10)
                        .border({ width: 1, color: Color.Black, radius: 2 })
                        .backgroundColor(Color.White)
                        .fontColor(Color.Black)
                        .margin({ left: 4 })
                        .padding({
                          left: 6,
                          right: 6,
                          top: 2,
                          bottom: 2,
                        })
                        .onClick(() => {
                          copyText(this.order.orderSn);
                        });
                    };
                  };

                  Divider().vertical(false).margin({ top: 16, bottom: 16 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('下单时间').fontSize(14).opacity(0.6);
                    Text(this.order.createTime).fontColor($r('app.color.order_item_detail_font_color')).fontSize(14);
                  };

                  Divider().vertical(false).margin({ top: 16 });
                }.margin({ top: 24 });
              }.padding({ left: 16, right: 16 });

              Row() {
                Row() {
                  Image($r('app.media.icon_order_cos')).size({ width: 14, height: 14 }).objectFit(ImageFit.Contain);
                  Text('联系客服').fontSize(12).margin({ left: 4 });
                }.width(Constants.HALF_SCREEN).justifyContent(FlexAlign.Center).onClick(() => {
                  if (this.dialogController !== null) {
                    this.dialogController.open();
                  }
                });

                Row() {
                  Image($r('app.media.icon_order_call')).size({ width: 14, height: 14 }).objectFit(ImageFit.Contain);
                  Text('联系商家').fontSize(12).margin({ left: 4 });
                }.width(Constants.HALF_SCREEN).justifyContent(FlexAlign.Center).margin({ left: 4 }).onClick(() => {
                  if (this.dialogController !== null) {
                    this.dialogController.open();
                  }
                });
              }.width(Constants.FULL_SCREEN).margin({ top: 32 });
            }.width(Constants.FULL_SCREEN);

          }.justifyContent(FlexAlign.SpaceBetween);
        };

        if (this.order.orderStatus === 1) {
          OrderFooter({ order: this.order });
        }
      }
      .height(Constants.FULL_SCREEN)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({ bottom: this.windowBottomHeight });
    }.hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.order = context.pathInfo.param as Order;
    }).onBackPressed(() => {
      this.mainPathStack.pop(this.order);
      return true;
    });
  }
}