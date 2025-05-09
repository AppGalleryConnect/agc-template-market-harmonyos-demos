@ComponentV2
export struct CommonRuleLine {
  @Param isPurchase: boolean = true
  @Param confirmationDate: string = ''
  @Param redemptionDate: string = ''

  @Builder
  contentBuilder(label: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('sys.color.font_primary'))

    Row()
      .width(1)
      .height(10)
      .backgroundColor('#E4480C')
  }

  build() {
    Row() {
      Column() {
        Text('17:00前')
          .fontSize(10)
          .fontWeight(FontWeight.Regular)
          .fontColor($r('sys.color.font_tertiary'))
        this.contentBuilder(this.isPurchase ? '购买日' : '赎回日')
        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#E4480C')
          .opacity(0.1)
      }
      .width('30%')
      .alignItems(HorizontalAlign.Start)

      Column() {
        Flex({ alignItems: ItemAlign.End, justifyContent: FlexAlign.SpaceBetween }) {
          Column() {
            Text(this.confirmationDate)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_tertiary'))
            this.contentBuilder('确认日')
          }
          .alignItems(HorizontalAlign.Start)

          Column() {
            Text(this.redemptionDate)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_tertiary'))
            this.contentBuilder(this.isPurchase ? '可随时赎回' : '到账日')
          }
          .alignItems(HorizontalAlign.End)
        }

        Row()
          .width('100%')
          .height(10)
          .backgroundColor('#E4480C')
          .opacity(0.1)
      }
      .width('70%')
      .alignItems(HorizontalAlign.Start)
    }
    .margin({ bottom: 10 })
  }
}