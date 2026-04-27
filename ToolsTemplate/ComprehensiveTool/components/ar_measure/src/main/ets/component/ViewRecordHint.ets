import { MeasureRecord } from '../model/Index';
import { PromptActionUtil } from '../util/PromptActionUtil';

@Builder
export function viewRecordHint(record: MeasureRecord) {
  Column({ space: 24 }) {
    Text(record.record)
      .fontColor($r('sys.color.font_primary'))
      .opacity(0.9);
    Row() {
      Text('取消').fontColor($r('sys.color.font_emphasize')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        PromptActionUtil.closeDialog(PromptActionUtil.getContentNode());
      });
      Text('|').height(36).opacity(0.05);
      Text('复制').fontColor($r('sys.color.warning')).width('50%').textAlign(TextAlign.Center).onClick(() => {
        record.copyCallBack();
        PromptActionUtil.closeDialog(PromptActionUtil.getContentNode());
      });
    };
  }
  .padding(24)
  .borderRadius(32)
  .backgroundColor($r('sys.color.ohos_id_blur_style_component_ultra_thick_color'))
  .width('90%');
}