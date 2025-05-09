@ComponentV2
export struct CommonTextVisibility {
  @Param description: string = ''
  @Local showDescription: boolean = false

  build() {
    Flex(this.showDescription ? { alignItems: ItemAlign.Center } : { alignItems: ItemAlign.End }) {
      Row() {
        Text(this.description)
          .fontColor($r('sys.color.font_secondary'))
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(this.showDescription ? 8 : 2)
      }
      .flexGrow(1)

      Image(this.showDescription ? $r('app.media.ic_arrow_up_text') : $r('app.media.ic_arrow_bottom_text'))
        .width(14)
        .height(14)
    }
    .borderRadius(8)
    .padding(8)
    .backgroundColor($r('sys.color.comp_background_tertiary'))
    .onClick(() => {
      this.showDescription = !this.showDescription
    })
  }
}