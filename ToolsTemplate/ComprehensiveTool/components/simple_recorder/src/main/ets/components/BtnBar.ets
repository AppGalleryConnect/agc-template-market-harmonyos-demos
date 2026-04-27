@ComponentV2
export struct BtnBar {
  @Param text: string = '';
  @Param isActive: boolean = false;
  @Event itemClick: () => void = () => {

  };

  build() {
    Text(this.text)
      .fontColor(this.isActive ? $r('sys.color.font_on_primary') : $r('sys.color.font_primary'))
      .fontSize($r('sys.float.Body_M'))
      .fontWeight(FontWeight.Regular)
      .width(76)
      .height(28)
      .borderRadius(14)
      .textAlign(TextAlign.Center)
      .backgroundColor(this.isActive ? '#2070F3' : $r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.itemClick();
      });
  }
}
