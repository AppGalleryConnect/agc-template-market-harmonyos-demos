@ComponentV2
export struct SheetTitle {
  @Param title: string = '';
  @Event onClose: () => void = () => {

  };
  @Event onConfirm: () => void = () => {

  };

  build() {
    Row({ space: 8 }) {
      Image($r('app.media.ic_record_close')).width(40).onClick(() => {
        this.onClose();
      });
      Text(this.title)
        .fontSize($r('sys.float.Title_S'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .layoutWeight(1);
      Image($r('app.media.ic_confirm')).width(40)
        .onClick(() => {
          this.onConfirm();
        });
    }.width('100%').padding({ top: 8, bottom: 8 });
  }
}