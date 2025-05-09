import { Constants } from 'constant';
import { TabBarData, TabBarType, tabsInfo } from '../model/TabBarModel';

@Component
export struct CustomTabBar {
  @Link homeTabIndex: TabBarType;

  onChange(index: TabBarType): void {
    this.homeTabIndex = index;
  }

  build() {
    Flex({
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceAround
    }) {
      ForEach(tabsInfo, (item: TabBarData) => {
        TabItem({
          index: item.id,
          selectedIndex: this.homeTabIndex,
          onChange: (index: number) => this.onChange(index)
        })
      }, (item: TabBarData) => item.id.toString())
    }
    .border({
      width: 0.5,
      color: Color.White
    })
    .clip(false)
    .height(54)
    .width(Constants.FULL_SCREEN)
  }
}

@Component
struct TabItem {
  @Prop index: number
  @Prop selectedIndex: number;
  @State showAnimation: boolean = false;
  onChange: (index: number) => void = () => {
  };

  build() {
    Column() {
      Image(this.selectedIndex === this.index ? tabsInfo[this.index].activeIcon : tabsInfo[this.index].defaultIcon)
        .size({ width: 24, height: 24 })
      Text(tabsInfo[this.index].title)
        .fontSize(12)
        .fontColor(this.selectedIndex === this.index ? $r('app.color.keyword_type_font_color') : Color.Black)
        .margin({top: 4})
    }
    .borderWidth({top: 1})
    .borderColor('#F6F6F6')
    .padding({ top: 6, bottom: 8 })
    .clip(false)
    .layoutWeight(1)
    .size({ width: Constants.FULL_SCREEN, height: Constants.FULL_SCREEN })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.selectedIndex !== this.index) {
        this.showAnimation = true;
        this.onChange(this.index);
        setTimeout(() => {
          this.showAnimation = false;
        }, 300)
      }
    })
  }
}