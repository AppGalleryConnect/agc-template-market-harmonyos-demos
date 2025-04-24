import { CITY_DATA, Cities, ALPHABET_VALUE, HOT_CITY, CityCallBack  } from '../model/CityData'

class DividerTmp {
  strokeWidth: Length = 1
  startMargin: Length = 60
  endMargin: Length = 10
  color: ResourceColor = '#ffe9f0f0'

  constructor(strokeWidth: Length, startMargin: Length, endMargin: Length, color: ResourceColor) {
    this.strokeWidth = strokeWidth
    this.startMargin = startMargin
    this.endMargin = endMargin
    this.color = color
  }
}

@Builder
export function CitySelectViewBuilder() {
  CitySelectView()
}

@ComponentV2
export struct CitySelectView {
  @Local locationName: string | Resource = '';
  @Local egDivider: DividerTmp = new DividerTmp(1, 0, 0, '#ffe9f0f0')
  topRectHeight: number = 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local selectedIndex: number = 0
  private listScroller: Scroller = new Scroller();
  updataLocationName?: (cityName:string) => void;
  getLocationName?:() => string | Resource;
  @Builder itemHead(text: string | Resource) {
    Text(text)
      .fontSize(12)
      .width('100%')
      .fontColor('#737373')
      .margin({
        bottom:8
      })
      .backgroundColor('#fff1f3f5')
      .padding(5)
  }

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
    this.appPathStack.getParamByName('updataLocationName')
    let params:CityCallBack = this.appPathStack.getParamByIndex(this.appPathStack.size() - 1) as CityCallBack;
    this.updataLocationName = params.updateLocationName;
    this.getLocationName = params.getLocationName;
    this.locationName = this.getLocationName();
  }

  setCurrentCity(cityName: string) {
    if (this.updataLocationName) {
      this.updataLocationName(cityName);
    }
    this.appPathStack.pop()
  }

  build() {
    NavDestination() {
      Stack({alignContent: Alignment.TopEnd}) {
        List({scroller: this.listScroller}) {
          ListItemGroup({header:this.itemHead($r('app.string.current_city'))}) {
            ListItem() {
              Text(this.locationName)
            }
            .margin({
              bottom:5,
              top:5
            })
          }
          .divider(this.egDivider)

          ListItemGroup({header:this.itemHead($r('app.string.hot_city'))}) {
            ListItem() {
              Flex({wrap:FlexWrap.Wrap, justifyContent:FlexAlign.Start}) {
                ForEach(HOT_CITY,(city:string) => {
                  Text(city)
                    .width(60)
                    .padding({
                      top:3,
                      bottom:3,
                      left:5,
                      right: 5
                    })
                    .margin({
                      right:5,
                      bottom:5
                    })
                    .fontSize(14)
                    .backgroundColor(Color.White)
                    .textAlign(TextAlign.Center)
                    .onClick(() => {
                      this.setCurrentCity(city)
                    })
                })
              }
              .margin({
                left: 5
              })
              .width('100%')
            }
            .width('100%')
            .margin({
              bottom:5,
              top:5
            })
          }
          .backgroundColor('#fff1f3f5')

          ForEach(CITY_DATA, (ele:Cities) => {
            ListItemGroup({header:this.itemHead(ele.type)}) {
              ForEach(ele.cities, (city:string) => {
                ListItem() {
                  Text(city)
                    .fontSize(12)
                    .fontColor('#666')
                }
                .margin({
                  bottom:6,
                  top:6
                })
                .width('100%')
                .onClick(() => {
                  this.setCurrentCity(city)
                })
                .align(Alignment.Start)
              })
            }
            .divider(this.egDivider)
          })
        }
        .padding({
          left:10,
          right:10
        })
        .sticky(StickyStyle.Header)
        .onScrollIndex((firstIndex: number) => {
          this.selectedIndex = firstIndex;
        })

        AlphabetIndexer({ arrayValue: ALPHABET_VALUE, selected: 0 })
          .selected(this.selectedIndex)
          .onSelect((index:number) => {
            this.selectedIndex = index;
            this.listScroller.scrollToIndex(index)
            console.log('[alphabet]',JSON.stringify(index))
          })
          .align(Alignment.End)
          .margin({
            top:20,
            right:10
          })
      }
    }
    .title('城市选择')
    .margin({
      top: px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle:135,
      colors:[['#D2E2F5', 0.0], [Color.White, 0.4]]
    })
  }
}
