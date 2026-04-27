import { BaseNavTitle, BaseSliderSwitch, BaseTextStyleModifier, getDataFromJSON, ToggleItem } from 'base_apis'
import { TABLET_GRID, TABLE_COL, TABLE_COL_OFFSET, YI_JI_COL, YI_JI_OPTIONS } from '../constants/Constants'
import { JiDayList, LuckyDays } from '../model/Model'
import { EventDispatcher } from '../utils/EventDispatcher'

@ComponentV2
export struct YiJiQuery {
  @Local jiDayList: JiDayList[] = []
  @Local choose: string = 'yi'
  @Local currentChoose: string = 'yi'
  @Param routerModule: NavPathStack = new NavPathStack()
  @Param selectColor: ResourceStr = '#c4272b'
  @Param titleColor: ResourceStr = '#ffffff'
  @Param selectedDate: Date = new Date()
  /**
   * 卡片点击事件
   */
  @Event onLunarInfoCardClick: (lunarInfo: LuckyDays) => void = () => {
  }
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
    EventDispatcher.onCellClick = (lunarInfo: LuckyDays) => {
      this.lunarInfoCardClick(lunarInfo)
    }
    this.jiDayList = getDataFromJSON<JiDayList>(this.getUIContext().getHostContext()!, 'Jiri_Info.json');
  }

  lunarInfoCardClick(lunarInfo: LuckyDays) {
    this.onLunarInfoCardClick(lunarInfo)
  }

  @Builder
  jiDayContent() {
    Column() {
      ForEach(this.jiDayList, (item: JiDayList) => {
        Column() {
          Row({ space: 5 }) {
            Image($r(item.icon)).width(24).height(24)
            Text(item.name)
              .attributeModifier(new BaseTextStyleModifier('#966426/Body_L/Medium'))
          }
          .margin({ top: 8, bottom: 12 })

          GridRow(YI_JI_OPTIONS) {
            ForEach(item.list, (value: string) => {
              GridCol({
                span: YI_JI_COL,
              }) {
                Row() {
                  Text(value)
                    .attributeModifier(new BaseTextStyleModifier('#966426/Body_M/Regular'))
                }
                .padding({ top: 6, bottom: 6 })
              }
              .onClick(() => {
                const navigationParams: Record<string, string | ResourceStr | Date> = {
                  'choose': this.currentChoose,
                  'selectValue': value,
                  'selectColor': this.selectColor,
                  'titleColor': this.titleColor,
                  'selectedDate': this.selectedDate,
                }
                this.routerModule.pushPathByName('JiDayDetail', navigationParams)
              })
              .borderRadius(27)
              .backgroundColor('#F9F3E9')
            }, (value: string) => value)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }, (item: JiDayList) => item.name)
    }
    .padding({ left: 16, right: 16 })
  }

  build() {
    NavDestination() {
      BaseNavTitle({
        title: '吉日查询',
        titleColor: this.titleColor,
        currentTheme: this.selectColor,
        routerModule: this.routerModule,
      })
      List() {
        ListItem() {
          BaseSliderSwitch({
            toggleList: this.toggleList,
            onChooseChange: (index: number) => {
              this.currentChoose = this.toggleList[index].id
            },
          })
        }
        .padding({ left: 16, right: 16 })
        .margin({ top: 18, bottom: 8 })

        ListItem() {
          GridRow(TABLET_GRID) {
            GridCol({
              span: TABLE_COL,
              offset: TABLE_COL_OFFSET,
            }) {
              this.jiDayContent()
            }
          }
        }
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .padding({ bottom: 16 })
    }
    .hideTitleBar(true)
  }
}