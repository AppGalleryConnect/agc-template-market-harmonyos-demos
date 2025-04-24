import { ComponentConst } from '../../../../Index';

@ComponentV2
export struct LoadingPageWrapper {
  @Param @Require isLoading: boolean;
  @Param loadingText: string | Resource = $r('app.string.loading');
  @BuilderParam contentBuilder: () => void;

  build() {
    Stack() {
      this.contentBuilder();
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color(Color.Grey)
            .width(80).height(80)
          Text(this.loadingText)
            .fontSize(16)
            .fontColor(Color.Grey)
        }
        .backgroundColor($r('sys.color.font_on_secondary'))
        .justifyContent(FlexAlign.Center)
        .width(ComponentConst.FULL_PARENT)
        .height(ComponentConst.FULL_PARENT)
        .justifyContent(FlexAlign.Center)
      }
    }
    .width(ComponentConst.FULL_PARENT)
    .height(ComponentConst.FULL_PARENT)

  }
}