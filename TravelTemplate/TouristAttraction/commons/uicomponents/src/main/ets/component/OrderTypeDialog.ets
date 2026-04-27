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
            .padding(12)
            .backgroundColor(this.type === index ? 'rgba(0, 0, 0, 0.05)' : 'rgba(255, 255, 255, 0.1)')
            .fontWeight(500)
            .borderRadius(4)
            .opacity(0.9)
            .clip(true)
            .onClick(() => {
              this.changeType(index);
              this.controller?.close();
            });
        }, (item: string, index: number) => index + '__' + JSON.stringify(item));
      }
    }.padding(4);
  }
}