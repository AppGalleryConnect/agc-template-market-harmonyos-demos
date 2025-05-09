@Component
export struct ScanCodeResult {
  scanResult: string = ''

  build() {
    NavDestination() {
      Column({ space: 20 }) {
        Image($r('app.media.color_success')).width(48).height(48)
        Row({ space: 5 }) {
          Text('扫码结果:')
          Text(this.scanResult)
        }
      }
      .height('90%')
      .justifyContent(FlexAlign.Center)
    }.title('扫码结果')
    .padding({ top: Number(AppStorage.get('topRectHeight')) })
  }
}