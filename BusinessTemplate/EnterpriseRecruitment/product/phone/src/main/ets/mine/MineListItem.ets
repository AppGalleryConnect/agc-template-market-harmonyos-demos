@ComponentV2
export default struct MineListItem {
  @Param imagePath: Resource = $r('app.media.star');
  @Param text: string | Resource = '';
  @Param onClickItem: (event: ClickEvent) => void = () => {};

  build() {
    Row() {
      Row() {
        Image(this.imagePath)
          .width('24vp')
          .height('24vp')
          .backgroundColor(Color.White)
          .margin({ left: 10, right: 15 })
        Text(this.text)
          .fontSize($r('app.float.font_size_16'))
          .fontColor(Color.Black)
          .fontWeight(500)
      }

      Image($r('app.media.ic_public_arrow_right'))
        .fillColor($r('sys.color.ohos_id_color_foreground'))
        .opacity(0.2)
        .width(12)
        .height(24)

    }
    .height(45)
    .width('100%')
    .padding({ left: '2.5%' , right: '3.5%'})
    .margin({ top: 12 })
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(
      (event: ClickEvent) => {
        this.onClickItem(event)
      }
    )
  }
}