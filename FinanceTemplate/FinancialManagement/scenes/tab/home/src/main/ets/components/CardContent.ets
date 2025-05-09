import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { HomePageVM } from '../viewModels/HomePageVM'

@ComponentV2
export struct CardContent {
  @Param productList: IProductItem[] = []
  vm: HomePageVM = HomePageVM.instance

  build() {
    Flex({ wrap: FlexWrap.NoWrap, justifyContent: FlexAlign.SpaceBetween }) {
      ForEach(this.productList, (item: IProductItem) => {
        Column() {
          Row() {
            Text(item.title)
              .fontSize(18)
          }
          .margin({ bottom: 4 })

          Row() {
            Text(item.name)
              .width('100%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .fontSize(16)
              .margin({ bottom: 10 })
          }
          .width('100%')

          Text(item.annualizedRate + '%')
            .fontSize(22)
            .fontColor(Color.Red)
            .margin({ bottom: 4 })
          Text(item.annualizedCycle)
            .fontSize(16)
            .fontColor(Color.Red)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }, (item: IProductItem[]) => JSON.stringify(item))
    }
  }
}