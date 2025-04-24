@CustomDialog
export struct OrderTypeDialog {
  controller?: CustomDialogController;
  changeType: (index: number) => void = () => {
  };
  type: number = 0;

  build() {
    Column() {
      Column() {
        ForEach(['门票订单', '购物订单'], (item: string, index: number) => {
          Text(item)
            .textAlign(TextAlign.Center)
            .padding(10)
            .backgroundColor(this.type === index ? 'rgba(0, 0, 0, 0.05)' : 'rgb(255, 255, 255)')
            .fontWeight(500)
            .borderRadius(8)
            .opacity(0.9)
            .clip(true)
            .onClick(() => {
              this.changeType(index);
              this.controller?.close();
            });
        }, (item: string, index: number) => index + '__' + JSON.stringify(item));
      }.borderRadius(16);
    }.padding(2).borderRadius(16).backgroundColor('rgb(255, 255, 255)');
  }
}