@Builder
export function CommonEmptyView(text: string = '暂无数据') {
  ListItem() {
    Column({ space: 16 }) {
      Image($r('app.media.ic_no_data'))
        .width(80)

      Text(text)
        .fontSize(14)
        .fontColor($r('sys.color.ohos_id_color_text_hint'))
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .padding(16)
  }
}