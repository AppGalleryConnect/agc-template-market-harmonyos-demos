import { CalendarVM, NavigationTitle, TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET } from 'common';
import { AlmanacVernacular } from './almanacVernacular/AlmanacVernacular';
import { YiJiSetDate } from './almanacVernacular/Model';


@Builder
export function VernacularBuilder() {
  Vernacular()
}

@ComponentV2
export struct Vernacular {
  vm: CalendarVM = CalendarVM.instance
  @Local yiMockData: YiJiSetDate[] = []
  @Local jiMockData: YiJiSetDate[] = []

  setMockData(date: string[]) {
    let newData = date.map(item => {
      return new YiJiSetDate(item)
    })
    return newData
  }

  aboutToAppear(): void {
    /*
     * 这里mock宜忌相关的白话文，实际开发请填充业务数据
     * */
    this.yiMockData = this.setMockData(this.vm.todayYiJi?.yi as string[])
    this.jiMockData = this.setMockData(this.vm.todayYiJi?.ji as string[])
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: '黄历现代文',
      })
      GridRow(TABLET_GRID) {
        GridCol({
          span: TABLE_COL,
          offset: TABLE_COL_OFFSET,
        }) {
          AlmanacVernacular({
            selectTime: this.vm.selectDate.format('YYYY-MM-DD'),
            yiToday: this.yiMockData,
            jiToday: this.jiMockData,
            bgColor: '#FDF7EE',
          })
            .padding({ left: 16, right: 16 })
        }
      }
    }
    .backgroundColor('#FDF7EE')
    .hideTitleBar(true)
  }
}