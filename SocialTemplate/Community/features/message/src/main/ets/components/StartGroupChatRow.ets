import { AppStorageV2 } from '@kit.ArkUI';
import { BarVM, BreakpointModel } from 'common';

@ComponentV2
export struct StartGroupChatRow {
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onStartGroupChatClick: () => void = () => {
  }

  build() {
    Row() {
      Text('发起群聊')
        .fontSize($r('sys.float.Body_L'))
        .backgroundColor('#564AF7')
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .textAlign(TextAlign.Center)
        .width('100%')
        .height($r('app.float.vp_46'))
        .borderRadius($r('sys.float.corner_radius_level6'))
        .onClick(() => this.onStartGroupChatClick())
    }
    .backgroundColor(Color.White)
    .alignItems(VerticalAlign.Top)
    .width('100%')
    .height(70 + BarVM.instance.aiBarH)
    .padding({
      top: $r('app.float.vp_12'),
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding
    })
  }
}