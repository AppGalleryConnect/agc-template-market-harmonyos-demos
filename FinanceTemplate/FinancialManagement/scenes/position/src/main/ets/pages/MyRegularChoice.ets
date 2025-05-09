import { FormatUtil } from 'commonlib'
import { RouterMap } from 'commonlib/src/main/ets/constants/CommonEnum'
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { MyRegularChoiceVM } from '../viewModels/MyRegularChoiceVM'

@Builder
export function MyRegularChoiceBuilder() {
  MyRegularChoice()
}

@ComponentV2
struct MyRegularChoice {
  vm: MyRegularChoiceVM = MyRegularChoiceVM.instance

  build() {
    NavDestination() {
      Column() {
        if (this.vm.myRegularChoiceList.length === 0) {
          Text('您目前没有已自选的理财产品哦~')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
            .fontColor($r('sys.color.font_tertiary'))
        } else {
          List() {
            ForEach(this.vm.myRegularChoiceList, (product: IProductItem) => {
              ListItem() {
                Column() {
                  Text(product.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor($r('sys.color.font_primary'))
                  if (product.tip) {
                    Row() {
                      Text(product.tip)
                        .fontSize(10)
                        .fontWeight(FontWeight.Regular)
                        .fontColor('#C15F2F')
                    }
                    .padding({
                      top: 1,
                      bottom: 1,
                      left: 4,
                      right: 4
                    })
                    .margin({ top: 2 })
                    .borderWidth(1)
                    .borderColor('#C15F2F')
                    .borderRadius(4)
                  }
                  Flex() {
                    Row() {
                      Text(product.annualizedRate + '%')
                        .fontSize(20)
                        .fontWeight(FontWeight.Medium)
                        .fontColor('#C15F2F')
                    }
                    .width('37.5%')
                    .margin({ right: 8 })

                    Row() {
                      Text(product.title)
                        .fontSize(14)
                        .fontWeight(FontWeight.Medium)
                        .fontColor($r('sys.color.font_primary'))
                    }
                    .flexGrow(1)
                  }
                  .margin({ top: 17, bottom: 9 })

                  Flex() {
                    Row() {
                      Text(product.annualizedCycle)
                        .fontSize(12)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_tertiary'))
                    }
                    .width('37.5%')
                    .margin({ right: 8 })

                    Row() {
                      Text(product.minimumPurchaseAmount + '元起购' + ' | ' + product.risk)
                        .fontSize(12)
                        .fontWeight(FontWeight.Regular)
                        .fontColor($r('sys.color.font_tertiary'))
                    }
                    .flexGrow(1)
                  }
                }
                .alignItems(HorizontalAlign.Start)
              }
              .backgroundColor(Color.White)
              .padding({
                top: 16,
                bottom: 16,
                left: 12,
                right: 12
              })
              .borderRadius(16)
              .margin({ bottom: 12 })
              .onClick(() => {
                FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, product.id)
              })
            }, (item: IProductItem[]) => JSON.stringify(item))
          }
        }
      }
      .padding({ left: 16, right: 16 })
    }
    .onShown(() => {
      this.vm.init()
    })
    .backgroundColor($r('sys.color.background_secondary'))
    .title('产品自选')
  }
}