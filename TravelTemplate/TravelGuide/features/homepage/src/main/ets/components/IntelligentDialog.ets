@ComponentV2
export struct IntelligentDialog {
  @Param contentArr: string[] = []
  @Param selectIntelligentIndex: number = 0
  @Event onItemClick: (index: number) => void = () => {

  };

  build() {
    Column() {
      Column() {
        ForEach(this.contentArr, (item: string, index) => {
          Row() {
            Text(item)
              .fontSize(14)
              .fontColor('#333333')
              .fontWeight(FontWeight.Regular)
            if (this.selectIntelligentIndex === index) {
              Image($r('app.media.ic_selected')).width(20).height(20)
            }
          }.justifyContent(FlexAlign.SpaceBetween).width('100%')
          .onClick(() => {
            this.onItemClick(index);
          })

        }, (item: string) => item);
      }
      .margin({ left: 16 })
      .height(200)
      .width(128)
      .backgroundColor('#FFFFFF')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.SpaceAround)
      .borderRadius(24)
    }.width('100%').alignItems(HorizontalAlign.Start)

  }
}