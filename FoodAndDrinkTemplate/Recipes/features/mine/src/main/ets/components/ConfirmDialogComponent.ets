@CustomDialog
export struct ConfirmDialogComponent {
  controller?: CustomDialogController;
  delete: () => void = () => {
  };

  build() {
    Column({ space: 16 }) {
      Text(`确认清除缓存？`)
        .fontWeight(500)
        .width('100%')
        .textAlign(TextAlign.Center);

      Row({ space: 120 }) {
        Text('取消').fontWeight(500).opacity(0.6).onClick(() => {
          this.controller?.close();
        });
        Text('删除').fontWeight(500).fontColor('#E84026').onClick(() => {
          this.delete();
          this.controller?.close();
        });
      }.width('100%').justifyContent(FlexAlign.Center);
    }
    .size({ width: '80%', height: 120 })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
    .borderRadius(16);
  }
}