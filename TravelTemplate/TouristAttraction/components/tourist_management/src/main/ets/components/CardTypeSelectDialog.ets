import { CARD_TYPE_OPTIONS } from 'module_base';
import { GridRowColSetting } from '../constant/GridRowColSetting';
import { TouristVM } from '../viewmodel/TouristVM';

@CustomDialog
export struct CardTypeSelectDialog {
  controller?: CustomDialogController;
  vm: TouristVM = TouristVM.instance;
  @Prop cardType: number = 0;
  change: (cardType: number) => void = () => {
  };

  aboutToAppear(): void {
    if (this.cardType < 0) {
      this.change(0);
    }
  }

  build() {
    Column() {
      TextPicker({ range: CARD_TYPE_OPTIONS, selected: $$this.cardType })
        .width(this.vm.getAddWidth)
        .disappearTextStyle({
          font: { size: $r('sys.float.Body_M') },
        })// 设置所有选项中除了最上、最下及选中项以外的文本颜色、字号、字体粗细。
        .textStyle({
          font: {
            size: $r('sys.float.Body_L'),
          },
        })// 设置选中项的文本颜色、字号、字体粗细。
        .selectedTextStyle({
          color: $r('sys.color.multi_color_04'), font: { size: $r('sys.float.Title_S'), weight: FontWeight.Medium },
        })
        .canLoop(true)
        .divider({ strokeWidth: 1, color: $r('sys.color.comp_divider') })
        .onClick(() => {
          this.controller?.close();
        })
        .onChange(() => {
          this.change(this.cardType);
        });
    }
    .padding(24)
    .backgroundColor($r('sys.color.comp_background_primary'))
    .margin({ left: 16, right: 16 })
    .constraintSize({ maxWidth: GridRowColSetting.DIALOG_MAX_WIDTH })
    .borderRadius(32);
  }
}