import { OrderTicketVM } from '../viewModels/OrderTicketVM';
import { CommonConstants } from 'commonlib';

@Builder
export function OrderSuccessBuilder() {
  OrderSuccess();
}


@ComponentV2
struct OrderSuccess {
  vm: OrderTicketVM = OrderTicketVM.instance;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Row({ space: 7.5 }) {
            Image($r('app.media.icon_public_success')).width(22);
            Text('预约成功').fontSize(CommonConstants.FONT_SIZE_L).fontColor(CommonConstants.FONT_COLOR_BLACK);
          }.height(84).width('100%').padding({ left: 12 }).justifyContent(FlexAlign.Center);

          Column({ space: 10 }) {
            Text('温馨提示').fontColor(CommonConstants.FONT_COLOR_BLACK);
            ForEach(this.vm.orderSuccessDetail?.notice, (item: string[]) => {
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
            Text('参观人信息').commonTitleStyle();
            Divider();
            Column() {
              Text('参观人：' + this.vm.orderSuccessDetail?.visitors?.map((item) => item.name).join('、'))
                .commonTextStyle();
              Text(`参观人数：${this.vm.orderSuccessDetail?.visitor}人`).commonTextStyle();
              Text('联系电话：' + this.vm.orderSuccessDetail?.contactPhone).commonTextStyle();
            }.alignItems(HorizontalAlign.Start).width('100%');

            Divider().margin({ bottom: 10 });
            Text('订单信息').commonTitleStyle();
            Column() {
              Text('参观时间：' + this.vm.orderSuccessDetail?.visitTime).commonTextStyle();
              Text('预约时间：' + this.vm.orderSuccessDetail?.orderTime).commonTextStyle();
            }.alignItems(HorizontalAlign.Start).width('100%');
          }.padding(10).backgroundColor(CommonConstants.BG_COLOR_WHITE);

        }.width('100%');
      }
      .height(CommonConstants.FULL_HEIGHT)
      .backgroundColor(CommonConstants.BG_COLOR_GRAY)
      .align(Alignment.Top)
      .scrollBar(BarState.Off);

    }.title('预约成功');
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
