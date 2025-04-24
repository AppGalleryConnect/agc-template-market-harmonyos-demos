@ComponentV2
export struct CommonButton {
  @Param
  bgColor: ResourceColor = $r('app.color.icon_color_highlight');
  @Param
  title: string = '';
  @Param
  subTitle: string = '';
  @Param
  fullWidth: boolean = true;
  @Event
  handleClick?: () => void = () => {
  };

  build() {
    Row() {
      Button(this.title) {
        Column() {
          Text(this.title)
            .fontSize($r('app.string.font_size_32'))
            .fontWeight(500);
          if (this.subTitle) {
            Text(this.subTitle)
              .fontSize($r('app.string.font_size_20'))
              .fontColor($r('app.color.font_color_level2_invert'));
          }
        };
      }
      .width(this.fullWidth ? '100%' : 'auto')
      .padding({
        left: $r('app.string.padding_m'),
        right: $r('app.string.padding_m'),
      })
      .height('88lpx')
      .backgroundColor(this.bgColor)
      .fontColor($r('app.color.icon_color_level1_invert'))
      .onClick(() => {
        this.handleClick?.();
      });
    }
    .padding({
      left: $r('app.string.padding_s'),
      right: $r('app.string.padding_s'),
    });
  }
}