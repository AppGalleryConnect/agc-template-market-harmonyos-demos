@ComponentV2
export struct DownLoadAndReadView {
  @Param title: string = ''
  @Param sum: string = ''

  build() {
    Column({ space: 4 }) {
      Text(this.sum)
        .textAlign(TextAlign.Center)
        .font({
          size: $r('sys.float.Title_S'),
          weight: FontWeight.Medium
        })
        .height($r('app.float.vp_23'))
        .fontColor($r('app.color.dark_color_B2000000'))
      Text(this.title)
        .textAlign(TextAlign.Center)
        .font({
          size: $r('sys.float.Body_S'),
        })
        .height($r('app.float.vp_14'))
        .fontColor($r('sys.color.font_tertiary'))
    }
    .height($r('app.float.vp_40'))
    .alignItems(HorizontalAlign.Center)
  }
}