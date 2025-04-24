import { CommonConstants } from '../constants/CommonConstants';

@ComponentV2
export struct FilterButton {
  @Param clickIndex: number = 0;
  @Param selfIndex: number = 0;
  @Param title: string = '';
  @Event invoke: (index: number) => void = () => {
  }

  build() {
    Button(this.title)
      .backgroundColor(this.selfIndex === this.clickIndex ? $r('app.color.common_blue') : $r('app.color.button_gray'))
      .fontColor(this.selfIndex === this.clickIndex ? Color.White : Color.Black)
      .fontWeight(CommonConstants.FONT_WEIGHT_600)
      .onClick(() => {
        this.invoke(this.selfIndex)
      })
  }
}