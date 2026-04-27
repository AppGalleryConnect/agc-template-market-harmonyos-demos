@CustomDialog
export struct EditNameDialog {
  text: string = '';
  controller: CustomDialogController;
  onChange: (text: string) => void = () => {

  };
  onSave: () => void = () => {

  };
  onCancel: () => void = () => {

  };

  build() {
    Column() {
      Column() {
        TextInput({ placeholder: '请输入名称', text: this.text })
          .backgroundColor('transparent')
          .height(48)
          .padding({ left: 0 })
          .inputFilter('[a-zA-Z0-9\u4e00-\u9fa5_]')
          .onChange((res) => {
            this.onChange(res.trim());
          });
        Divider().margin({ bottom: 16 });
        Row() {
          Button('取消')
            .backgroundColor(Color.Transparent)
            .width('calc(50% - 4vp)')
            .height(40)
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.onCancel();
            });
          Divider().vertical(true).height(24);
          Button('保存')
            .backgroundColor(Color.Transparent)
            .width('calc(50% - 4vp)')
            .height(40)
            .fontColor($r('sys.color.font_emphasize'))
            .onClick(() => {
              this.onSave();
            });
        }.width('100%').justifyContent(FlexAlign.SpaceBetween);

      }
      .width('100%')
      .padding({
        top: 24,
        left: 24,
        right: 24,
        bottom: 16,
      })
      .borderRadius($r('sys.float.corner_radius_level16'))
      .backgroundColor('rgba(255, 255, 255, 0.9)')
      .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK);
    }.width('100%').padding({ left: 16, right: 16 });
  }
}