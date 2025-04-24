@ComponentV2
export struct ServiceTitle {
  @Param title: ResourceStr = ''
  @Param titleColor: ResourceStr = ''

  build() {
    Flex({ justifyContent: FlexAlign.Start,alignItems:ItemAlign.Center }) {
      Text(this.title)
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Title_M'))
        .fontColor(this.titleColor ? this.titleColor : $r('sys.color.font_primary'))
    }
    .height(56)
    .margin({ top: Number(AppStorage.get('topRectHeight')), left: 16, right: 16 })
  }
}