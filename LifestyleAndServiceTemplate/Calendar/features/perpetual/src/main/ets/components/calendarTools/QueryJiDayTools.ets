import { PersistenceV2 } from '@kit.ArkUI';
import { CalendarVM, ThemeModel } from 'common';
import { RouterModule } from 'router_module'
import { YiJiQuery } from 'yiji_query'

@Builder
export function QueryJiDayToolsBuilder() {
  QueryJiDayTools()
}

@ComponentV2
export struct QueryJiDayTools {
  @Local theme: ThemeModel = PersistenceV2.connect(ThemeModel, () => new ThemeModel())!;
  vm: CalendarVM = CalendarVM.instance;
  build() {
    Column(){
      YiJiQuery({
        routerModule:RouterModule.getStack(),
        selectColor:this.theme.themeState.calendarColor,
        titleColor:this.theme.themeState.titleColor,
        selectedDate:new Date(this.vm.selectDate.format('YYYY-MM-DD'))
      })
    }
  }
}