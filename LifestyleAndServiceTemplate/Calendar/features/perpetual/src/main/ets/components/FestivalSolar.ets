import { calculateNextEvents, CalendarVM, FestivalList, TextStyleModifier } from 'common';

@ComponentV2
export struct FestivalSolar {
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local festivalList: FestivalList[] = []
  @Local vm: CalendarVM = CalendarVM.instance;

  @Monitor('vm.selectDate')
  onStrChange(monitor: IMonitor) {
    monitor.dirty.forEach((path: string) => {
      this.festivalList = calculateNextEvents(this.vm.selectDate.format('YYYY-MM-DD'))
    })
  }

  aboutToAppear(): void {
    this.festivalList = calculateNextEvents(this.vm.selectDate.format('YYYY-MM-DD'))
  }

  build() {
    Column({ space: 12 }) {
      Text('节日节气')
        .attributeModifier(new TextStyleModifier('font_primary/Subtitle_L/Bold'))

      List({ space: 12 }) {
        ForEach(this.festivalList, (item: FestivalList) => {
          ListItem() {
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems: ItemAlign.Center }) {
              Column({ space: 3 }) {
                Text(item.date.split('-')[2])
                  .attributeModifier(new TextStyleModifier('font_primary/Subtitle_L/Medium'))
                Text(`${item.date.split('-')[1]}月`)
                  .attributeModifier(new TextStyleModifier('font_primary/Body_M/Regular'))
              }

              Row() {
                Column({ space: 5 }) {
                  Text(item.name)
                    .attributeModifier(new TextStyleModifier('font_primary/Subtitle_S/Medium'))
                  Text(item.date)
                    .attributeModifier(new TextStyleModifier('font_secondary/Body_S/Regular'))
                }
                .alignItems(HorizontalAlign.Start)

                Row() {
                  Text(item.daysUntil.toString())
                    .attributeModifier(new TextStyleModifier('font_primary/Body_L/Bold'))
                  Text('天')
                    .attributeModifier(new TextStyleModifier('font_secondary/Body_M/Regular'))
                }
              }
              .padding({
                left: 12,
                right: 12,
                top: 10,
                bottom: 10,
              })
              .width('85%')
              .borderRadius(8)
              .backgroundColor('#FDF7EE')
              .justifyContent(FlexAlign.SpaceBetween)
              .onClick(() => {
                this.pageInfos.pushPathByName('FestivalDetails', item)
              })
            }
          }
        })
      }
      .scrollBar(BarState.Off)
    }
    .margin({ top: 12 })
    .padding(12)
    .backgroundColor($r('sys.color.background_primary'))
    .borderRadius(16)
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}