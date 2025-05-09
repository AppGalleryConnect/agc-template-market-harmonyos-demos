import { Constants, WindowModel } from 'common';
import { TabBarData, TabBarType, TABS_INFO } from 'common/src/main/ets/models/TabBarModel';
import { AppStorageV2 } from '@kit.ArkUI';

@ComponentV2
export struct CustomTabBar {
  @Consumer('currentIndex') currentIndex: TabBarType = TabBarType.HOME_PAGE;
  @Local windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!

  onChange(index: TabBarType): void {
    this.currentIndex = index;
  }

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(TABS_INFO, (value: TabBarData) => {
        TabItem({
          selectedIndex: this.currentIndex,
          index: value.id,
          onChange: (index: number) => this.onChange(index),
        })
      }, (value: TabBarData) => value.id.toString())
    }
    .backgroundColor($r('sys.color.comp_background_list_card'))
    .shadow({
      radius: 30,
      color: '#33000000',
      offsetX: 0,
      offsetY: 10,
    })
    .padding({
      top: 8,
      left: 28,
      right: 28,
      bottom: this.windowModel.getWindowBottomHeight(),
    })
    .clip(false)
    .width(Constants.FULL_SIZE)
  }
}

@ComponentV2
struct TabItem {
  @Param @Require selectedIndex: number;
  @Param @Require index: number
  @Event onChange: (index: number) => void = () => {
  };

  build() {
    Column() {
      Image(this.selectedIndex === this.index ? TABS_INFO[this.index].activeIcon : TABS_INFO[this.index].defaultIcon)
        .width(24).height(24)
      Text(TABS_INFO[this.index].title)
        .fontSize(10)
        .lineHeight(14)
        .fontColor(this.index === this.selectedIndex ? ($r('app.color.tab_color_check')) :
        $r('app.color.tab_color_default'))
        .margin({ top: 4 })
    }.width(71)
    .onClick(() => this.onChange(this.index))
  }
}