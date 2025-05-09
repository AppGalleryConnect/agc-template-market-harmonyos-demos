import { BookCover, BookInfo, Constants, LazyDataVM, TCRouter } from 'common';


@ComponentV2
export struct BookWaterFlowCard {
  @Param @Require books: LazyDataVM<BookInfo>
  @Local bookInfoList: BookInfo[] = [];

  @Builder
  waterItem(info: BookInfo) {
    Column() {
      Column() {
        Column() {
          BookCover(info.coverUrl, info.isFree)
        }.padding({ top: 20 })
      }
      .backgroundColor($r('app.color.common_background'))
      .height(180)
      .width(170)

      Column() {
        Text(info?.name)
          .fontSize($r('sys.float.Body_L'))
          .fontColor($r('sys.color.font_primary'))
          .fontWeight(FontWeight.Medium)
          .maxLines(2)
          .padding({ top: 5 })

        Row() {
          Image($r('app.media.ic_public_star'))
            .height(15)
            .width(20)
            .padding({ right: 8 })
          Text(`${info?.rate} ${info?.category} | ${info?.author}`)
            .fontSize($r('sys.float.Body_M'))
            .fontColor($r('sys.color.font_secondary'))
        }
        .padding({ top: 12 })
      }
      .alignItems(HorizontalAlign.Start)
      .height(50)
    }
    .borderRadius(10)
    .borderWidth(0.05)
    .padding({ bottom: 12 })
    .onClick(() => {
      if (info) {
        TCRouter.push(Constants.READ_ROUTER, info);
      }
    })
  }

  async aboutToAppear() {
    this.bookInfoList = await this.books.getAllData()
  }

  build() {
    Column() {
      Text($r('app.string.more_and_more'))
        .fontSize(20)
        .fontColor($r('sys.color.font_primary'))
        .textAlign(TextAlign.Start)
        .width(Constants.FULL_SIZE)
      Column() {
        WaterFlow() {
          ForEach(this.bookInfoList, (info: BookInfo) => {
            FlowItem() {
              this.waterItem(info)
            }
            .width(Constants.FULL_SIZE)
          }, (item: BookInfo) => `${item.id}${new Date().toString()}`)
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(10)
        .rowsGap(5)
        .padding({ bottom: '29%' })
      }.padding({ top: 5 })
    }
    .padding({ top: 20, left: 18, right: 18 })
    .width(Constants.FULL_SIZE)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
  }
}