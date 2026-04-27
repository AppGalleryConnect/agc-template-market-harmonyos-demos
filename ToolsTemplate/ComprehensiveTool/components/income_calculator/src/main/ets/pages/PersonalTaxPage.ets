import { PersonalTaxPageVM } from '../viewmodel/PersonalTaxPageVM';

// 跳转页面入口函数
@Builder
export function PersonalTaxPageBuilder() {
  PersonalTaxPage()
}

@ComponentV2
export struct PersonalTaxPage {
  vm: PersonalTaxPageVM = PersonalTaxPageVM.instance

  removeTrailingZeros(num: number, fixed: number): string {
    let numStr = num.toFixed(fixed);
    if (numStr.includes('.')) {
      numStr = numStr.replace(/0+$/, '');
      if (numStr.endsWith('.')) {
        numStr = numStr.slice(0, -1);
      }
    }
    return numStr;
  }

  aboutToAppear(): void {
    this.vm.init()
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Scroll() {
            Column() {
              Row() {
                Text($r('app.string.calculation_result'))
                  .fontSize($r('sys.float.Title_S'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.font_primary'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ top: 14, bottom: 16 })

              List() {
                this.rowBuilder('税前收入', this.vm.tax?.totalIncome ?? 0, '元')
                this.rowBuilder('应纳税所得额',
                  this.vm.tax?.taxableIncome ? Number(this.vm.tax.taxableIncome.toFixed(2)) : 0, '元')
                this.rowBuilder('适用税率', this.vm.tax?.taxRate ?? 0, '%')
                this.rowBuilder('速算扣除数', this.vm.tax?.quickDeduction ?? 0, '元')
                this.rowBuilder('应纳税额', this.vm.tax?.tax ?? 0, '元', $r('sys.color.multi_color_08'))
                this.rowBuilder('税后收入', this.vm.tax?.afterTaxIncome ?? 0, '元')

                ListItem() {
                  Divider().color($r('sys.color.comp_divider')).width(1)
                }
                .width('100%')
                .padding({ bottom: 17 })
              }
              .divider(this.vm.egDivider)
              .alignListItem(ListItemAlign.Center)
              .backgroundColor($r('app.color.list_background'))
              .borderRadius(16)
              .padding({ left: 12, right: 12 })
              .margin({ bottom: 12 })

              Text($r('app.string.calculation_formula'))
                .fontSize($r('sys.float.Subtitle_M'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('sys.color.font_primary'))
                .textAlign(TextAlign.Start)
                .width('100%')

              Text(this.vm.calculationFormula)
                .width('100%')
                .fontSize($r('sys.float.Body_S'))
                .fontWeight(FontWeight.Regular)
                .fontColor($r('sys.color.font_primary'))
                .padding({ top: 16, bottom: 16 })
            }
          }
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
        }
        .layoutWeight(1)
        .padding({ left: 16, right: 16 })
      }
      .width('100%')
      .height('100%')
      .backgroundColor($r('app.color.page_background'))
    }
    .title('个税计算器')
  }

  @Builder
  rowBuilder(title: string, value: number, unit: string, color?: ResourceColor) {
    ListItem() {
      Row() {
        Text(title)
          .fontSize($r('sys.float.Subtitle_M'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.font_primary'))
        Row() {
          Text() {
            Span(`${this.removeTrailingZeros(value, 2)} `)
              .fontColor(color ? color : $r('sys.color.font_primary'))
            Span(unit)
              .fontColor($r('sys.color.font_primary'))
          }
          .fontSize($r('sys.float.Body_M'))
          .fontWeight(FontWeight.Medium)
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height(48)
  }
}