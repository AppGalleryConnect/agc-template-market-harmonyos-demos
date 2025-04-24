@ComponentV2
export struct ViewDetailComponent {
  build() {
    Row() {
      Text('详情').fontSize(14).opacity(0.6)
      Image($r('app.media.chevron_right')).size({ width: 12, height: 24 })
    }
  }
}