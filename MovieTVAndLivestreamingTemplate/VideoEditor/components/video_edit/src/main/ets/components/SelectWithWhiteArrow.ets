import { SelectOption, CustomPopupOptions } from '../model/SelectWithWhiteArrowModel'

@ComponentV2
export struct SelectWithWhiteArrow {
  @Local private showPop: boolean = false;
  // Data
  @Param options: SelectOption[] = [];
  @Param selectedIndex: number = 0;
  @Param value: string = '';
  @Param onSelect: (index: number, value: string) => void = (index: number, value: string) => {
  };
  // Style Params
  @Param selectWidth: number = 64;
  @Param selectHeight: number = 28;
  @Param fontSizeRes: number = 14;
  @Param textColor: string = '#D9FFFFFF';
  @Param cornerRes: number = 8;
  @Param bgColor: string = 'FF333333';
  // Dropdown style params
  @Param selectedBgColor: string = '#FF505050';
  @Param itemWidth: number = 70;
  @Param itemHeight: number = 32;

  // Internal helpers
  private currentLabel(): string {
    if (this.value && this.value.length > 0) {
      return this.value;
    }
    const opt = this.options?.[this.selectedIndex];
    return opt ? opt.value : '';
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Row() {
        Text(this.currentLabel())
          .font({ size: this.fontSizeRes })
          .fontColor(this.textColor)
          .padding({ right: 6 })
        Image($r('app.media.select_arrow_icon'))
          .width(8)
          .height(8)
      }
      .width(this.selectWidth)
      .height(this.selectHeight)
      .backgroundColor(this.bgColor)
      .borderRadius(this.cornerRes)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.showPop = true;
      })
      .bindPopup(this.showPop, this.getPopOptions())
    }
  }

  @Builder
  private popupBuilder() {
    Column() {
      ForEach(this.options, (opt: SelectOption, idx: number) => {
        Column() {
          Row() {
            Text(opt.value)
              .font({ size: this.fontSizeRes })
              .fontColor(this.textColor)
          }
          .width('100%')
          .height(this.itemHeight)
          .backgroundColor(idx === this.selectedIndex ? this.selectedBgColor : this.bgColor)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            try {
              this.onSelect?.(idx, opt.value);
            } finally {
              this.showPop = false;
            }
          })
        }
      })
    }
    .backgroundColor(this.bgColor)
  }

  getPopOptions(): CustomPopupOptions {
    return {
      builder: () => {
        this.popupBuilder()
      },
      enableArrow: false,
      autoCancel: true,
      placement: Placement.BottomLeft,
      width: this.itemWidth,
      offset: { x: 0, y: 4 },
      radius: this.cornerRes,
      onWillDismiss: () => {
        this.showPop = false;
      },
    }
  }
}