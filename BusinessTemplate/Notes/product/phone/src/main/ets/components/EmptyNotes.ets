import { BreakpointType, GlobalInfoModel } from '@ohos_agcit/notes_utils';
import { ThemeController } from '../controller/ThemeController';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct EmptyNotes {
  /** 平板侧栏等场景：空态与列表左对齐，不占中 */
  @Param alignStart: boolean = false;
  @Local globalInfo: GlobalInfoModel =
    AppStorageV2.connect<GlobalInfoModel>(GlobalInfoModel, () => new GlobalInfoModel())!;

  @Builder
  private emptyBody() {
    Column() {
      Image($r('app.media.empty_notes'))
        .width(120)
        .height(120);

      Text('岁月悠悠，心事悄悄，记录一下吧')
        .fontSize(12)
        .fontColor($r('sys.color.font_tertiary'));
    }
    .width('100%')
    .alignItems(this.alignStart ? HorizontalAlign.Start : HorizontalAlign.Center);
  }

  build() {
    if (this.alignStart) {
      Column() {
        this.emptyBody();
      }
      .width('100%')
      .height(100)
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
          top: 24,
          bottom: 0,
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
          top: 24,
          bottom: 0,
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
          top: 24,
          bottom: 0,
        },
      }).getValue(this.globalInfo.currentBreakpoint))
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start);
    } else {
      Column() {
        this.emptyBody();
      }
      .width('100%')
      .layoutWeight(1)
      .padding(new BreakpointType<Padding>({
        sm: {
          left: $r('sys.float.padding_level8'),
          right: $r('sys.float.padding_level8'),
          top: 0,
          bottom: 0,
        },
        md: {
          left: $r('sys.float.padding_level12'),
          right: $r('sys.float.padding_level12'),
          top: 0,
          bottom: 0,
        },
        lg: {
          left: $r('sys.float.padding_level16'),
          right: $r('sys.float.padding_level16'),
          top: 0,
          bottom: 0,
        },
      }).getValue(this.globalInfo.currentBreakpoint))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center);
    }
  }
}