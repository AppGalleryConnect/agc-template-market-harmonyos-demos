/* eslint-disable */
export enum CustomButtonType {
  PRIMARY,
  OUTLINE,
  DISABLED,

}

@ComponentV2
export struct CommonButton {
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
          .onClick(() => {
            this.handleClick?.();
          });
      } else if (this.buttonType === CustomButtonType.OUTLINE) {
        Button(this.title)
          .commonButtonStyle(this.fullWidth)
          .outlineButtonStyle(this.themeColor)
          .enabled(this.isEnable)
          .onClick(() => {
            this.handleClick?.();
          });
      } else {
        Button(this.title)
          .commonButtonStyle(this.fullWidth)
          .enabled(this.isEnable)
          .disabledButtonStyle();
      }
    }
    .padding({
      left: $r('app.string.padding_l'),
      right: $r('app.string.padding_l'),
    });
  }
}

@Extend(Button)
function commonButtonStyle(isFullWidth: boolean) {
  .fontSize($r('app.string.font_size_16'))
  .fontWeight(500)
  .width(isFullWidth ? '100%' : 'auto')
  .padding({
    left: $r('app.string.padding_l'),
    right: $r('app.string.padding_l'),
  })
  .height(40);
}

@Extend(Button)
function primaryButtonStyle(themeColor: ResourceColor) {
  .backgroundColor(themeColor)
  .fontColor($r('app.color.icon_color_level1_invert'));

}

@Extend(Button)
function outlineButtonStyle(themeColor: ResourceColor) {
  .backgroundColor($r('app.color.system_color_background_white'))
  .fontColor(themeColor)
  .borderWidth(1)
  .borderColor(themeColor);
}

@Extend(Button)
function disabledButtonStyle() {
  .backgroundColor($r('app.color.system_color_grey'))
  .fontColor($r('app.color.font_color_level3'));
}