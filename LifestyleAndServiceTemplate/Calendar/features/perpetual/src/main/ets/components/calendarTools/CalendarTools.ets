import { getDataFromJSON } from 'base_apis';
import { CalendarTool, CalendarVM, TextStyleModifier } from 'common';
import { RouterModule } from 'router_module';

@ComponentV2
export struct CalendarTools {
  @Local calendarTool: CalendarTool[] = []
  vm: CalendarVM = CalendarVM.instance;

  aboutToAppear(): void {
    this.calendarTool = getDataFromJSON<CalendarTool>(this.getUIContext().getHostContext()!, 'Calendar_Tools.json');
  }

  build() {
    Column() {
      List({ space: 37 }) {
        ForEach(this.calendarTool, (item: CalendarTool) => {
          ListItem() {
            Column({ space: 5 }) {
              Image($r(item.icon)).width(48).height(48)
              Text(item.name)
                .attributeModifier(new TextStyleModifier('font_primary/Body_S/Regular'))
            }
            .onClick(() => {
              switch (item.id) {
                case 'query':
                  RouterModule.pushPathByName({ url: 'QueryJiDayTools' })
                  break
                case 'calculation':
                  RouterModule.pushPathByName({ url: 'DateCalculationTools' })
                  break
                case 'festival':
                  RouterModule.pushPathByName({ url: 'FestivalSolarTools' })
                  break
              }
            })
          }
        }, (item: CalendarTool) => item.id)
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ top: 12, bottom: 8 })
  }
}