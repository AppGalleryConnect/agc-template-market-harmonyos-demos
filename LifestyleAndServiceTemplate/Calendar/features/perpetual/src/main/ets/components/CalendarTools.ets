import { CalendarTool, CalendarVM, getDataFromJSON, TextStyleModifier } from 'common';

@ComponentV2
export struct CalendarTools {
  @Local calendarTool: CalendarTool[] = []
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack();
  vm: CalendarVM = CalendarVM.instance;
  aboutToAppear(): void {
    this.calendarTool = getDataFromJSON<CalendarTool>('Calendar_Tools.json', this);
  }

  build() {
    Column({ space: 8 }) {
      Text('实用工具')
        .attributeModifier(new TextStyleModifier('font_primary/Subtitle_L/Bold'))
      List({ space: 37 }) {
        ForEach(this.calendarTool, (item: CalendarTool) => {
          ListItem() {
            Column({ space: 5 }) {
              Image($r(item.icon)).width(48).height(48)
              Text(item.name)
                .attributeModifier(new TextStyleModifier('font_primary/Body_S/Regular'))
            }
            .onClick(() => {
              switch (item.id){
                case 'query':
                  this.pageInfos.pushPathByName('QueryJiDay', null)
                break
                case 'calculation':
                  this.pageInfos.pushPathByName('DateCalculation', null)
                  break
                case 'festival':
                  this.pageInfos.pushPathByName('QueryJiDay', null)
                  break
              }
            })
          }
        })
      }
      .width('100%')
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
    }
    .alignItems(HorizontalAlign.Start)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .padding(12)
    .margin({ top: 12, left: 16, right: 16 })
  }
}