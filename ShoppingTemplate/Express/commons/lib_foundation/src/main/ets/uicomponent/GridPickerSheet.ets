import { GRID_LIST } from '../common/Constant';

export interface GridPickerParam {
  currentGrid: string,
  confirm: (grid: string) => void
  cancel: () => void
}

@Builder
export function gridPickerSheetBuilder(param: GridPickerParam) {
  GridPickerSheet({
    currentGrid: param.currentGrid,
    confirm: param.confirm,
    cancel: param.cancel
  })
}

@ComponentV2
struct GridPickerSheet {
  @Param currentGrid: string = '';
  @Event confirm: (grid: string) => void;
  @Event cancel: () => void;
  @Local selectGridIndex: number = 0;
  @Local gridList: string[] = [];

  aboutToAppear(): void {
    this.gridList = GRID_LIST.map((item) => item.text);
    const index = this.gridList.findIndex((item) => item === this.currentGrid)
    this.selectGridIndex = index > -1 ? index : 0;
  }

  build() {
    Scroll() {
      Column() {
        TextPicker({ range: this.gridList, selected: $$this.selectGridIndex })
          .width(200)
          .disappearTextStyle({ color: Color.Black, font: { size: 15, weight: FontWeight.Regular } })
          .textStyle({ color: Color.Black, font: { size: 16, weight: FontWeight.Regular } })
          .selectedTextStyle({
            color: $r('sys.color.font_emphasize'),
            font: { size: 20, weight: FontWeight.Medium }
          })

        Row({space: 12}) {
          Button('取消')
            .fontColor($r('sys.color.font_primary'))
            .backgroundColor($r('sys.color.comp_background_tertiary'))
            .flexGrow(1)
            .onClick(() => {
              this.cancel?.();
            })

          Button('确认')
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .flexGrow(1)
            .onClick(() => {
              const grid = this.gridList[this.selectGridIndex];
              this.confirm(grid);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: 28 })
      }
      .width('100%')
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
}