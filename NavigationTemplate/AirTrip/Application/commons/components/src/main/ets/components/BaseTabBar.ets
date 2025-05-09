import { BaseTabBarItem } from '../types';

@ComponentV2
export struct BaseTabBar {
  @Param tabBarList: BaseTabBarItem[] = []
  @Event $currentIndex: (idx: number) => void = (idx: number) => {};
  @Param currentIndex: number = 0

  @Builder
  TabBarView(data: BaseTabBarItem, index: number) {
    Column() {
      Text(data.text)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentIndex === index ? '#466DFA' : '#99000000')
        .padding({ bottom: 6 })

      Row(){}.width(20).height(2).backgroundColor(this.currentIndex === index ? '#466DFA' : Color.Transparent)
    }
    .width('50%')
    .padding({ top: 14, bottom: 10 })
    .onClick(() => {
      this.$currentIndex(index)
    })
  }

  build() {
    Row() {
      ForEach(this.tabBarList, (item: BaseTabBarItem, index: number) => {
        this.TabBarView(item, index)
      })
    }
    .justifyContent(FlexAlign.SpaceBetween)
  }
}