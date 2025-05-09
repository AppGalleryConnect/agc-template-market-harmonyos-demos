import { FormatUtil, RouterMap } from 'commonlib'
import { CustomTabContent } from '../components/productList/CustomTabContent'
import { ProductListVM } from '../viewModels/ProductListVM'

@Builder
export function ProductListBuilder() {
  ProductList()
}

@ComponentV2
struct ProductList {
  vm: ProductListVM = ProductListVM.instance
  @Local fontColor: ResourceStr = $r('sys.color.font_secondary')
  @Local selectedFontColor: string = '#E4480C'
  private controller: TabsController = new TabsController()
  private searchController: SearchController = new SearchController()

  build() {
    NavDestination() {
      Column() {
        Search({ value: this.vm.searchText, placeholder: '请输入产品名称/代码', controller: this.searchController })
          .width('100%')
          .height(40)
          .placeholderColor($r('sys.color.font_secondary'))
          .placeholderFont({ size: 16, weight: FontWeight.Regular })
          .textFont({ size: 16, weight: FontWeight.Regular })
          .focusable(false)
          .onClick(() => {
            FormatUtil.jumpToNext(RouterMap.PRODUCT_SEARCH)
          })

        Tabs({ barPosition: BarPosition.Start, index: this.vm.currentIndex, controller: this.controller }) {
          TabContent() {
            CustomTabContent()
          }
          .tabBar(this.tabBuilder(0, '活钱管理'))

          TabContent() {
            CustomTabContent()
          }.tabBar(this.tabBuilder(1, '稳健低波'))

          TabContent() {
            CustomTabContent()
          }.tabBar(this.tabBuilder(2, '稳健增值'))

          TabContent() {
            CustomTabContent()
          }.tabBar(this.tabBuilder(3, '投资增益'))

          TabContent() {
            CustomTabContent()
          }.tabBar(this.tabBuilder(4, '投资回报'))
        }
        .vertical(false)
        .barMode(BarMode.Fixed)
        .barWidth('100%')
        .barHeight(56)
        .animationDuration(400)
        .onChange((index: number) => {
          this.vm.currentIndex = index
          this.vm.selectedIndex = index
          this.vm.refresh(index)
        })
        .onAnimationStart((index: number, targetIndex: number, event: TabsAnimationEvent) => {
          if (index === targetIndex) {
            return
          }
          this.vm.selectedIndex = targetIndex
        })
        .width('100%')
        .height('100%')
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .title('理财产品选择')
    .onShown(() => {
      this.vm.init()
    })
    .onHidden(() => {
      this.vm.clear()
    })
  }

  @Builder
  tabBuilder(index: number, name: string) {
    Column() {
      Column() {
        Text(name)
          .fontColor(this.vm.selectedIndex === index ? this.selectedFontColor : this.fontColor)
          .fontSize(14)
          .fontWeight(this.vm.selectedIndex === index ? FontWeight.Bold : FontWeight.Regular)
          .margin({ top: 17, bottom: 7 })
        Divider()
          .strokeWidth(2)
          .color('#E4480C')
          .opacity(this.vm.selectedIndex === index ? 1 : 0)
      }
      .width(56)
    }
    .width('100%')
  }
}