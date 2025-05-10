@Builder
export function ResultPageBuilder() {
  ResultPage();
}

@ComponentV2
struct ResultPage {
  @Local historyInfo: string[] = [
    '下饭菜',
    '烘焙',
    '菠萝',
    '快手菜',
    '家常菜',
    '槐花',
    '空心菜',
  ];

  build() {
    NavDestination() {
      Column() {
        Row().justifyContent(FlexAlign.SpaceBetween).padding(10)
      }.height('100%').width('100%')
    }.title('搜索结果');
  }
}

