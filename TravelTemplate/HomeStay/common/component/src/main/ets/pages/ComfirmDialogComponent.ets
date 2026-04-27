@CustomDialog
export struct DeleteConfirmDialog {
  controller?: CustomDialogController;
  delete: () => void = () => {
  };

  build() {
    Column({ space: 16 }) {
      Text(`确认删除此常用旅客吗`)
        .fontWeight(500)
        .width('100%')
        .textAlign(TextAlign.Center);

      Row({ space: 120 }) {
        Text('取消').fontWeight(500).opacity(0.6).onClick(() => {
          this.controller?.close();
        });
        Text('删除').fontWeight(500).fontColor($r('sys.color.warning')).onClick(() => {
          this.delete();
          this.controller?.close();
        });
      }.width('100%').justifyContent(FlexAlign.Center);
    }
    .size({ width: '90%', height: 120 })
    .justifyContent(FlexAlign.Center)
    .borderRadius(16)

  }
}