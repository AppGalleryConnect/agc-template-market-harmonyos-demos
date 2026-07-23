import { Constant } from 'module_base';
import { BreakpointNameEnum, GridRowColSetting } from '../constant/GridRowColSetting';

@CustomDialog
export struct DeleteConfirmDialog {
  controller?: CustomDialogController;
  delete: () => void = () => {
  };
  type: number = 0;
  @State breakpoint: string = BreakpointNameEnum.SM;

  build() {
    GridRow({ columns: 12 }) {
      GridCol({ span: 12 }) {
        Column({ space: 24 }) {
          Text(`确认删除${this.type === 0 ? '此常用旅客吗' : '此收货地址吗'}`)
            .fontSize($r('sys.float.Body_L'))
            .width('100%')
            .textAlign(TextAlign.Center);

          Row() {
            Text('取消')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .textAlign(TextAlign.Center)
              .width(144)
              .height(40)
              .onClick(() => {
                this.controller?.close();
              });
            Row()
              .width(0.5)
              .height(24)
              .backgroundColor($r('sys.color.comp_divider'))
              .margin({ left: 4, right: 4, top: 8 });
            Text('删除')
              .fontSize($r('sys.float.Body_L'))
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.warning'))
              .textAlign(TextAlign.Center)
              .width(144)
              .height(40)
              .onClick(() => {
                this.delete();
                this.controller?.close();
              });
          }.width('100%').height(56).justifyContent(FlexAlign.Center).alignItems(VerticalAlign.Top);
        }
        .justifyContent(FlexAlign.Center)
        .margin({ left: 16, right: 16 })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .padding({ top: 24, left: 16, right: 16, })
        .borderRadius(32);
      };
    }
    .onBreakpointChange((breakpoint: string) => {
      this.breakpoint = breakpoint;
    })
    .width(Constant.FULL_PERCENT)
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH });
  }
}