import { CustomTabsInfo } from '../model/Model';
import { getDataFromJSON } from '../utils/Utils';

@ComponentV2
export struct BaseCustomTabBar {
  @Require @Param currentIndex: number;
  @Require @Param rawSource: string = ''
  @Local tabsInfos: CustomTabsInfo[] = []
  @Event tabIndexChange: (index: number) => void = () => {
  }

  aboutToAppear(): void {
    this.tabsInfos = getDataFromJSON<CustomTabsInfo>(this.rawSource, this);
  }

  build() {
    Flex({
      direction: FlexDirection.Row,
      alignItems: ItemAlign.Center,
      justifyContent: FlexAlign.SpaceEvenly,
    }) {
      ForEach(this.tabsInfos, (item: CustomTabsInfo, index: number) => {
        Column() {
          Text(item.name)
            .fontSize($r('sys.float.Body_M'))
            .fontColor(this.currentIndex === index ? '#C4272B' : $r('sys.color.font_secondary'))
            .fontWeight(FontWeight.Medium)
        }
        .border({
          width: { bottom: this.currentIndex === index ? 2 : 0 },
          color: '#C4272B',
        })
        .padding({ top: 8, bottom: 8 })
        .onClick(() => {
          this.tabIndexChange(index)
        })
      }, (item: CustomTabsInfo) => JSON.stringify(item))
    }
    .backgroundColor($r('sys.color.background_primary'))
    .border({
      width: { bottom: 1 },
      color: $r('sys.color.comp_divider'),
    })
    .margin({ top: 11})
  }
}
