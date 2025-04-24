import { Constant, Logger } from 'common';
import { TitleBar } from 'components';
import { GetOrderDetailRequest } from 'network';

@Builder
export function PaySuccessBuilder() {
  PaySuccess();
}

@ComponentV2
export struct PaySuccess {
  @Local orderNo: string = '';
  @Local category: number = 0;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '支付结果', clickEvent: () => {
            this.mainPathStack.pop();
          },
        });

        Column() {
          Column({ space: 14 }) {
            Image($r('app.media.success')).height(80).width(80);
            Text('支付成功').fontSize(14).fontColor('rgba(0, 0, 0, 0.6)');
          }.margin({ top: 90, bottom: 90 });

          Row() {
            Button('查看订单')
              .width(Constant.FULL_PERCENT)
              .padding({ left: 24, right: 24 })
              .backgroundColor('rgb(100, 187, 92)')
              .fontColor(Color.White)
              .fontSize(14)
              .onClick(() => {
                this.mainPathStack.pushPathByName(this.category === 0 ? 'TicketOrderDetail' : 'CommodityOrderDetail', {
                  category: this.category,
                  orderNo: this.orderNo,
                } as GetOrderDetailRequest);
              });
          }.padding({ left: 24, right: 24 });
        }.height('90%').justifyContent(FlexAlign.Start);
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      let params = context.pathInfo.param as GetOrderDetailRequest;
      this.orderNo = params.orderNo ?? '';
      this.category = params.category ?? 0;
      Logger.info('purchase info is ' + this.orderNo);
    });
  }
}