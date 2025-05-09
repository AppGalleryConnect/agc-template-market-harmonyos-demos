@Component
export struct NodataPage {
  title: string = ''

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.no_data')).width(48).height(48)
        Text($r('app.string.no_search_data'))
      }.width('100%').height('100%').justifyContent(FlexAlign.Center)
    }.title(this.title).padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}