import { BaseNavTitle } from 'base_apis'
import dayjs from 'dayjs'
import { TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from '../../constants/Constants'
import { YiJiDayQuery } from './JiDayDetailCard'


@Builder
export function JiDayDetailBuilder() {
  JiDayDetail()
}

@ComponentV2
export struct JiDayDetail {
  @Local title: string = ' '
  @Local choose: string = ''
  @Local routerModule: NavPathStack = new NavPathStack()
  @Local selectColor: ResourceStr = '#c4272b'
  @Local selectedDate: Date = new Date()
  @Local titleColor: ResourceStr = '#ffffff'

  getNavigationParams() {
    let params =
      this.routerModule.getParamByName('JiDayDetail')[0] as Record<string, string | ResourceStr | Date>
    this.title = params.selectValue as string
    this.choose = params.choose as string
    this.selectColor = params.selectColor as ResourceStr
    this.selectedDate = params.selectedDate as Date
    this.titleColor = params.titleColor as ResourceStr
  }

  build() {
    NavDestination() {
      BaseNavTitle({
        title: this.title,
        titleColor: this.titleColor,
        currentTheme: this.selectColor,
        routerModule: this.routerModule,
      })
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          YiJiDayQuery({
            value: this.title,
            choose: this.choose,
            selectColor: this.selectColor,
            startDate: new Date(dayjs(this.selectedDate).format('YYYY-MM-DD')),
          })
        }
      }
      .layoutWeight(1)
    }
    .onReady((ctx) => {
      this.routerModule = ctx.pathStack
      this.getNavigationParams()
    })
    .hideTitleBar(true)
  }
}