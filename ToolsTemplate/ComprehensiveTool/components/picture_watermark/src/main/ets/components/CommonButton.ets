class ButtonConstant {
  // 背景颜色
  static readonly BG_COLOR: ResourceColor = $r('sys.color.comp_background_emphasize');
  // 按钮高度
  static readonly HEIGHT: Length = 40;
  // 按钮宽度
  static readonly WIDTH: Length = 'calc(100% - 32vp)';
}

@ComponentV2
export struct CommonButton {
  // 按钮文字
  @Param title: string = '';
  // 按钮宽度
  @Param btnWidth: Length = ButtonConstant.WIDTH;
  // 按钮操作
  @Event handleClick: () => void;

  build() {
    Button(this.title)
      .width(this.btnWidth)
      .height(ButtonConstant.HEIGHT)
      .fontWeight(FontWeight.Medium)
      .fontSize($r('sys.float.Body_L'))
      .fontColor($r('sys.color.font_on_primary'))
      .backgroundColor(ButtonConstant.BG_COLOR)
      .onClick(() => {
        this.handleClick();
      })
  }
}