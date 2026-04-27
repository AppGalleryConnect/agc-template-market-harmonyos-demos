import { common } from '@kit.AbilityKit';

@Extend(Row)
function operationRow(color: string) {
  .height(40)
  .width('100%')
  .backgroundColor(color)
  .borderRadius(20)
  .justifyContent(FlexAlign.Center);
}

@Builder
export function CustomServiceDialog(context: Context, phone: string) {
  Column({ space: 12 }) {
    Text(phone).fontSize(18).fontWeight(500).opacity(0.9).fontColor($r('sys.color.black'));

    Row() {
      Image($r('app.media.phone')).size({ width: 24, height: 24 }).fillColor($r('sys.color.white'));
      Text('一键拨号').fontWeight(500).fontColor($r('sys.color.white'));
    }
    .operationRow('#64BB5C').onClick(() => {
      (context as common.UIAbilityContext).eventHub.emit('makeCall', phone);
    });

    Row() {
      Text('取消').fontColor('rgba(0,0,0,0.60)').fontWeight(500);
    }
    .operationRow('rgba(0,0,0,0.05)').onClick(() => {
      (context as common.UIAbilityContext).eventHub.emit('cancelCall');
    });
  }
  .width('90%')
  .borderRadius(16)
  .backgroundColor($r('sys.color.white'))
  .padding(12)
  .alignItems(HorizontalAlign.Center)
  .margin({ top: 16 });
}