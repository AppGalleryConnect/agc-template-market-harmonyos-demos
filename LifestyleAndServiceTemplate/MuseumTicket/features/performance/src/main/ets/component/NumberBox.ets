import { CommonConstants } from 'commonlib';


@ComponentV2
export struct NumberBox {
  @Once @Param value: number = 0;
  @Param limit: number = Infinity;
  @Event onchange: (value: number) => void = () => {

  };


  build() {
    Row() {
      Row() {
        Image($r('app.media.icon_minus')).width(24).height(24).fillColor(CommonConstants.FONT_COLOR_BLACK);
      }.baseRowStyle().opacity(this.value === 0 ? 0.4 : 1)
      .onClick(() => {
        if (this.value > 0) {
          this.value--;
          this.onchange(this.value);
        }
      });

      TextInput({ text: this.value.toString() })
        .width(56)
        .height(32)
        .textAlign(TextAlign.Center)
        .padding(0)
        .borderRadius(0)
        .backgroundColor('transparent');

      Row() {
        Image($r('app.media.icon_plus')).width(24).height(24).fillColor(CommonConstants.FONT_COLOR_BLACK);
      }.baseRowStyle().opacity(this.value === this.limit ? 0.4 : 1)
      .onClick(() => {
        if (this.value < this.limit) {
          this.value++;
          this.onchange(this.value);
        }
      });

    }.width(120).justifyContent(FlexAlign.SpaceBetween);
  }
}

@Extend(Row)
function baseRowStyle() {
  .width(32)
  .height(32)
  .borderRadius(16)
  .justifyContent(FlexAlign.Center)
  .backgroundColor(CommonConstants.BG_COLOR_GRAY);
}
