export interface INodeItem {
  text: string,
  time: string,
  description: string
  image: ResourceStr,
  selectedImage: ResourceStr,
}

@ComponentV2
export struct CommonTimeLine {
  @Param nodeList: INodeItem[] = []
  @Param minHeight: number = 54

  build() {
    Column() {
      ForEach(this.nodeList, (node: INodeItem, index: number) => {
        Flex({ alignItems: ItemAlign.Start }) {
          Column() {
            Image(index === 0 ? node.selectedImage : node.image)
              .width(24)
              .height(28)
            if (index !== this.nodeList.length - 1) {
              Column()
                .width(2)
                .height(this.minHeight)
                .borderWidth({ right: 1 })
                .borderColor($r('sys.color.comp_divider'))
                .borderStyle(BorderStyle.Dashed)
                .margin({ left: -1 })
            }
          }

          Column() {
            Text(node.text)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('sys.color.font_primary'))
              .margin({ top: 5 })


            Text(node.time)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_secondary'))
              .margin({ top: 4, bottom: 4 })

            Text(node.description)
              .fontSize(10)
              .fontWeight(FontWeight.Regular)
              .fontColor($r('sys.color.font_primary'))
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 8 })
          .flexGrow(1)
        }
        .width('100%')
      }, (item: INodeItem[]) => JSON.stringify(item))
    }
  }
}