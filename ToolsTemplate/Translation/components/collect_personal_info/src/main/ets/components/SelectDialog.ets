import { Constants } from '../common/Constant';
import { ObservedInfoItem, ISelectOption } from '../common/FormModel';

@ComponentV2
export struct SelectDialog {
  @Require @Param item: ObservedInfoItem;
  @Event onSelected: (value: ISelectOption) => void = () => {
  };
  @Local selectIndex: number = 0;

  aboutToAppear(): void {
    this.selectIndex = this.item.selectOptions?.findIndex(v => v.value === this.item.value) ?? 0;
  }

  build() {
    Column() {
      List() {
        ForEach(this.item.selectOptions, (option: ISelectOption, index: number) => {
          ListItem() {
            Row() {
              Text(option.label)
                .fontSize(16)
                .fontColor($r('sys.color.font_primary'))
                .layoutWeight(1)
                .textAlign(TextAlign.Start)
              SymbolGlyph($r('sys.symbol.checkmark'))
                .fontSize(24)
                .fontColor([$r('sys.color.font_primary')])
                .margin({
                  left: Constants.PADDING_XS,
                })
                .visibility(this.selectIndex === index ? Visibility.Visible : Visibility.Hidden)
            }
            .width(Constants.FULL_PERCENT)
            .borderRadius($r('app.float.large_radius'))
            .padding(Constants.PADDING_M)
            .stateStyles({
              normal: {
                .backgroundColor($r('sys.color.comp_background_primary'))
              },
              pressed: {
                .backgroundColor($r('sys.color.interactive_pressed'))
              },
            })
            .onClick(() => {
              this.selectIndex = index;
              this.onSelected(option);
            })
          }
        }, (option: ISelectOption) => JSON.stringify(option))
      }
      .width(Constants.FULL_PERCENT)
      .padding(Constants.PADDING_XS)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
      .divider({
        strokeWidth: '1px',
        color: $r('sys.color.comp_divider'),
        startMargin: Constants.PADDING_S,
        endMargin: Constants.PADDING_S,
      })
    }
    .width(Constants.FULL_PERCENT)
    .borderRadius(20)
    .backgroundColor($r('sys.color.comp_background_primary'))
  }
}
