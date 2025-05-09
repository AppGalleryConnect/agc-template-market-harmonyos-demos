import { FormatUtil, RouterMap } from 'commonlib'
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { HomePageVM } from '../viewModels/HomePageVM'

@ComponentV2
export struct FinancialNightMarket {
  vm: HomePageVM = HomePageVM.instance

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('理财夜市')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
        Row() {
          Text('更多')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
          Image($r('app.media.ic_chevron_right'))
            .width(12)
            .height(24)
        }
      }
      .margin({ bottom: 16 })
      .onClick(() => {
        FormatUtil.jumpToNext(RouterMap.PRODUCT_LIST,
          { type: this.vm.mainServiceList[0].type, index: this.vm.mainServiceList[0].index })
      })

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.vm.financialNightMarketProductList, (product: IProductItem, index: number) => {
          Column() {
            Row() {
              Text(product.title)
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .margin({ right: 5 })
              Row() {
                Text(product.tip)
                  .fontSize(10)
                  .fontWeight(FontWeight.Regular)
                  .fontColor('#C15F2F')
              }
              .width(48)
              .height(16)
              .borderWidth(1)
              .borderRadius(4)
              .borderColor('#C15F2F')
              .justifyContent(FlexAlign.Center)
            }
            .margin({ bottom: 8 })

            Text(product.annualizedRate + '%')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#C15F2F')
              .margin({ bottom: 5 })
            Text(product.annualizedCycle)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .opacity(0.4)
          }
          .width('50%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16 })
          .margin(index === 4 || index === 5 ? {} : { bottom: 24 })
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, product.id)
          })
        }, (item: IProductItem[]) => JSON.stringify(item))
      }
      .padding({ top: 16, bottom: 16 })
      .borderRadius(16)
      .linearGradient({
        direction: GradientDirection.Bottom,
        repeating: true,
        colors: [[0xFFFAF5, 0.0], [0xffffff, 0.51], [0xffffff, 1]]
      })
    }
    .margin({ top: 24 })
  }
}