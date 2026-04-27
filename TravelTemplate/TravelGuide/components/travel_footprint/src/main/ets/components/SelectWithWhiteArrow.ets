import { CustomPopupOptions } from '../viewmodel/SelectWithWhiteArrowModel'

/**
 * @usage: 白色箭头下拉选择组件，用于年份筛选等场景，支持自定义样式
 * @layout: 层叠布局，文本+箭头图标，点击弹出下拉选项列表
 * @isGen: true
 * @fileType: component
 * @zhName: 白色箭头选择器组件
 * @domain: 旅游
 */
@ComponentV2
export struct SelectWithWhiteArrow {
  @Local private showPop: boolean = false;
  // Data
  @Param options: SelectOption[] = [];
  @Param selectedIndex: number = 0;
  @Param value: ResourceStr = '';
  @Param onSelect: (index: number, value: ResourceStr) => void = (index: number, value: ResourceStr) => {
  };
  // Style Params
  @Param selectWidth: number = 64;
  @Param selectHeight: number = 28;
  @Param fontSizeRes: number = 14;
  @Param textColor: string | ResourceColor = '#D9FFFFFF';
  @Param cornerRes: number = 8;
  // Dropdown style params
  @Param selectedTextColor: string | ResourceColor = '#FF505050';
  @Param itemWidth: number = 70;
  @Param itemHeight: number = 32;

  // Internal helpers
  private currentLabel(): ResourceStr {
    if (this.value) {
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
        Image(this.showPop ? $r('app.media.ic__footprint_selected') : $r('app.media.ic__footprint_unselected'))
          .width(10)
          .height(10)
      }
      .width(this.selectWidth)
      .height(this.selectHeight)
      .backgroundColor(Color.Transparent)
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
              .fontColor(idx === this.selectedIndex ? this.selectedTextColor : Color.Black)
          }
          .width('100%')
          .height(this.itemHeight)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            try {
              this.onSelect?.(idx, opt.value);
            } finally {
              this.showPop = false;
            }
          })
        }
      },(item: SelectOption) => JSON.stringify(item))
    }
    .borderRadius(32)
    .backgroundColor('#FFFFFF')
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