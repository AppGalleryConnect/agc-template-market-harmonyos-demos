@ComponentV2
export struct HotelPolicyGridItem {
  @Param title: string = '';
  @Param img: string = ''
  @Param items: string[] = [];

  build() {
    Column({ space: 10 }) {
      Column() {
        Row() {
          Image($r(this.img)).width(14).height(14)
          Text(this.title).textTitlePolicy()
        }.width('100%').alignItems(VerticalAlign.Top).justifyContent(FlexAlign.Start)
      }.margin({ top: 20 })

      Grid() {
        ForEach(this.items, (item: string, index: number) => {
          GridItem() {
            Column() {
              Text(item).textContentPolicy()
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start).margin({ left: 21 })
          }
        },(item: string) => JSON.stringify(item))
      }
      .columnsTemplate('1fr 1fr') // 三列等宽
      .columnsGap(10) // 列间距
      .rowsGap(8) // 行间距
      .width('100%')
    }
    .width('100%').alignItems(HorizontalAlign.Start)
  }
}

@Extend(Text)
function textTitlePolicy() {
  .fontWeight(500)
  .margin({ left: 7, bottom: 10 })
  .fontSize(14)
  .fontColor('#000000')
}

@Extend(Text)
function textContentPolicy() {
  .fontSize(12)
  .fontWeight(400)
  .fontColor('#000000')
}