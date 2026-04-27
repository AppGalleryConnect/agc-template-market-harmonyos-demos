@Builder
export function customTitleBuilder(title: ResourceStr) {
  Text(title)
    .fontSize(26)
    .fontColor($r('sys.color.font_primary'))
    .fontWeight(700)
    .height(56)
    .alignSelf(ItemAlign.Start)
}