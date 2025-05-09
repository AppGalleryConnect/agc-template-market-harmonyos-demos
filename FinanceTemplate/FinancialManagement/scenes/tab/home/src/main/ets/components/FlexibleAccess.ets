import { FormatUtil, RouterMap } from 'commonlib'
import { IProductItem } from 'network/src/main/ets/types/responseTypes/GetProductResp'
import { HomePageVM } from '../viewModels/HomePageVM'

@ComponentV2
export struct FlexibleAccess {
  vm: HomePageVM = HomePageVM.instance

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.SpaceBetween }) {
        Text('灵活取用')
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

      Flex() {
        ForEach(this.vm.flexibleAccessProductList, (product: IProductItem) => {
          Column() {
            Text(product.title)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .margin({ bottom: 2 })
            Text(product.name)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .margin({ bottom: 16 })
            Text(product.annualizedRate + '%')
              .fontSize(20)
              .fontWeight(FontWeight.Medium)
              .fontColor('#C15F2F')
              .margin({ bottom: 5 })
            Text(product.annualizedCycle)
              .fontSize(12)
              .fontWeight(FontWeight.Regular)
              .opacity(0.4)
              .margin({ bottom: 8 })
            Row() {
              Text(product.minimumPurchaseAmount + '元起购')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
              Text(' | ')
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
                .opacity(0.4)
              Text(product.risk)
                .fontSize(12)
                .fontWeight(FontWeight.Regular)
            }
          }
          .flexGrow(0.5)
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16 })
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRODUCT_INFO, product.id)
          })
        }, (item: IProductItem[]) => JSON.stringify(item))
      }
      .padding({ top: 16, bottom: 16 })
      .borderRadius(16)
      .linearGradient({
        direction: GradientDirection.Bottom, // 渐变方向
        repeating: true, // 渐变颜色是否重复
        colors: [[0xF0F2FF, 0.0], [0xffffff, 0.32], [0xffffff, 1]] // 数组末尾元素占比小于1时满足重复着色效果
      })
    }
    .margin({ top: 24 })
  }
}