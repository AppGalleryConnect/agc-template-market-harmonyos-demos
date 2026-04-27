import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { MessageContactModel } from '../viewmodel/MessageContactModel';

@ComponentV2
export struct ContactSingleRow {
  @Param @Require friendInfoVM: MessageContactModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onFriendClick: (friendInfoVM: MessageContactModel) => void = (_friendInfoVM: MessageContactModel) => {
  }

  build() {
    Row() {
      Radio({
        value: 'Radio1', group: this.friendInfoVM.userId,
        indicatorType: RadioIndicatorType.TICK
      })
        .checked($$this.friendInfoVM.isSelect)
        .height($r('app.float.vp_20'))
        .aspectRatio(1)
        .enabled(this.friendInfoVM.isChange)
        .hitTestBehavior(HitTestMode.None)
      Blank().width($r('app.float.vp_12'));
      Image($r('app.media.' + this.friendInfoVM.avatarUrl))
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
        .borderRadius($r('sys.float.corner_radius_level6'))
      Blank().width($r('app.float.vp_12'));
      Text(this.friendInfoVM.nickName)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.vp_18'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
        .textAlign(TextAlign.Start)
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.vp_64'))
    .padding({
      top: $r('app.float.vp_8'),
      left: this.breakPointModel.pagePadding,
      bottom: $r('app.float.vp_8'),
      right: this.breakPointModel.pagePadding
    })
    .onClick(() => {
      if (this.friendInfoVM.isChange) {
        this.friendInfoVM.isSelect = !this.friendInfoVM.isSelect;
        this.onFriendClick(this.friendInfoVM);
      }
    })
  }
}