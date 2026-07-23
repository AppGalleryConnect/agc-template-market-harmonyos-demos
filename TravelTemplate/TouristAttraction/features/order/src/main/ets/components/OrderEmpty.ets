import { AppStorageV2 } from '@kit.ArkUI';
import { AppBaseModel, Constant } from 'common';
import { OrderPageVM } from '../viewmodel/OrderPageVM';

@ComponentV2
export struct OrderEmpty {
  vm: OrderPageVM = OrderPageVM.instance;
  @Consumer('mainPathStack') mainPathStack: NavPathStack = new NavPathStack();
  @Local appBaseModel: AppBaseModel = AppStorageV2.connect(AppBaseModel, () => new AppBaseModel())!;

  build() {
    Column({ space: 8 }) {
      Image(this.vm.orderType === 0 ? $r('app.media.no_ticket') : $r('app.media.no_commodity'))
        .size({ height: 120, width: 120 });
      Text(`还没有相关订单哟\n快去购买心仪${this.vm.orderType === 0 ? '门票' : '物品'}吧～`)
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.font_secondary'));
      Button(`${this.vm.orderType === 0 ? '购买门票' : '逛一逛'}`)
        .width(156)
        .backgroundColor($r('sys.color.multi_color_04'))
        .fontColor($r('sys.color.font_on_primary'))
        .onClick(() => {
          if (this.vm.orderType === 0) {
            this.mainPathStack.pop()
            this.appBaseModel.mainTabIndex = 1
            return
          }
          this.mainPathStack.pushPathByName('Mall', null, false);
        });
    }
    .width(Constant.FULL_PERCENT)
    .height(Constant.FULL_PERCENT)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center);
  }
}