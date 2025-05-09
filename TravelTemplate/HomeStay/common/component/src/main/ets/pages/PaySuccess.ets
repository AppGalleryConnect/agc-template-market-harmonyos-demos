import { NavPathName } from 'constant';
import { OrderParam } from 'type';
import { TitleBar } from './TitleBar';

@Builder
export function PaySuccessBuilder() {
  PaySuccess();
}

@Component
export struct PaySuccess {
  @Consume('mainPathStack') mainPathStack: NavPathStack;
  @State type: number = 0;

  back() {
    // 预订和详情页弹出栈
    if (this.type === 0) {
      this.mainPathStack.popToName(NavPathName.RESERVE);
    } else {
      this.mainPathStack.popToName(NavPathName.PURCHASE);
    }
  }

  build() {
    NavDestination() {
      Column() {
        TitleBar({
          isShowBack: true, title: '支付结果', clickEvent: () => {
            this.back();
          },
        });
        Column() {
          Image($r('app.media.tip_success')).size({ width: 88, height: 88 }).margin({ top: 72, bottom: 20 });
          Text('支付成功').fontSize(14).fontColor($r('app.color.order_item_detail_font_color')).margin({ bottom: 50 });

          Button('查看订单', { type: ButtonType.Normal })
            .borderRadius($r('sys.float.corner_radius_level4'))
            .backgroundColor($r('app.color.keyword_type_font_color'))
            .width('90%')
            .height(44)
            .onClick(() => {
              // 弹出当前栈顶
              this.mainPathStack.pop();
              this.mainPathStack.pushPathByName(NavPathName.ORDER_LIST, {
                orderStatus: 2,
                orderType: this.type,
              } as OrderParam);
            });
        };
      };
    }.hideTitleBar(true).onReady((context: NavDestinationContext) => {
      this.type = context.pathInfo.param as number;
    }).onBackPressed(() => {
      this.back();
      return true;
    });
  }
}