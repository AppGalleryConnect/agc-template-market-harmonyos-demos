@ComponentV2
export struct CommonButton {
  @Param
  bgColor:ResourceColor = $r('app.color.background_color_white')
  @Param
  buttonColor: ResourceColor = $r('app.color.theme_color');
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
    Column() {
      Button() {
        Column() {
          Text(this.title)
            .fontSize($r('sys.float.Body_L'))
            .fontWeight(FontWeight.Medium);
          if (this.subTitle) {
            Text(this.subTitle)
              .fontSize($r('sys.float.Body_S'))
              // .fontColor($r('app.color.font_color_level2_invert'));
          }
        };
      }
      .borderRadius($r('app.string.border_radius_capsule'))
      .width(this.fullWidth ? '100%' : 'auto')
      .padding( $r('app.string.space_m'))
      .backgroundColor(this.buttonColor)
      .fontColor($r('app.color.font_color_level1_invert'))
      .onClick(() => {
        this.handleClick?.();
      });
    }
    .width('100%')
    .padding($r('app.string.space_s'))
    .backgroundColor(this.bgColor)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}