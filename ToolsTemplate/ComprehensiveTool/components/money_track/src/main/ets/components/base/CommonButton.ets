export enum CustomButtonType {
  PRIMARY,
  SECONDARY,
  DISABLED,
}

@ComponentV2
export struct MoneyTrackButton {
  // 按钮主题色
  @Param themeColor: ResourceColor = $r('app.color.system_theme_color');
  // 按钮标题
  @Param title: string = '';
  // 按钮类型
  @Param buttonType: CustomButtonType = CustomButtonType.PRIMARY;
  // 按钮宽度
  @Param fullWidth: boolean = true;
  // 是否可用
  @Param isEnable: boolean = true;
  // 点击事件
  @Event handleClick?: () => void;

  build() {
    Row() {
      if (this.buttonType === CustomButtonType.PRIMARY) {
        Button(this.title)
          .commonButtonStyle(this.fullWidth)
          .primaryButtonStyle(this.themeColor)
          .enabled(this.isEnable)
      } else if (this.buttonType === CustomButtonType.SECONDARY) {
        Button(this.title)
          .commonButtonStyle(this.fullWidth)
          .enabled(this.isEnable)
          .secondaryButtonStyle()
      } else {
        Button(this.title)
          .commonButtonStyle(this.fullWidth)
          .enabled(this.isEnable)
          .disabledButtonStyle();
      }
    }
    .onClick(() => {
      this.handleClick?.();
    });
  }
}

@Extend(Button)
function commonButtonStyle(isFullWidth: boolean) {
  .fontSize($r('sys.float.Body_L'))
  .fontWeight(500)
  .width(isFullWidth ? '100%' : 'auto')
  .padding({
    left: $r('app.string.space_l'),
    right: $r('app.string.space_l'),
  })
  .height(40);
}

@Extend(Button)
function primaryButtonStyle(themeColor: ResourceColor) {
  .backgroundColor(themeColor)
  .fontColor($r('sys.color.font_on_primary'));
}

@Extend(Button)
function secondaryButtonStyle() {
  .backgroundColor($r('app.color.system_color_background_grey_level2'))
  .fontColor($r('sys.color.font_primary'));
}

@Extend(Button)
function disabledButtonStyle() {
  .backgroundColor($r('app.color.system_color_grey'))
  .fontColor($r('sys.color.font_tertiary'));
}