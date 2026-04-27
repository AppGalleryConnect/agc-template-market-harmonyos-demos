@Builder
export function buildCommonEmptyStatus(message?: string) {
  Column() {
    Image($r('app.media.ic_search_empty'))
      .width(120)
      .height(120);
    Text(message ?? '暂无搜索结果')
      .fontSize(14)
      .fontColor($r('app.color.font_color_level2'));
  }
  .width('100%')
  .layoutWeight(1)
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.Center)
}