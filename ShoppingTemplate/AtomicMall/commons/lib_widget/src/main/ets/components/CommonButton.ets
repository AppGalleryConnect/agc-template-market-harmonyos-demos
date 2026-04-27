@ComponentV2
export struct CommonButton {
  @Param
  bgColor: ResourceColor = $r('app.color.theme_color');
  @Param
  fontColor: ResourceColor = $r('app.color.font_color_level1_invert')
  @Param
  customBorderColor?: ResourceColor = undefined
  @Param
  isLoading: boolean = false
  @Param
  title: string = '';
  @Param
  icon: ResourceStr = ''
  @Param
  fullWidth: boolean = true;
  @Param
  containerPadding: Length = $r('app.float.space_l')
  @Event
  handleClick?: () => void = () => {
  };

  build() {
    Row() {
      Button(this.title) {
        Row() {
          if (this.icon) {
            Image(this.icon)
              .width(24)
              .height(24)
              .objectFit(ImageFit.Contain)
              .margin({ right: $r('app.float.space_xs') })
          }
          Text(this.title)
            .fontSize($r('app.float.font_size_16'))
            .fontWeight(500);
        }
      }
      .width(this.fullWidth ? '100%' : 'auto')
      .padding({
        left: $r('app.float.space_m'),
        right: $r('app.float.space_m'),
      })
      .enabled(!this.isLoading)
      .height(40)
      .borderRadius($r('app.float.border_radius_capsule'))
      .backgroundColor(this.bgColor)
      .borderWidth(this.customBorderColor ? 1 : 0)
      .borderColor(this.customBorderColor ? this.customBorderColor : this.bgColor)
      .fontColor(this.fontColor)
      .onClick(() => {
        this.handleClick?.();
      });
    }
    .padding({
      left: this.containerPadding,
      right: this.containerPadding,
    });
  }
}