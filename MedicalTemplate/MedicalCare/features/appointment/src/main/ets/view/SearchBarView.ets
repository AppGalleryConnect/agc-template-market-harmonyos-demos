@ComponentV2
export struct SearchBarView {
  @Param onSearch: (text: string) => void = () => {
  }

  build() {
    Row() {
      Image($r('app.media.ic_magnifyingglass'))
        .width(15)
        .height(15)
        .fillColor($r('sys.color.ohos_id_color_primary'))

      TextInput({ placeholder: '搜索' })
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontSize(16)
        .backgroundColor('#00000000')
        .padding(12)
        .onChange((value: string) => {
          this.onSearch(value)
        })
    }
    .height(40)
    .alignItems(VerticalAlign.Center)
    .borderRadius(24)
    .backgroundColor($r('sys.color.ohos_id_color_text_field_sub_bg'))
    .padding({
      left: 12, right: 12
    })
  }
}