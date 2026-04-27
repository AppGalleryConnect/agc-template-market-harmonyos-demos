@Builder
export function MenuItemBuilder(configuration: MenuItemConfiguration) {
  Column() {
    Row() {
      Text(configuration.value).fontSize(16).fontWeight(FontWeight.Medium).fontColor($r('sys.color.font_primary'))
      if (configuration.selected) {
        Image(configuration.icon).size({ width: 24, height: 24 })
      }
    }.justifyContent(FlexAlign.SpaceBetween)
    .height(48)
    .width('100%')
    .constraintSize({ maxWidth: '100%' })
  }.padding({ left: 16, right: 16 })
  .onClick(() => {
    configuration.triggerSelect(configuration.index, configuration.value.valueOf().toString())
  })
}