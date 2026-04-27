import { Hint } from '../model/Index';

@Builder
export function clearHistoryHint(hint: Hint) {
  Column({ space: 24 }) {
    Text(hint.message)
      .fontColor($r('sys.color.font_primary'))
      .opacity(0.9);
    Row() {
      Text('取消').fontColor($r('sys.color.font_emphasize')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        hint.cancelCallBack();
      });
      Text('|').height(36).opacity(0.05);
      Text('删除').fontColor($r('sys.color.warning')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        hint.confirmCallBack();
      });
    };
  }
  .padding(24)
  .borderRadius(32)
  .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
  .width('90%');
}