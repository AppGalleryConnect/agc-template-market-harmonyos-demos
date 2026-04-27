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
]

@ComponentV2
export struct MonthPicker {
  @Param
  initMonth: string = ''
  @Local
  value: [string, string] = ['', '']
  @Event
  handleConfirm: (dateStr: string) => void
  @Event
  handleCancel: () => void

  @Computed
  get pickerGroup() {
    const curYear = new Date().getFullYear()
    const yearList: string[] = []
    for (let i = 0; i <= curYear - 1970; i++) {
      yearList.push(`${1970 + i}年`)
    }
    return [yearList, MONTH_LIST]
  }

  @Computed
  get selectedMonth() {
    const year = this.value[0].split('年')[0]
    const month = this.value[1].split('月')[0]
    return `${year}-${month}`
  }

  aboutToAppear(): void {
    if (this.initMonth) {
      const temp = this.initMonth.split('-')
      this.value[0] = temp[0] + '年'
      this.value[1] = temp[1] + '月'
    } else {
      const cur = new Date()
      const month = cur.getMonth() + 1
      this.value[0] = `${cur.getFullYear()}年`
      this.value[1] = `${month < 10 ? '0' : ''}${month}月`
    }
  }

  build() {
    Column() {
      TextPicker({ range: this.pickerGroup, value: this.value })
        .onChange((value: string | string[]) => {
          this.value[0] = (value as string[])[0]
          this.value[1] = (value as string[])[1]
        })
        .disappearTextStyle({
          font: { size: $r('app.float.font_size_14'), weight: FontWeight.Regular },
        })
        .textStyle({
          color: $r('app.color.font_color_level1'),
          font: { size: $r('app.float.font_size_16'), weight: FontWeight.Regular },
        })
        .selectedTextStyle({
          color: $r('app.color.theme_color'),
          font: {
            size: $r('app.float.font_size_20'),
            weight: FontWeight.Medium,
          },
        })
        .canLoop(false)
        .width('100%')
      Blank()
      Row() {
        Text('取消')
          .onClick(() => {
            this.handleCancel?.()
          })
          .fontColor($r('app.color.font_color_level2'))
          .textButtonStyle()

        Blank().width(16)

        Text('确定')
          .onClick(() => {
            this.handleConfirm?.(this.selectedMonth)
          })
          .fontColor($r('app.color.theme_color'))
          .textButtonStyle()
      }
      .width($r('app.string.size_percent_full'))
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ bottom: $r('app.float.space_l') })
    }
    .height($r('app.string.size_percent_full'))
    .width($r('app.string.size_percent_full'))
    .padding($r('app.float.space_l'))
  }
}

@Extend(Text)
function textButtonStyle() {
  .textAlign(TextAlign.Center)
  .width('40%')
  .constraintSize({ maxWidth: 180 })
  .fontWeight(FontWeight.Medium)
}
