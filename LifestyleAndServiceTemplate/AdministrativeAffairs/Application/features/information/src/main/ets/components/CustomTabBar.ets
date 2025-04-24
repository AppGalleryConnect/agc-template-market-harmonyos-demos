import { Constants, InformationTabsInfo, TabsInfo } from 'common';

@ComponentV2
export struct CustomTabBar {
  @Param fontSize: number = 16
  @Require @Param currentIndex: number;
  @Require @Param informationTabsInfo: InformationTabsInfo[]
  @Event currentIndexChange: (value: number) => void = (value: number) => {
  };

  build() {
    Grid() {
      ForEach(this.informationTabsInfo, (item: InformationTabsInfo, index: number) => {
        GridItem() {
          Column({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Text(item.name)
              .fontColor(this.currentIndex === index ? $r('sys.color.font_emphasize') : $r('sys.color.font_secondary'))
              .fontSize(this.fontSize)
            Divider()
              .height($r('app.float.information_title_divider_height'))
              .width($r('app.float.information_title_divider_width'))
              .color($r('sys.color.background_emphasize'))
              .visibility(this.currentIndex === index ? Visibility.Visible : Visibility.None)
          }.onClick(() => {
            this.currentIndexChange(index);
          })
          .height($r('app.float.information_title_size'))
        }.width(Constants.QUARTER_PERCENT_WIDTH)
      }, (item: TabsInfo) => JSON.stringify(item))
    }
    .backgroundColor($r('sys.color.background_primary'))
    .rowsTemplate('1fr')
    .height($r('app.float.information_custom_height'))
    .scrollBar(BarState.Off)
  }
}
