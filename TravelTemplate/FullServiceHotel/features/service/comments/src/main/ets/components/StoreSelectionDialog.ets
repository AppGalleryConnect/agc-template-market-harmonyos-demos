import { SubmitCommentPageVM } from '../viewModels/SubmitCommentPageVM';

@CustomDialog
export struct StoreSelectionDialog {
  vm: SubmitCommentPageVM = SubmitCommentPageVM.instance;
  controller?: CustomDialogController;
  @State curIndex: number = 0;
  cancel: () => void = () => {
  };
  confirm: (item: string) => void = () => {
  };

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_left_arrow'))
          .height('32lpx')
          .onClick(() => {
            if (this.controller !== undefined) {
              this.controller.close();
            }
          });

        Text('门店选择')
          .fontSize($r('app.string.font_size_32'));
        Text('保存')
          .fontSize($r('app.string.font_size_32'))
          .fontColor($r('app.color.font_color_link'))
          .onClick(() => {
            this.confirm(this.vm.hotelLabelList[this.curIndex]);
            this.controller?.close();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween);

      TextPicker({ range: this.vm.hotelLabelList, selected: this.curIndex })
        .onChange((value: string | string[], index: number | number[]) => {
          this.curIndex = index as number;
        })
        .textStyle({
          color: $r('app.color.font_color_level1'),
          font: { size: $r('app.string.font_size_28'), weight: FontWeight.Normal },
        })
        .selectedTextStyle({
          color: $r('app.color.font_color_level1'),
          font: { size: $r('app.string.font_size_28'), weight: FontWeight.Bold },
        })
        .canLoop(false)
        .margin({
          top: $r('app.string.margin_m'),
        })
        .height(200)
        .width('100%');
      // .indicator(false)
    }
    .backgroundColor($r('app.color.font_color_level1_invert'))
    .width('100%')
    .borderRadius({
      topLeft: $r('app.string.border_radius_32'),
      topRight: $r('app.string.border_radius_32'),
    })
    .padding($r('app.string.padding_m'))
    .justifyContent(FlexAlign.Start);
  }
}