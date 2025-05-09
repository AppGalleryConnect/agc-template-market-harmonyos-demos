import { consult, copyText } from 'util';
import { Constants } from 'constant';
import { TenantInfo } from '../model/Index';
import { Order } from 'type';
import { OrderFooter } from '../components/OrderFooter';
import { OrderHeader } from '../components/OrderHeader';
import { ConfirmDialog, TitleBar } from 'component';

@Builder
export function CommodityOrderDetailBuilder() {
  CommodityOrderDetail();
}

@Component
export struct CommodityOrderDetail {
  @State order: Order = new Order();
  @State orderNo: string = '';
  @State tenantInfo: TenantInfo | undefined = AppStorage.get('tenantInfo');
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
                    Image(this.order.goodsBanner)
                      .size({ width: 80, height: 80 })
                      .borderRadius(8)
                      .objectFit(ImageFit.Fill);
                  };

                  Column() {
                    Text(this.order.orderName).fontSize(12).fontWeight(500).maxLines(2);
                    Text(this.order.sfc).fontSize(10).margin({ top: 8 });
                    Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                      Text(`￥${this.order.goodsRetailPrice}`)
                        .fontSize(12)
                        .fontColor(Color.Red)
                        .fontWeight(600)
                        .opacity(0.6);
                      Text(`x${this.order.goodsCount}`).fontSize(14);
                    }.margin({ top: 8 });
                  }.margin({ left: 12 }).alignItems(HorizontalAlign.Start).layoutWeight(1);
                }.width(Constants.FULL_SCREEN).margin({ bottom: 4 });

                Column() {
                  Row() {
                    Text('运费').fontSize(14).fontColor($r('app.color.order_item_font_color')).opacity(0.6);
                    Text('免邮').fontColor($r('app.color.order_item_detail_font_color')).fontSize(14);
                  }.justifyContent(FlexAlign.SpaceBetween).width(Constants.FULL_SCREEN).margin({ top: 20, bottom: 20 });

                  Row() {
                    Text('备注').fontSize(14).fontColor($r('app.color.order_item_font_color')).opacity(0.6);
                    Text(this.order.orderRemark).fontColor($r('app.color.order_item_detail_font_color')).fontSize(14);
                  }.justifyContent(FlexAlign.SpaceBetween).width(Constants.FULL_SCREEN);

                  Row() {
                    Text('订单金额').fontSize(14).fontColor($r('app.color.order_item_font_color')).opacity(0.6);
                    Text(`￥${this.order.amount}`)
                      .fontColor($r('app.color.order_item_detail_font_color'))
                      .fontSize(14);
                  }.justifyContent(FlexAlign.SpaceBetween).width(Constants.FULL_SCREEN).margin({ top: 20, bottom: 20 });
                }.margin({ bottom: 4 });

                Column() {
                  Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
                    Text('订单编号').fontSize(14).fontColor($r('app.color.order_item_font_color')).opacity(0.6);
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
                  }.margin({ top: 20, bottom: 20 });

                  Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                    Text('下单时间').fontSize(14).fontColor($r('app.color.order_item_font_color')).opacity(0.6);
                    Text(this.order.createTime).fontColor($r('app.color.order_item_detail_font_color')).fontSize(14);
                  }.margin({ bottom: 20 });
                }.margin({ bottom: 4 });

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
              }
              .padding({
                left: 16,
                right: 16,
              });
            };
          };
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