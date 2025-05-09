@Component
export struct EmptyComponent {
  private outerHeight?: number | string = '100%';

  build() {
    Flex({
      justifyContent: FlexAlign.Center,
      alignItems: ItemAlign.Center,
      direction: FlexDirection.Column
    }) {
      Image($r('app.media.ic_empty'))
        .width('60vp')
        .height('60vp')
      Text('No data')
        .fontSize('10fp')
        .margin({ top: '10vp' })
    }
    .width('100%')
    .height(this.outerHeight !== undefined ? this.outerHeight : '100%')
  }
}