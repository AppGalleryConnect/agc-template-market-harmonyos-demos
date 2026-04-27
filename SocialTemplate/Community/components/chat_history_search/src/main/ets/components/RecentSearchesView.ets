@ComponentV2
export struct RecentSearchesView {
  @Param @Require onRecentSearchClick: (searchText: string) => void = (searchText: string) => {
  };
  @Param searchHistoryList: string[] = [];

  build() {
    Column() {
      Text($r('app.string.search_history'))
        .fontSize($r('sys.float.Body_M'))
        .fontColor($r('sys.color.icon_tertiary'))
        .lineHeight($r('app.float.vp_22'))
        .margin({
          bottom: $r('app.float.vp_8'),
        })
      Divider()
        .strokeWidth('1px')
        .width('100%')
        .color($r('sys.color.comp_divider'))
      List() {
        Repeat<string>(this.searchHistoryList)
          .each((ri: RepeatItem<string>) => {
            ListItem() {
              Text(ri.item)
                .fontSize($r('sys.float.Body_M'))
                .fontColor($r('sys.color.icon_secondary'))
                .lineHeight($r('app.float.vp_22'))
                .width('100%')
                .padding({
                  right: $r('app.float.vp_4'),
                  left: ri.index % 2 === 1 ? $r('app.float.vp_4') : 0
                })
                .maxLines(1)
                .margin({
                  right: $r('app.float.vp_8'),
                  bottom: $r('app.float.vp_8'),
                })
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .onClick(() => {
                  this.onRecentSearchClick(ri.item);
                })
            }
          })
          .key((item: string): string => item)
          .virtualScroll()
      }
      .lanes(2)
      .width('100%')
      .height('auto')
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: true })
      .margin({
        top: $r('app.float.vp_12')
      })
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({
      top: $r('app.float.vp_12'),
    })
  }
}