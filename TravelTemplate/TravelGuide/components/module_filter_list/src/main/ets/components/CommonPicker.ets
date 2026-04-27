@ComponentV2
export struct CommonPicker {
  @Param contentArr: string[] = [];
  @Param curIndex: number = 0;
  @Event onItemClick: (index: number) => void = () => {

  };

  build() {
    Grid() {
      ForEach(this.contentArr, (item: string, index) => {
        GridItem() {
          Text(item)
            .fontSize($r('sys.float.Body_M'))
            .fontWeight(FontWeight.Regular)
            .fontColor(this.curIndex === index ? $r('sys.color.font_on_primary') : $r('sys.color.font_secondary'));
        }
        .backgroundColor(this.curIndex === index ? $r('sys.color.alert') :
        $r('sys.color.comp_background_tertiary'))
        .height(28)
        .borderRadius(8)
        .onClick(() => {
          this.onItemClick(index);
        });
      }, (item: string) => item);
    }
    .gridBaseStyle();
  }
}

@Extend(Grid)
function gridBaseStyle() {
  .columnsTemplate('1fr 1fr 1fr 1fr')
  .columnsGap(11)
  .rowsGap(12)
  .backgroundColor($r('sys.color.background_secondary'))
  .padding({
    left: 16,
    right: 16,
    top: 12,
    bottom: 12,
  });
}