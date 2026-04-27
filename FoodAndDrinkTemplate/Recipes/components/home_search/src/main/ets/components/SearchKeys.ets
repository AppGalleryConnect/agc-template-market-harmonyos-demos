import { LengthMetrics } from '@kit.ArkUI';


@ComponentV2
export struct SearchKeys {
  @Param keys: string[] = []
  @Param title: string = ''
  @BuilderParam clearBuilderParam: () => void = this.clearBuilder;
  @Event onKeyClick: (key: string) => void = () => {

  };

  @Builder
  clearBuilder() {

  }

  build() {
    Column() {
      Row() {
        Text(this.title).fontSize(12).fontColor($r('sys.color.font_primary'));
        this.clearBuilderParam()
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.keys, (item: string) => {
          Text(item)
            .labelBaseStyle()
            .onClick(() => {
              this.onKeyClick(item)
            });
        }, (item: string, index) => item + index.toString());
      };
    }
  }
}


@Extend(Text)
function labelBaseStyle() {
  .padding({
    top: 4,
    bottom: 4,
    left: 8,
    right: 8,
  })
  .fontSize(14)
  .borderRadius(14)
  .backgroundColor($r('sys.color.comp_background_tertiary'))
  .focusable(true)
  .focusOnTouch(true);
}
