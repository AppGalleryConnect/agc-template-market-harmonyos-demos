import { AppStorageV2 } from '@kit.ArkUI';
import { BreakpointModel } from 'common';
import { SearchContactTypeEnum } from '../utils/MessageEnum';
import { SearchContactModel } from '../viewmodel/SearchContactModel';

@ComponentV2
export struct SearchContactRow {
  @Param @Require contactVM: SearchContactModel;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Event onContactClick: (contactVM: SearchContactModel) => void =
    (_contactVM: SearchContactModel) => {
    }

  build() {
    Row() {
      Image($r('app.media.' + this.contactVM.avatarUrl))
        .width($r('app.float.vp_48'))
        .aspectRatio(1)
        .objectFit(ImageFit.Fill)
        .borderRadius($r('sys.float.corner_radius_level6'))

      Blank().width($r('app.float.vp_12'));
      Column() {
        if (this.contactVM.searchType === SearchContactTypeEnum.CHAT_TYPE_PHONE) {
          Text(this.contactVM.nickName)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(Color.Black)
            .fontWeight(FontWeight.Medium)
            .lineHeight($r('app.float.vp_20'))

          Blank().width($r('app.float.vp_2'));
          Text() {
            ForEach(this.contactVM.normalArr, (str: string, index: number) => {
              Span(str);
              if (this.contactVM.lightArr.length > index) {
                Span(this.contactVM.lightArr[index])
                  .fontColor('#0A59F7')
              }
            }, (str: string, index: number) => str + '_' + index);
          }
          .fontSize($r('sys.float.Body_S'))
          .fontColor($r('app.color.color_99000000'))
          .fontWeight(FontWeight.Regular)
          .lineHeight($r('app.float.vp_18'))
        } else {
          Text() {
            ForEach(this.contactVM.normalArr, (str: string, index: number) => {
              Span(str);
              if (this.contactVM.lightArr.length > index) {
                Span(this.contactVM.lightArr[index])
                  .fontColor('#0A59F7')
              }
            }, (str: string, index: number) => str + '_' + index);
          }
          .fontSize($r('sys.float.Body_M'))
          .fontColor(Color.Black)
          .fontWeight(FontWeight.Medium)
          .lineHeight($r('app.float.vp_20'))
        }
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
    .onClick(() => this.onContactClick(this.contactVM))
  }
}