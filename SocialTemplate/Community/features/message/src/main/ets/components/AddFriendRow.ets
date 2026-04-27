import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { AddFriendSingleModel } from '../viewmodel/AddFriendSingleModel';

@ComponentV2
export struct AddFriendRow {
  @Param @Require friendVM: AddFriendSingleModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onFriendClick: (friendVM: AddFriendSingleModel) => void = (_friendVM: AddFriendSingleModel) => {
  }

  build() {
    Row() {
      Image(this.friendVM.icon)
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
      Blank().width($r('app.float.vp_12'));
      Column() {
        Text(this.friendVM.title)
          .fontSize($r('sys.float.Body_M'))
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_22'))
        Blank().width($r('app.float.vp_2'));
        Text(this.friendVM.subtitle)
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('app.color.color_66000000'))
          .fontWeight(FontWeight.Regular)
          .lineHeight($r('app.float.vp_18'))
      }
      .alignItems(HorizontalAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_72'))
    .padding({
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding
    })
    .onClick(() => this.onFriendClick(this.friendVM))
  }
}