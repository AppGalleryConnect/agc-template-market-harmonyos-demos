import { ComponentConst } from '../../../../Index';

@ComponentV2
export struct LoadingComponentWrapper {
  @Param @Require isLoading: boolean;
  @BuilderParam contentBuilder: () => void;

  build() {
    Stack() {
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .color(Color.Grey)
            .width(80).height(80)
          Text($r('app.string.loading'))
            .fontSize(16)
            .fontColor(Color.Grey)
        }
        .width(ComponentConst.FULL_PARENT)
        .height(ComponentConst.AUTO_SIZE)
        .justifyContent(FlexAlign.Center)
      } else {
        this.contentBuilder();
      }
    }
  }
}