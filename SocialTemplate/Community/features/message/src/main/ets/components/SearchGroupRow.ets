import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { SearchGroupInfoModel } from '../viewmodel/SearchGroupInfoModel';
import { messageAvatarBuilder } from './relayui/AvatarWrapperBuilder';

@ComponentV2
export struct SearchGroupRow {
  @Param @Require groupInfoVM: SearchGroupInfoModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onGroupClick: (groupInfoVM: SearchGroupInfoModel) => void =
    (_groupInfoVM: SearchGroupInfoModel) => {
    }

  build() {
    Row() {
      messageAvatarBuilder.builder(2, this.groupInfoVM.faceURL,
        this.groupInfoVM.memberAvatarList, this.groupInfoVM.memberInfoList.length);
      Blank().width($r('app.float.vp_12'));
      Text() {
        ForEach(this.groupInfoVM.normalArr, (str: string, index: number) => {
          Span(str);
          if (this.groupInfoVM.lightArr.length > index) {
            Span(this.groupInfoVM.lightArr[index])
              .fontColor('#0A59F7')
          }
        }, (str: string, index: number) => str + '_' + index);
      }
      .fontColor(Color.Black)
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Medium)
      .lineHeight($r('app.float.vp_18'))
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .textAlign(TextAlign.Start)

      Blank().width($r('app.float.vp_6'));
      Text(`(${this.groupInfoVM.count}个朋友)`)
        .fontSize($r('sys.float.Body_S'))
        .fontColor($r('app.color.color_66000000'))
        .fontWeight(FontWeight.Regular)
        .lineHeight($r('app.float.vp_18'))
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
    .onClick(() => this.onGroupClick(this.groupInfoVM))
  }
}