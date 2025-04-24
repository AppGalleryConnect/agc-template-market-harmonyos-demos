import { Constants } from 'common'

@ComponentV2
export struct NodataPage {
  @Param title: string = ''

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.no_data')).width($r('app.float.no_data_size')).height($r('app.float.no_data_size'))
        Text($r('app.string.no_data'))
      }.width(Constants.FULL_PERCENT_HEIGHT).height(Constants.FULL_PERCENT_HEIGHT).justifyContent(FlexAlign.Center)
    }.title(this.title).padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}