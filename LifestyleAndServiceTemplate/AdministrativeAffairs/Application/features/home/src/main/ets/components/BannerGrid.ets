import { Constants, GridBanner, NavigationParams } from 'common'

@ComponentV2
export struct BannerGrid {
  @Require @Param gridBanner: GridBanner[] = [];
  @Consumer('pageInfos') pageInfos: NavPathStack = new NavPathStack()
  @Event currentIndexChange: (value: number) => void = (value: number) => {
  };

  aboutToAppear(): void {
  }

  jumpToRouter(item: GridBanner) {
    switch (item.name) {
      case '更多':
        this.goToService()
        break
      default:
        this.pageInfos.pushPathByName('notAvailable', new NavigationParams(item.name))
    }
  }

  goToService() {
    this.currentIndexChange(1)
  }

  build() {
    // Flex({ justifyContent: FlexAlign.SpaceBetween, wrap: FlexWrap.Wrap }) {
    Grid() {
      ForEach(this.gridBanner, (item: GridBanner) => {
        GridItem() {
          Column({ space: Constants.CONTAINER_SPACE_TEN }) {
            Image(item.pic)
              .width($r('app.float.banner_icon_size'))
              .height($r('app.float.banner_icon_size'))
              .syncLoad(false);
            Text(`${item.name}`)
              .textAlign(TextAlign.Center)
              .fontSize($r('sys.float.Body_S'))
              .fontColor($r('sys.color.font_primary'))
              .fontWeight(FontWeight.Regular)
          }
        }
        .onClick(() => {
          this.jumpToRouter(item)
        })
      }, (item: GridBanner) => item.name);
    }
    .rowsTemplate('1fr 1fr ')
    .columnsTemplate('1fr 1fr 1fr 1fr')

    // }
    .borderRadius($r('sys.float.corner_radius_level6'))
    .height($r('app.float.banner_grid_height'))
    .margin({
      left: $r('app.float.common_margin_sixty'),
      right: $r('app.float.common_margin_sixty'),
    })
    .backgroundColor($r('sys.color.background_primary'))
  }
}
