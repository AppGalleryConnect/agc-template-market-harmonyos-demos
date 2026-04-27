

@ComponentV2
export struct CommonEmpty {
  @Param emptyDesc: ResourceStr = '暂无内容';
  @Param emptyIcon: ResourceStr = $r('app.media.img_template_empty');
  @Param imgSize: SizeOptions = { width: 120, height: 120 };
  @Event clickAction: () => void

  build() {
    Column({ space: 12 }) {
      Image(this.emptyIcon).size(this.imgSize)
      Text(this.emptyDesc)
        .fontSize(14)
        .fontWeight(400)
        .fontColor($r('sys.color.font_tertiary'))
        .lineHeight(19)
        .onClick(() => {
          this.clickAction?.();
        })
    }
  }
}