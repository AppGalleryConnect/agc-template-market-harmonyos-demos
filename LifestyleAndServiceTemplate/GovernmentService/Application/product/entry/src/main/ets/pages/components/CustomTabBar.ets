import { TabsInfo } from 'common';
import { getDataFromJSON } from 'h5';

@Component
export struct CustomTabBar {
  @Link currentIndex: number;
  @State tabsInfos: TabsInfo[] = []
  aboutToAppear(): void {
    this.tabsInfos = getDataFromJSON<TabsInfo>('Tabs_Info.json', this);
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceBetween,
    }) {
      ForEach(this.tabsInfos, (item: TabsInfo, index: number) => {
        Column({ space: 5 }) {
          Image(this.currentIndex === index ? $r(item.icon) : $r(item.iconSel))
            .size({ width: 24, height: 24 })
          Text(item.title)
            .fontSize($r('sys.float.Caption_M'))
            .fontColor(this.currentIndex === index ? '#007DFF' : $r('sys.color.icon_secondary'))
            .fontSize($r('sys.float.Caption_M'))
        }.onClick(() => {
          this.currentIndex = index
        })
      }, (item: TabsInfo) => JSON.stringify(item))
    }
    .padding({ top: 5, bottom: Number(AppStorage.get('bottomRectHeight')) })
    .margin({
      left: 28,
      right: 28,
      top: 8,
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}
