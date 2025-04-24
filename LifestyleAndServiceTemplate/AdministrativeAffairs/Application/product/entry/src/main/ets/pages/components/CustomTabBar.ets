import { Constants, getDataFromJSON, HomeServiceEnum, TabsInfo } from 'common';

@ComponentV2
export struct CustomTabBar {
  @Require @Param currentIndex: number;
  @Local tabsInfos: TabsInfo[] = []
  @Consumer('tabCurrentIndex') tabCurrentIndex: number = 0
  @Event tabIndexChange: (index: number) => void = () => {
  }

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
        if (index === HomeServiceEnum.Code) {
          Column({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Column() {
              Image(this.currentIndex === index ? $r(item.iconSel) : $r(item.icon))
                .size({ width: $r('app.float.tab_icon_size'), height: $r('app.float.tab_icon_size') })
            }
            .linearGradient({
              angle: 180,
              colors: [
                ['#58BC11', 0.0],
                ['#C1EF2E', 1.0],
              ],
            })
            .padding($r('app.float.tab_icon_padding'))
            .margin({ top: $r('app.float.code_icon_margin') })
            .borderRadius(Constants.HALF_PERCENT_RADIUS)
            .border({
              width: 5,
              color: Color.White,
            })
            .onClick(() => {
              this.tabIndexChange(index)
            })

            Text(item.title)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor(this.currentIndex === index ? $r('app.color.tab_icon_active') : $r('sys.color.icon_secondary'))
              .fontSize($r('sys.float.Caption_M'))
          }
        } else {
          Column({ space: Constants.CONTAINER_SPACE_FIVE }) {
            Image(this.currentIndex === index ? $r(item.iconSel) : $r(item.icon))
              .size({ width: $r('app.float.tab_icon_size'), height: $r('app.float.tab_icon_size') })
            Text(item.title)
              .fontSize($r('sys.float.Caption_M'))
              .fontColor(this.currentIndex === index ? $r('app.color.tab_icon_active') : $r('sys.color.icon_secondary'))
              .fontSize($r('sys.float.Caption_M'))
          }.onClick(() => {
            this.tabIndexChange(index)
          })
        }

      }, (item: TabsInfo) => JSON.stringify(item))
    }
    .padding({ top: $r('app.float.custom_tab_padding_top'), bottom: Number(AppStorage.get('bottomRectHeight')) })
    .margin({
      left: $r('app.float.common_margin_thirty_eight'),
      right: $r('app.float.common_margin_thirty_eight'),
      top: $r('app.float.common_margin_eight'),
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}
