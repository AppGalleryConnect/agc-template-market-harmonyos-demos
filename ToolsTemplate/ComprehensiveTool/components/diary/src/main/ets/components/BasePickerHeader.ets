

@ComponentV2
export struct BasePickerHeader {
  @Param @Require title: string;
  @Param confirm: () => void = () => {}
  @Param cancel: () => void = () => {}

  build() {
    RelativeContainer() {
      Image($r('app.media.ic_filter_close'))
        .width(40)
        .height(40)
        .id('close')
        .draggable(false)
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .onClick(() => {
          this.cancel?.()
        })

      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })
        .alignRules({
          left: { anchor: 'close', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })

      Image($r('app.media.ic_filter_confirm'))
        .width(40)
        .height(40)
        .draggable(false)
        .alignRules({
          right: { anchor: '__container__', align: HorizontalAlign.End },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .onClick(() => {
          this.confirm?.()
        })
    }
    .height(56)
    .margin({ top: 8 })
  }
}