import { carData , CarType, CarGroupType, ALPHABET_VALUE, HOT_CAR} from '../constants/car'
import { CommonConstants } from '@ohos_agcit/car_beauty_care_commonlib'
import { VehicleVM } from '../model/VehicleVM'

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
export function CarSelectViewBuilder() {
  CarSelectView()
}

@ComponentV2
struct CarSelectView {
  vehicleVM: VehicleVM = VehicleVM.instance;
  @Local egDivider: DividerTmp = new DividerTmp(1, 0, 0, '#ffe9f0f0')
  topRectHeight: number = 0;
  @Consumer('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local selectedIndex: number = 0
  private listScroller: Scroller = new Scroller();
  @Builder itemHead(text: string | Resource) {
    Text(text)
      .fontSize(12)
      .width(CommonConstants.FULL_WIDTH)
      .fontColor('#737373')
      .margin({
        bottom:8
      })
      .backgroundColor('#fff1f3f5')
      .padding(5)
  }

  aboutToAppear(): void {
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  setCurrentCity(car: CarType) {
    this.vehicleVM.addCar(car)
    const index = this.appPathStack.getIndexByName('garagePage');
    if (index.length < 1) {
      this.appPathStack.replacePathByName('garagePage', true)
    } else {
      this.appPathStack.pop()
    }

  }

  build() {
    NavDestination() {
      Stack({alignContent: Alignment.TopEnd}) {
        List({scroller: this.listScroller}) {
          ListItemGroup() {
            ListItem() {
              Column() {
                Text($r('app.string.hotBranding'))
                  .fontSize(14)
                  .fontColor('#444')
                  .margin({
                    bottom:8,
                    top:8,
                    left: 10
                  })
                Flex({wrap:FlexWrap.Wrap, justifyContent:FlexAlign.Start}) {
                  ForEach(HOT_CAR,(car:CarType) => {
                    Column() {
                      Image(car.logoUrl)
                        .width(24)
                        .height(24)
                        .margin({
                          bottom:4
                        })

                      Text(car.name)
                        .fontSize(12)
                        .fontColor('#666')
                        .textAlign(TextAlign.Center)
                    }
                    .width('20%')
                    .onClick(() => {
                      this.setCurrentCity(car)
                    })
                    .margin({
                      bottom:10
                    })
                  })
                }
                .margin({
                  left: 5
                })
                .width(CommonConstants.FULL_WIDTH)
              }
              .alignItems(HorizontalAlign.Start)
            }
            .width(CommonConstants.FULL_WIDTH)
            .margin({
              bottom:5,
              top:5
            })
          }
          .backgroundColor('#fff')
          .borderRadius(12)
          .margin({
            bottom:10
          })
          ForEach(carData, (ele:CarGroupType) => {
            ListItemGroup({header:this.itemHead(ele.type)}) {
              ForEach(ele.data, (car:CarType) => {
                ListItem() {
                  Row() {
                    Image(car.logoUrl)
                      .width(24)
                      .height(24)
                      .margin({
                        right:12
                      })
                    Text(car.name)
                      .fontSize(12)
                      .fontColor('#666')
                  }

                }
                .margin({
                  bottom:8,
                  top:8
                })
                .width(CommonConstants.FULL_WIDTH)
                .onClick(() => {
                  this.setCurrentCity(car)
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
            top:160,
            right:10
          })
      }
    }
    .title('车型选择')
    .margin({
      top: px2vp(this.topRectHeight)
    })
    .onBackPressed(() => {
      this.appPathStack.pop();
      return true;
    })
    .linearGradient({
      angle:150,
      colors:[['#D2E2F5', 0.0], [Color.White, 0.4]]
    })
  }
}