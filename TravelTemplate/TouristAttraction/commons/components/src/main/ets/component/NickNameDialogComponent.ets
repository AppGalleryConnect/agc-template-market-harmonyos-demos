@CustomDialog
export struct NickNameDialog {
  controller?: CustomDialogController;
  change: (value: string) => void = (value: string) => {
  };
  confirm: () => void = () => {
  };
  nickName: string = '';

  build() {
    Column({ space: 16 }) {
      Text(`修改昵称`).fontSize(20).fontWeight(500);
      Column() {
        TextInput({ placeholder: this.nickName, text: this.nickName })
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            this.change(value);
          });

        Divider();
      };

      Row() {
        Text('取消')
          .opacity(0.4)
          .width('50%')
          .textAlign(TextAlign.Center)
          .onClick(() => {
            this.controller?.close();
          });
        Text('确认').width('50%').textAlign(TextAlign.Center).fontColor('#64BB5C').onClick(() => {
          // 保存修改值
          this.confirm();
          this.controller?.close();
        });
      }.width('100%').justifyContent(FlexAlign.SpaceBetween);
    }
    .width('90%')
    .backgroundColor(Color.White)
    .padding(16)
    .borderRadius(16)
    .alignItems(HorizontalAlign.Start);
  }
}