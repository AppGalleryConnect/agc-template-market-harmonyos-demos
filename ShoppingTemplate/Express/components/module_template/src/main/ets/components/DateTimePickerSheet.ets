import { TIME_LIST } from 'lib_foundation';


export interface DateTimePickerParam {
  currentTime: string;
  confirm: (time: string) => void;
  cancel: () => void;
}

@Builder
export function dateTimePickerSheetBuilder(param: DateTimePickerParam) {
  DateTimePickerSheet({
    currentTime: param.currentTime,
    confirm: param.confirm,
    cancel: param.cancel,
  })
}

@ComponentV2
struct DateTimePickerSheet {
  @Param currentTime: string = '';
  @Event confirm: (time: string) => void;
  @Event cancel: () => void;
  @Local selectedTimeIndex: number = 0;

  aboutToAppear(): void {
    const index = TIME_LIST.findIndex((item) => item === this.currentTime);
    this.selectedTimeIndex = index > -1 ? index : 0;
  }

  build() {
    Scroll() {
      Column() {
        TextPicker({ range: TIME_LIST, selected: $$this.selectedTimeIndex })
          .width(200)
          .disappearTextStyle({ color: Color.Black, font: { size: 14, weight: FontWeight.Regular } })
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
              this.cancel();
            })

          Button('确认')
            .fontColor($r('sys.color.font_on_primary'))
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .flexGrow(1)
            .onClick(() => {
              const selectedTime = TIME_LIST[this.selectedTimeIndex];
              this.confirm(selectedTime);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: 28 })
      }
      .width('100%')
      .padding({ bottom: 16 })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
  }
}