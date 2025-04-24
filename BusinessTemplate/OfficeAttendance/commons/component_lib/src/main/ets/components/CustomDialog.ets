@CustomDialog
export struct ConfirmView {
  private controller: CustomDialogController;
  protected confirm: () => void = () => {
  };
  protected titleResID: Resource | null = null;
  protected contentResID: Resource | null = null;
  protected btnCancelResID: Resource = $r('app.string.btn_cancel');
  protected btnConfirmResID: Resource = $r('app.string.btn_confirm');
  protected btnCancelFontColor: Resource = $r('app.color.sys_default_blue');
  protected btnConfirmFontColor: Resource = $r('app.color.sys_default_blue');

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.titleResID).fontSize(20).fontWeight(FontWeight.Bold)
        }.width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .height(56)

        Row() {
          Text(this.contentResID).fontSize(16).fontWeight(FontWeight.Regular)
        }.width('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
        .height(21)
      }.layoutWeight(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      Row() {
        Row() {
          Text(this.btnCancelResID)
            .fontColor(this.btnCancelFontColor)
            .onClick(() => {
              this.controller.close();
            })

        }.width('50%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)


        Row() {
          Text(this.btnConfirmResID)
            .fontColor(this.btnConfirmFontColor)
            .onClick(() => {
              this.confirm();
              this.controller.close();
            })
        }.width('50%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
      }.height(56)
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(164)
    .width(328)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .borderRadius(32)
  }
}