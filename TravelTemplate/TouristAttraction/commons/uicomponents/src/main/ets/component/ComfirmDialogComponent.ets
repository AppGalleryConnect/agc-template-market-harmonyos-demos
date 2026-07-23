import { GridRowColSetting } from 'common';

@CustomDialog
export struct DeleteConfirmDialog {
  controller?: CustomDialogController;
  type: number = 0;
  delete: () => void = () => {
  };

  build() {
    Column({ space: 16 }) {
      Text(`确定要删除${this.type === 0 ? '此常用旅客吗？' : '此收货地址吗？'}`)
        .fontSize($r('sys.float.Body_L'))
        .fontColor($r('sys.color.font_primary'))
        .width('100%')
        .textAlign(TextAlign.Center);

      Row({ space: 8 }) {
        Text('取消')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .onClick(() => {
            this.controller?.close();
          });
        Text('删除')
          .fontWeight(FontWeight.Medium)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.warning'))
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
          .onClick(() => {
            this.delete();
            this.controller?.close();
          });
      }.width('100%').height(40).justifyContent(FlexAlign.Center);
    }
    .size({ width: '100%', height: 120 })
    .margin({ left: 16, right: 16 })
    .padding({
      top: 24,
      bottom: 16,
      left: 24,
      right: 24,
    })
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
    .justifyContent(FlexAlign.Center)
    .borderRadius($r('sys.float.corner_radius_level16'))
    .backgroundColor($r('sys.color.comp_background_primary'));
  }
}