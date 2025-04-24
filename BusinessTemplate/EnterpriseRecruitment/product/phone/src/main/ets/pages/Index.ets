import { Information } from './Information';
import { Job } from './Job';
import { Mine } from './Mine';
import { AvoidArea } from '@ohos_agcit/common_component';
import { AppStorageV2 } from '@kit.ArkUI';

//  资讯，主页面
@Entry
@ComponentV2
struct Index {
  @Local avoidArea: AvoidArea = AppStorageV2.connect(AvoidArea, () => new AvoidArea(0, 0))!;
  @Local currentIndex: number = 0
  private controller: TabsController = new TabsController()
  private tabsController: TabsController = new TabsController()

  @Builder
  tabBuilder(title: Resource, index: number, selectedImg: Resource, normalImg: Resource) {
    Column() {
      Image(this.currentIndex === index ? selectedImg : normalImg)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(title)
        .margin({ top: 4 })
        .fontSize($r('app.float.font_size_10'))
        .fontColor(this.currentIndex === index ? '#3388ff' : '#E6000000')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height(52)
    .padding({ bottom: px2vp(this.avoidArea.bottomRectHeight) })
    .onClick(() => {
      this.currentIndex = index;
      this.tabsController.changeIndex(this.currentIndex);
    })
  }

  build() {
    Column() {
      Tabs({ barPosition: BarPosition.End, controller: this.controller, index: this.currentIndex }) {
        TabContent() {
          Information()
        }
        .tabBar(this.tabBuilder($r('app.string.app_information'), 0, $r('app.media.active_home'), $r('app.media.home')))

        TabContent() {
          // Job()
          Job()
        }
        .tabBar(this.tabBuilder($r('app.string.app_job'), 1, $r('app.media.active_job'), $r('app.media.job')))

        TabContent() {
          Mine()
        }
        .tabBar(this.tabBuilder($r('app.string.app_mine'), 2, $r('app.media.mine_active'), $r('app.media.mine')))
      }
      .vertical(false)
      .barMode(BarMode.Fixed)
      .barWidth(360)
      .barHeight(80)
      .animationDuration(0)
      .onChange((index: number) => {
        this.currentIndex = index
      })
      .backgroundColor('#F1F3F5')
      .scrollable(false)
      .onContentWillChange((currentIndex, comingIndex) => {
        return true
      })
    }
    .width('100%')
    .height('100%')
  }
}