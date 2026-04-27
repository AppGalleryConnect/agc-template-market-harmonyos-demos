import { PopViewUtils } from 'lib_foundation';

export const MONTH_LIST: string[] = [
  '01月',
  '02月',
  '03月',
  '04月',
  '05月',
  '06月',
  '07月',
  '08月',
  '09月',
  '10月',
  '11月',
  '12月',
];

export interface MonthFilterParam {
  monthDate: string,
  confirm: (date: string) => void,
  cancel: () => void,
}


@Builder
function monthFilterSheetBuilder(param: MonthFilterParam) {
  MonthFilterSheet({
    monthDate: param.monthDate,
    confirm: param.confirm,
    cancel: param.cancel,
  })
}

@ComponentV2
struct MonthFilterSheet {
  @Param monthDate: string = '';
  @Event confirm: (date: string) => void;
  @Event cancel: () => void;
  @Local value: [string, string] = ['', ''];

  @Computed
  get pickerGroup() {
    const curYear = new Date().getFullYear();
    const yearList: string[] = [];
    for (let i = 0; i <= curYear - 1970; i++) {
      yearList.push(`${1970 + i}年`);
    }
    return [yearList, MONTH_LIST];
  }

  @Computed
  get selectedMonth() {
    const year = this.value[0].split('年')[0];
    const month = this.value[1].split('月')[0];
    return `${year}.${month}`;
  }

  aboutToAppear(): void {
    if (this.monthDate) {
      let temp = this.monthDate.split('.');
      this.value[0] = temp[0] + '年';
      this.value[1] = temp[1] + '月';
    } else {
      const today = new Date();
      this.value[0] = `${today.getFullYear()}年`;
      this.value[1] = `0${today.getMonth() + 1}`.slice(-2) + '月';
    }
  }

  build() {
    Column() {
      this.pickerHeader()

      TextPicker({ range: this.pickerGroup, value: this.value })
        .onChange((value: string | string[]) => {
          this.value[0] = value[0];
          this.value[1] = value[1];
        })
        .disappearTextStyle({
          font: { size: 15, weight: FontWeight.Regular },
        })
        .textStyle({
          color: $r('sys.color.font_primary'),
          font: { size: 16, weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('sys.color.font_emphasize'),
          font: {
            size: 20,
            weight: FontWeight.Medium,
          },
        })
        .canLoop(false)
        .width('100%')
        .layoutWeight(1)
        .margin({ bottom: 16 })
    }
    .height('100%')
    .width('100%')
    .padding({ left: 16, right: 16 })
  }

  @Builder
  pickerHeader() {
    Row() {
      Button() {
        SymbolGlyph($r('sys.symbol.xmark'))
          .fontSize(18)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.cancel?.()
      })

      Text('选择日期')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.font_primary'))
        .margin({ left: 8 })

      Blank()

      Button() {
        SymbolGlyph($r('sys.symbol.checkmark'))
          .fontSize(18)
          .fontColor([$r('sys.color.icon_primary')])
      }
      .width(40)
      .height(40)
      .backgroundColor($r('sys.color.comp_background_tertiary'))
      .onClick(() => {
        this.confirm?.(this.selectedMonth)
      })
    }
    .width('100%')
    .height(56)
    .margin({ top: 8 })
  }
}

export function openMonthFilterSheet(monthDate: string = '', confirm: Function) {
  const param: MonthFilterParam = {
    monthDate,
    confirm: (date: string) => {
      confirm?.(date);
      PopViewUtils.closeSheet();
    },
    cancel: () => {
      PopViewUtils.closeSheet();
    }
  }
  PopViewUtils.showSheet(wrapBuilder(monthFilterSheetBuilder), {
    height: 300,
    preferType: SheetType.CENTER,
    showClose: false,
  }, param)
}