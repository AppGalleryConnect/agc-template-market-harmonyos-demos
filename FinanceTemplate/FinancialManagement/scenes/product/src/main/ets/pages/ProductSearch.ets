import { FormatUtil, RouterMap } from 'commonlib'
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { ProductSearchVM } from '../viewModels/ProductSearchVM'

@Builder
export function ProductSearchBuilder() {
  ProductSearch()
}

@ComponentV2
struct ProductSearch {
  vm: ProductSearchVM = ProductSearchVM.instance
  searchController: SearchController = new SearchController()

  build() {
    NavDestination() {
      Column() {
        Row() {
          Search({ value: this.vm.searchText, placeholder: '请输入产品名称/代码', controller: this.searchController })
            .width('100%')
            .height(40)
            .placeholderColor($r('sys.color.font_secondary'))
            .placeholderFont({ size: 16, weight: FontWeight.Regular })
            .textFont({ size: 16, weight: FontWeight.Regular })
            .fontColor($r('sys.color.font_primary'))
            .onSubmit((value: string) => {
              this.vm.search(value)
            })
        }
        .padding({ left: 16, right: 16 })

        Row() {
          Text(`共款${this.vm.productList.length}产品`)
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_secondary'))
        }
        .margin({ top: 16, bottom: 8 })
        .padding({ left: 16, right: 16 })

        List() {
          ForEach(this.vm.productList, (product: IProductItem) => {
            ListItem() {
              Column() {
                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Row() {
                    Text(product.name)
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(2)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                      .fontColor($r('sys.color.font_primary'))
                  }
                  .width('75%')
                  .margin({ right: 8 })

                  Row() {
                    Text(product.annualizedRate + '%')
                      .fontColor('#C15F2F')
                      .fontSize(14)
                      .fontWeight(FontWeight.Medium)
                  }
                  .width('25%')
                  .justifyContent(FlexAlign.End)
                }
                .height(38)
                .margin({ bottom: 2 })

                Flex({ justifyContent: FlexAlign.SpaceBetween }) {
                  Row() {
                    Text(product.number)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('75%')
                  .margin({ right: 8 })

                  Row() {
                    Text(product.annualizedCycle)
                      .fontSize(12)
                      .fontWeight(FontWeight.Regular)
                      .fontColor($r('sys.color.font_secondary'))
                  }
                  .width('25%')
                  .justifyContent(FlexAlign.End)
                }
              }
              .padding({
                left: 16,
                right: 16,
                top: 12,
                bottom: 8
              })
              .borderWidth({ bottom: 1 })
              .borderColor('#F1F3F5')
            }
            .backgroundColor(Color.White)
            .onClick(() => {
              FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, product.id)
            })
          }, (item: IProductItem[]) => JSON.stringify(item))
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('搜索')
    .onShown(() => {
      this.vm.init()
    })
  }
}