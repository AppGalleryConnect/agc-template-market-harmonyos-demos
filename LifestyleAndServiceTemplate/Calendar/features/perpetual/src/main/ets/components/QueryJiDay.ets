import { getDataFromJSON, JiDayList, NavigationTitle, TextStyleModifier, ToggleChoose, ToggleItem } from 'common'

@Builder
export function QueryJiDayBuilder() {
  QueryJiDay()
}

@ComponentV2
export struct QueryJiDay {
  @Local jiDayList: JiDayList[] = []
  @Local choose: string = 'yi'
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Local toggleList: ToggleItem [] = [
    {
      name: '宜',
      id: 'yi',
    },
    {
      name: '忌',
      id: 'ji',
    },
  ]

  aboutToAppear(): void {
    this.jiDayList = getDataFromJSON<JiDayList>('Jiri_Info.json', this);
  }

  @Builder
  jiDayContent() {
    Column() {
      ForEach(this.jiDayList, (item: JiDayList) => {
        Column() {
          Row({ space: 5 }) {
            Image($r(item.icon)).width(24).height(24)
            Text(item.name)
              .attributeModifier(new TextStyleModifier('#966426/Body_L/Medium'))
          }
          .margin({ top: 8, bottom: 12 })

          Grid() {
            ForEach(item.list, (value: string) => {
              GridItem() {
                Row() {
                  Text(value)
                    .attributeModifier(new TextStyleModifier('#966426/Body_M/Regular'))
                }
              }
              .padding({
                left: 24,
                right: 24,
                top: 5,
                bottom: 5,
              })
              .onClick(() => {
                this.pageInfos.pushPathByName('JiDayDetail', value)
              })
              .borderRadius(27)
              .backgroundColor('#F9F3E9')
            }, (value: string) => value)
          }
          .columnsTemplate('repeat(auto-fit, 70)')
          .columnsGap(10)
          .rowsGap(10)
        }
        .alignItems(HorizontalAlign.Start)
      }, (item: JiDayList) => item.name)
    }
    .padding({ left: 16, right: 16 })
  }

  build() {
    NavDestination() {
      NavigationTitle({
        title: '吉日查询',
      })
      List() {
        ListItem() {
          ToggleChoose({
            toggleList: this.toggleList,
          })
        }

        ListItem() {
          this.jiDayContent()
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
    }
    .hideTitleBar(true)
  }
}