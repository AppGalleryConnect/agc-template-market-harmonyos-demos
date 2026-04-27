import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { CMChatGroupInfo } from 'instant_messaging';

@ComponentV2
export struct MyGroupRow {
  @Param @Require groupInfo: CMChatGroupInfo;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;

  build() {
    Row() {
      // 头像
      this.setAvatarImage();

      Blank().width($r('app.float.vp_12'));

      // 名称
      Text(this.groupInfo.groupName)
        .fontSize($r('sys.float.Body_M'))
        .fontColor(Color.Black)
        .fontWeight(FontWeight.Medium)
        .lineHeight($r('app.float.vp_18'))
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .layoutWeight(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width('100%')
    .height($r('app.float.vp_64'))
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
    .backgroundColor(Color.White)
    .padding({
      top: $r('app.float.vp_8'), bottom: $r('app.float.vp_8'),
      left: this.breakPointModel.pagePadding,
      right: this.breakPointModel.pagePadding
    })
  }

  @Builder
  setAvatarImage() {
    // 有头像
    if (this.groupInfo.faceURL.length > 0) {
      Image(this.groupInfo.faceURL)
        .objectFit(ImageFit.Fill)
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .borderRadius($r('sys.float.corner_radius_level6'))
        .backgroundColor($r('app.color.color_F1F3F5'))
        .clip(true)
    } else {
      // 无头像
      Column({ space: this.groupInfo.memberInfoList.length > 4 ? 2 : 4 }) {
        ForEach(this.groupInfo.memberAvatarList, (rowAvatars: string[]) => {
          Row({ space: this.groupInfo.memberInfoList.length > 4 ? 2 : 4 }) {
            ForEach(rowAvatars, (userAvatar: string) => {
              Image($r('app.media.' + userAvatar))
                .width(this.groupAvatarsWidth)
                .aspectRatio(1)
                .objectFit(ImageFit.Fill)
            }, (userAvatar: string, index: number) => userAvatar + index.toString());
          }
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)
        }, (index: number) => index.toString());
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .width($r('app.float.vp_48'))
      .height($r('app.float.vp_48'))
      .borderRadius($r('sys.float.corner_radius_level6'))
      .backgroundColor($r('app.color.color_F1F3F5'))
      .clip(true)
    }
  }

  @Computed
  get groupAvatarsWidth() {
    if (this.groupInfo.memberInfoList.length < 5) {
      return $r('app.float.vp_20');
    }

    return 40 / 3.0;
  }
}