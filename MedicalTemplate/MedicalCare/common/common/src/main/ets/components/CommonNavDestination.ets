@Component
export struct CommonNavDestination {
  title: string = ''
  bgColor: ResourceColor = $r('sys.color.ohos_id_color_sub_background')
  contentPadding: Padding = { top: 8 }
  @BuilderParam content: () => void
  onBack: () => boolean = () => false
  enableScroll: boolean = false

  build() {
    NavDestination() {
      Stack() {
        if (this.enableScroll) {
          Scroll() {
            this.content()
          }
          .width('100%')
          .height('100%')
          .align(Alignment.Top)
          .edgeEffect(EdgeEffect.None)
        } else {
          this.content()
        }
      }
      .backgroundColor(this.bgColor)
      .padding(this.contentPadding)
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Top)
    }
    .title(this.title)
    .onBackPressed(this.onBack)
  }
}