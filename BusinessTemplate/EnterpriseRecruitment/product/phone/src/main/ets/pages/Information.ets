import { AvoidArea, SwiperComponent, TitleBar } from '@ohos_agcit/common_component';
import { AboutUs } from '../information/AboutUs';
import { Introductions } from '../information/Introductions';
import { AppStorageV2 } from '@kit.ArkUI';

@Entry
@ComponentV2
export struct Information {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;

  @Builder
  tabBuilder(tabName: string | Resource, tabIndex: number) {
    Row() {
      Text(tabName)
        .fontSize($r('app.float.font_size_15'))
        .fontColor(tabIndex === this.currentIndex ? Color.White : '#E6000000')
        .id(tabIndex.toString())
    }
    .justifyContent(FlexAlign.Center)
    .backgroundColor(tabIndex === this.currentIndex ? $r('app.color.common_blue') :
    $r('app.color.button_gray'))
    .borderRadius(21)
    .width(150)
    .height(40)
    .margin({ left: 2, right: 2, bottom: 30 })
    .onClick(() => {
      this.controller.changeIndex(tabIndex);
      this.listScroller.scrollToIndex(tabIndex, true, ScrollAlign.CENTER);
    })
  }

  @Local currentIndex: number = 0
  private controller: TabsController = new TabsController();
  private listScroller: Scroller = new Scroller();

  build() {
    Column() {
      Column() {
        TitleBar({ text: $r('app.string.information') })
          .width('100%')
          .height('75%')
      }
      .padding({ top: '2%', left: '6%', right: '6%' })
      .height('8%')
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Scroll() {
        Column() {
          Row() {
            SwiperComponent()
          }
          .padding('2%')
          .margin({ bottom: 10 })
          .height(200)
          .width('100%')

          Tabs({ barPosition: BarPosition.End, controller: this.controller, index: this.currentIndex }) {
            TabContent() {
              AboutUs()
            }
            .tabBar(this.tabBuilder($r('app.string.information_aboutUs'), 0))

            TabContent() {
              Introductions()
            }
            .tabBar(this.tabBuilder($r('app.string.information_hobbies'), 1))
          }
          .scrollable(false)
          .vertical(false)
          .barMode(BarMode.Scrollable)
          .barWidth(360)
          .barHeight(60)
          .barPosition(BarPosition.Start)
          .animationDuration(0)
          .onChange((index: number) => {
            this.currentIndex = index
          })
          // .onContentWillChange((currentIndex, comingIndex) => {
          //   return true
          // })
          .height('auto')
        }
        .justifyContent(FlexAlign.Start)
      }
      .scrollBar(BarState.Off)
      .height('92%')
      .width('100%')
      .padding({
        left: '6%',
        right: '6%'
      })
    }
    .backgroundColor($r('app.color.common_background'))
    .padding({
      top: px2vp(this.avoidArea.topRectHeight) + 10,
    })
    .width('100%')
    .height('100%')
  }
}
