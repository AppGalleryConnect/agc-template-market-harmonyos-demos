import { BuyVM } from '../viewModels/BuyVM';
import { TicketListItem, TicketTypeInfo } from '../types/Index';
import { CommonConstants } from 'commonlib';
import { TicketOwner } from 'network';

@Builder
export function BuySuccessBuilder() {
  BuySuccess();
}


@ComponentV2
struct BuySuccess {
  vm: BuyVM = BuyVM.instance;

  build() {
    NavDestination() {
      Column() {
        Row({ space: 7.5 }) {
          Image($r('app.media.icon_public_success')).width(22);
          Text('购票成功').fontSize(CommonConstants.FONT_SIZE_L).fontColor(CommonConstants.FONT_COLOR_BLACK);
        }.height(84).width('100%').padding({ left: 12 }).justifyContent(FlexAlign.Center);

        Column({ space: 10 }) {
          Text('温馨提示').fontColor(CommonConstants.FONT_COLOR_BLACK);
          ForEach(this.vm.orderDetail?.notice, (item: string[]) => {
            Column() {
              ForEach(item, (v: string) => {
                Text(v).fontSize(CommonConstants.FONT_SIZE_S).fontColor(CommonConstants.FONT_COLOR_BLACK);
              }, (v: string) => v);
            }.alignItems(HorizontalAlign.Start).width('100%');
          }, (item: string[], index) => index.toString());

        }
        .padding({
          left: 20,
          right: 20,
          bottom: 10,
          top: 20,
        })
        .backgroundColor(CommonConstants.BG_COLOR_WHITE)
        .margin({ bottom: 10 });

        Column() {
          Text('购票人信息').commonTitleStyle();
          Divider();
          Column() {
            Row() {
              Text('购票人').commonTextStyle().width(48);
              Column() {
                ForEach(this.vm.orderDetail?.ticketOwner, (item: TicketOwner) => {
                  Row() {
                    Text(item.name + `（${item.ticketType}）`).commonTextStyle().width(120);
                    Text(`×${item.ticket}张`).commonTextStyle().width(40);
                    Text('¥' + item.price).commonTextStyle();
                  }.justifyContent(FlexAlign.SpaceBetween).width('100%');
                }, (item: TicketOwner) => item.personId);
                Divider();
                Row() {
                  Text('合计').commonTextStyle().width(120);
                  Text(`×${this.vm.orderDetail?.ticketOwner?.length}张`).commonTextStyle().width(40);
                  Text('¥' + this.vm.orderDetail?.orderAmount).commonTextStyle();
                }.justifyContent(FlexAlign.SpaceBetween).width('100%');
              }.width('calc(100% - 48vp)');
            }.alignItems(VerticalAlign.Top);

            Text('联系电话：' + this.vm.orderDetail?.contactPhone).commonTextStyle();
          }.alignItems(HorizontalAlign.Start).width('100%');

          Divider().margin({ bottom: 10 });
          Text('订单信息').commonTitleStyle();
          Column() {
            Text('参观时间：' + this.vm.orderDetail?.visitTime).commonTextStyle();
            Text('下单时间：' + this.vm.orderDetail?.placeTime).commonTextStyle();
            Text('付款时间：' + this.vm.orderDetail?.payTime).commonTextStyle();
            Text('实付款：¥' + this.vm.orderDetail?.actualPay).commonTextStyle();
          }.alignItems(HorizontalAlign.Start).width('100%');
        }.padding(10).backgroundColor(CommonConstants.BG_COLOR_WHITE);

      }.width('100%').height(CommonConstants.FULL_HEIGHT).backgroundColor(CommonConstants.BG_COLOR_GRAY);
    }.title('购票成功').onReady(() => {
      this.vm.getBuySuccessInfo();
    });
  }
}

@Extend(Text)
function commonTextStyle() {
  .height(32).fontSize(CommonConstants.FONT_SIZE_S).fontColor(CommonConstants.FONT_COLOR_BLACK);
}

@Extend(Text)
function commonTitleStyle() {
  .fontSize(CommonConstants.FONT_SIZE_L)
  .height(21)
  .fontWeight(500)
  .fontColor(CommonConstants.FONT_COLOR_BLACK)
  .width('100%')
  .margin({ bottom: 4 });
}
