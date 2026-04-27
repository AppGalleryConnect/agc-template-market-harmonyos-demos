@ComponentV2
export struct PriceSortingDialog {
  // 价格排序
  @Param priceSortingArray: string[] = ['综合', '价格降序', '价格升序']
  // 选择回调排序方式
  @Param priceSorting: string = '综合'
  // 回调函数
  @Param priceSortingResult: (index: number) => void = (index: number) => {
  }

  build() {
    Column() {
      ForEach(this.priceSortingArray, (item: string, index) => {
        Row() {
          Text(item)
            .height(19)
            .fontColor(this.priceSorting === item ? 'rgba(255, 75, 75, 1)' : 'rgba(0, 0, 0, 0.6)')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)

        }
        .width('100%')
        .height(44)
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.priceSortingResult(index)
        })

        if (index !== this.priceSortingArray.length - 1) {
          Row() {
            Divider()
              .layoutWeight(1)
              .height(1)
              .backgroundColor('rgba(112, 112, 112, 0.1)')

          }
          .width('100%')
          .height(1)
          .backgroundColor(Color.White)

        }
      }, (item: string, index: number) => JSON.stringify(item) + index)
    }
    .backgroundColor(Color.White)
    .borderRadius({
      bottomLeft: 32,
      bottomRight: 32
    })
    .width('100%')
    .padding({
      left: 16,
      right: 15,
      bottom: 8
    })
  }
}