class ButtonConstant {
  // 背景颜色
  static readonly BG_COLOR: ResourceColor = '#3F7EF7';
  // 按钮高度
  static readonly HEIGHT: Length = 40;
}

@ComponentV2
export struct CommonButton {
  // 按钮文字
  @Param title: string = '';
  // 按钮操作
  @Event handleClick: () => void;

  build() {
    Button(this.title)
      .fontWeight(FontWeight.Medium)
      .height(ButtonConstant.HEIGHT)
      .backgroundColor(ButtonConstant.BG_COLOR)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_on_primary'))
      .width('calc(100% - 32vp)')
      .onClick(() => {
        this.handleClick();
      })
  }
}