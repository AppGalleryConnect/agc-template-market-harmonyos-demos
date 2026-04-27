import { DateIndex, DateTimePickerOption } from '../model/Time'
import { formatFullDate } from '../utils/Base'
import { DATE_TIME_RANGE } from '../utils/DateTimeRange'
import { isVisibility } from '../utils/Time'
import { RetirePageVM } from '../viewmodel/RetirePageVM'

@ComponentV2
export struct RetirementAgePage {
  vm: RetirePageVM = RetirePageVM.instance

  aboutToAppear(): void {
    this.vm.init()
    this.vm.onChangedOption()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Scroll() {
            Column() {
              Column() {
                Row() {
                  Column() {
                    Text() {
                      Span('退休年龄：')
                      Span(this.vm.retirementAge ? this.vm.retirementAgeText : '--')
                    }
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                    .margin({ bottom: 2 })

                    Text() {
                      Span('退休日期：')
                      Span(this.vm.retirementDate ? formatFullDate(this.vm.retirementDate) : '---- -- --')
                    }
                    .fontSize($r('sys.float.Body_L'))
                    .fontWeight(FontWeight.Medium)
                    .fontColor(Color.White)
                    .margin({ bottom: 24 })

                    Text(`距离退休还有：`)
                      .fontSize($r('sys.float.Body_L'))
                      .fontWeight(FontWeight.Medium)
                      .fontColor(Color.White)
                      .margin({ bottom: 4 })
                    Text(this.vm.isCalc ? this.vm.daysRemaining ? `${this.vm.daysRemaining}天` : '已退休' : '-天')
                      .fontSize($r('sys.float.Title_M'))
                      .fontWeight(FontWeight.Bold)
                      .fontColor(Color.White)
                  }
                  .alignItems(HorizontalAlign.Start)

                  Image($r('app.media.image'))
                    .width(118)
                    .height(141)
                }
                .width('100%')
                .padding({
                  top: 16,
                  bottom: 16,
                  left: 24,
                  right: 8,
                })
                .borderRadius(20)
                .backgroundColor($r('sys.color.background_emphasize'))
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 32 })

                Row() {
                  Text('选择人员类型：')
                    .fontSize($r('sys.float.Subtitle_L'))
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#191919')

                  Select([{ value: '男职工' }, { value: '女职工' }])
                    .value(this.vm.text)
                    .optionWidth(224)
                    .onSelect((index, text) => {
                      this.vm.text = text
                    })
                }
                .width('100%')
                .height(40)
                .justifyContent(FlexAlign.SpaceBetween)
                .margin({ bottom: 16 })

                Row() {
                  Text('出生年月日：')
                    .fontSize($r('sys.float.Subtitle_L'))
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#191919')
                }
                .width('100%')
                .margin({ bottom: 8 })

                Flex() {
                  Row() {
                    customPicker({
                      range: this.vm.yearRange,
                      selected: this.vm.currentYear - DATE_TIME_RANGE.getStartYear(),
                      dateIndex: DateIndex.YEAR,
                      callback: this.vm.updateSelectedDate,
                      option: this.vm.option,
                    })
                  }.flexGrow(2)

                  Row() {
                    customPicker({
                      range: this.vm.monthRange,
                      selected: this.vm.monthIndex,
                      dateIndex: DateIndex.MONTH,
                      callback: this.vm.updateSelectedDate,
                      option: this.vm.option,
                    })
                  }.flexGrow(1)

                  Row() {
                    customPicker({
                      range: this.vm.dayRange,
                      selected: this.vm.dayIndex,
                      dateIndex: DateIndex.DAY,
                      callback: this.vm.updateSelectedDate,
                      option: this.vm.option,
                    })
                  }.flexGrow(1)
                }
                .width('100%')
                .height(248)
                .backgroundColor(Color.White)
                .borderRadius(20)
                .padding(24)
                .margin({ bottom: 12 })

                Row() {
                  Text('男职工和原法定退休年龄为五十五周岁的女职工，法定退休年龄每四个月延迟一个月，分别逐步延迟至六十三周岁和五十八周岁。')
                    .fontSize($r('sys.float.Body_M'))
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.font_secondary'))
                }
                .width('100%')
              }
              .padding({ left: 16, right: 16 })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
        .height('calc(100% - 56vp)')

        Row() {
          Row() {
            Button() {
              Row() {
                SymbolGlyph($r('sys.symbol.calculator'))
                  .fontSize(24)
                  .fontColor([$r('sys.color.font_on_primary')])
                  .margin({ right: 8 })
                Text('计算')
                  .fontSize($r('sys.float.Body_L'))
                  .fontColor($r('sys.color.font_on_primary'))
                  .fontWeight(FontWeight.Medium)
              }.alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .height(40)
            .backgroundColor($r('sys.color.comp_background_emphasize'))
            .fontColor($r('sys.color.font_primary'))
            .onClick(() => {
              this.vm.calculateRetirement()
            })
          }
          .width('100%')
          .padding({ left: 16, right: 16 })
        }
        .width('100%')
        .position({ bottom: 0 })
      }
      .height('100%')
    }
    .title('退休年龄计算')
    .backgroundColor('#F1F3F5')
  }
}

@Observed
class PickerClass {
  @Track range: string[] = []
  @Track selected: number = 0
  @Track dateIndex: DateIndex = DateIndex.YEAR
  @Track option?: DateTimePickerOption
  callback = (dateIndex: DateIndex, value: string | string[], index: number | number[]) => {
  }
}

@Builder
function customPicker(picker: PickerClass) {
  TextPicker({ range: picker.range, selected: picker.selected })
    .width('100%')
    .height(200)
    .canLoop(true)
    .visibility(isVisibility(picker.dateIndex, picker.option?.timeFormat))
    .onChange((value: string | string[], index: number | number[]) => {
      picker.callback(picker.dateIndex, value, index)
    })
}

@Builder
export function RetirementAgePageBuilder() {
  RetirementAgePage()
}