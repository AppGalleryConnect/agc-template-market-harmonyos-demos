
export interface ExpressPickerParam {
  companyList: string[],
  currentCompany: string,
  confirm: (company: string) => void
  cancel: () => void
}

@Builder
export function expressPickerSheetBuilder(param: ExpressPickerParam) {
  ExpressPickerSheet({
    companyList: param.companyList,
    currentCompany: param.currentCompany,
    confirm: param.confirm,
    cancel: param.cancel
  })
}

@ComponentV2
struct ExpressPickerSheet {
  @Param companyList: string[] = [];
  @Param currentCompany: string = '';
  @Event confirm: (company: string) => void;
  @Event cancel: () => void;
  @Local selectIndex: number = 0

  aboutToAppear(): void {
    const index = this.companyList.findIndex((item) => item === this.currentCompany);
    this.selectIndex = index > -1 ? index : 0;
  }

  build() {
    Scroll() {
      Column() {
        TextPicker({ range: this.companyList, selected: $$this.selectIndex })
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
              const selectedCompany = this.companyList[this.selectIndex];
              this.confirm(selectedCompany);
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