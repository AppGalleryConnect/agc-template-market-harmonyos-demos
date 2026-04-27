import { HomeModel } from '../viewmodel/HomeModel';
import { TabSingleItem } from '../viewmodel/TabSingleItem';
import { BarVM } from 'common';

@Builder
export function HomePageBuilder() {
  HomePage()
}

@ComponentV2
export struct HomePage {
  vm: HomeModel = HomeModel.instance;

  @Builder
  tabBuilder(tabItem: TabSingleItem) {
    Column() {
      Image(this.vm.curIndex === tabItem.index ? tabItem.iconActive : tabItem.icon)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(tabItem.label)
        .margin({ top: 4 })
        .fontSize(10)
        .fontWeight(500)
        .fontColor(this.vm.curIndex === tabItem.index ? tabItem.fontColorActive : tabItem.fontColor)
    }
    .justifyContent(FlexAlign.Center)
    .height(52)
    .width('100%')
  }

  // 页面内容渲染
  @Builder
  render() {
    Tabs({
      barPosition: BarPosition.End,
      index: $$this.vm.curIndex,
      controller: this.vm.controller
    }) {
      ForEach(this.vm.tabList, (item: TabSingleItem) => {
        TabContent() {
          item.component.builder('');
        }
        .tabBar(this.tabBuilder(item))
      }, (item: TabSingleItem, index) => JSON.stringify(item) + '_' + index)
    }
    .clip(true)
    .width('100%')
    .backgroundColor('#F3F4F5')
    .barHeight(50)
    .barMode(BarMode.Fixed)
    .padding({
      bottom: BarVM.instance.aiBarH
    })
    .animationDuration(0)
    .scrollable(false)
  }

  build() {
    NavDestination() {
      this.render();
    }
    .backgroundColor('#F3F4F5')
    .hideTitleBar(true)
  }
}
