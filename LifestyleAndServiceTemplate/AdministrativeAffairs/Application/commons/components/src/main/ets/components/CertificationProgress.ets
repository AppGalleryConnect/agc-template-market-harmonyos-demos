import { Constants } from 'common'

@ComponentV2
export struct CertificationProgress {
  @Param title: string = ''

  build() {
    NavDestination() {
      Column({ space: Constants.CONTAINER_SPACE_TEN }) {
        Image($r('app.media.no_data')).width($r('app.float.empty_width')).height($r('app.float.empty_height'))
        Text($r('app.string.no_data'))
      }.width(Constants.FULL_PERCENT_WIDTH).height(Constants.FULL_PERCENT_HEIGHT).justifyContent(FlexAlign.Center)
    }.title(this.title).padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}