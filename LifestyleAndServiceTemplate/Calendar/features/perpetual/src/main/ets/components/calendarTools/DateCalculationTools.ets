import { PersistenceV2 } from '@kit.ArkUI'
import { CalendarVM, NavigationTitle, TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET, ThemeModel } from 'common'
import { DateToolsCalculate } from 'date_calculation'

@Builder
export function DateCalculationToolsBuilder() {
  DateCalculationTools()
}

@ComponentV2
export struct DateCalculationTools {
  vm: CalendarVM = CalendarVM.instance;
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;

  build() {
    NavDestination() {
      NavigationTitle({
        title: '日期计算',
      })
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          DateToolsCalculate({
            startDate: new Date(this.vm.selectDate.format('YYYY-MM-DD')),
            buttonColor: this.theme.themeState.current,
            textColor: this.theme.themeState.titleColor,
            selectColor:this.theme.themeState.calendarColor,
          })
        }
      }
    }
    .hideTitleBar(true)
  }
}