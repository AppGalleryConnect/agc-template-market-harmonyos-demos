@CustomDialog
export struct LoginConfirmDialogComponent {
  controller?: CustomDialogController;
  confirm: () => void = () => {
  };

  build() {
    Column({ space: 16 }) {
      Text(`元服务未获取phone权限或用户授权，点击确定创建一个mock账号`)
        .fontWeight(500)
        .width('100%')
        .textAlign(TextAlign.Start);

      Row({ space: 120 }) {
        Text('取消').fontWeight(500).opacity(0.6).onClick(() => {
          this.controller?.close();
        });
        Text('确定').fontWeight(500).fontColor('#E84026').onClick(() => {
          this.confirm();
          this.controller?.close();
        });
      }.width('100%').justifyContent(FlexAlign.Center);
    }
    .size({ width: '90%', height: 120 })
    .padding({ left: 12, right: 12 })
    .justifyContent(FlexAlign.Center)
  }
}