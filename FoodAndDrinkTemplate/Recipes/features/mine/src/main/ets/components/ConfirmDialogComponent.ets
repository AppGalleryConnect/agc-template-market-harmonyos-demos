import { CommonConstants, DialogParams } from 'commonlib';
@Builder
export function ConfirmDialogComponent(params:DialogParams) {
    Column({ space: 16 }) {
      Text(params.title)
        .fontWeight(500)
        .width('100%')
        .textAlign(TextAlign.Center);

      Row({ space: 120 }) {
        Text('取消').fontWeight(500).opacity(0.6).onClick(() => {
          if(params.cancelFunc){
            params.cancelFunc();
          }
        });
        Text('删除').fontWeight(500).fontColor('#E84026').onClick(() => {
          if(params.confirmFunc){
            params.confirmFunc();
          }
        });
      }.width('100%').justifyContent(FlexAlign.Center);
    }
    .size({ width: '80%', height: 120 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor($r('sys.color.comp_background_gray'))
    .borderRadius(16);
}