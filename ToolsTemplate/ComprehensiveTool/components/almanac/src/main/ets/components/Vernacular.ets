import { YiJiSetDate } from '../model/Index';
import CalendarVM from '../viewmodel/CalendarVM';
import { AlmanacVernacular } from './AlmanacVernacular';

@Builder
export function VernacularBuilder() {
  Vernacular();
}

@ComponentV2
export struct Vernacular {
  vm: CalendarVM = CalendarVM.instance;
  @Local yiMockData: YiJiSetDate[] = [];
  @Local jiMockData: YiJiSetDate[] = [];

  setMockData(date: string[]) {
    let newData = date.map(item => {
      return new YiJiSetDate(item);
    });
    return newData;
  }

  aboutToAppear(): void {
    /*
     * 这里mock宜忌相关的白话文，实际开发请填充业务数据
     * */
    this.yiMockData = this.setMockData(this.vm.todayYiJi?.yi as string[]);
    this.jiMockData = this.setMockData(this.vm.todayYiJi?.ji as string[]);
  }

  build() {
    NavDestination() {
      AlmanacVernacular({
        selectTime: this.vm.selectDate.format('YYYY-MM-DD'),
        yiToday: this.yiMockData,
        jiToday: this.jiMockData,
        bgColor: '#FDF7EE',
      })
        .padding({ left: 16, right: 16 });
    }
    .backgroundColor('#FDF7EE')
    .title('黄历现代文').expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}