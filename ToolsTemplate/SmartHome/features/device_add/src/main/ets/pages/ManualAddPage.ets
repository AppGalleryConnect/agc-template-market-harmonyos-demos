import { TwoLevelListView } from '../view/TwoLevelListView'
import { ProductListViewModel } from '../viewmodel/ProductListViewModel'

@Builder
export function ManualAddPageBuilder(name: string, param: Object) {
  ManualAddPage()
}

@ComponentV2
export struct ManualAddPage {
  pathStack: NavPathStack = new NavPathStack()
  productListViewModel: ProductListViewModel = new ProductListViewModel()
  level2ItemNum: number[] = []
  controller: SearchController = new SearchController();

  aboutToAppear(): void {
    for (let i = 0; i < this.productListViewModel.products.length; i++) {
      this.level2ItemNum.push(this.productListViewModel.products[i].products.length)
    }
  }

  @BuilderParam level1Builder: (level1Index: number) => void
  @BuilderParam level2Builder: (level1Index: number, level2Index: number) => void

  @Builder BuildProduct(level1Index: number, level2Index: number) {
    Row(){
      Image(this.productListViewModel.products[level1Index].products[level2Index].image)
        .objectFit(ImageFit.Contain)
        .size({ width: 50, height: 40 })
      Text(this.productListViewModel.products[level1Index].products[level2Index].name)
        .margin({left: 10})
        .width(150)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .maxLines(1)
        .wordBreak(WordBreak.BREAK_ALL)
    }
    .width('100%')
    .onClick(() => {
      this.pathStack.pushPathByName('AddInstructionPage',
        this.productListViewModel.products[level1Index].products[level2Index].name)
    })
  }

  @Builder BuildClass(level1Index: number) {
    Row(){
      Image(this.productListViewModel.products[level1Index].productClass.image)
        .size({ width: 30 })
      Text(this.productListViewModel.products[level1Index].productClass.name)
        .margin({left: 10})
    }
    .width(90)
  }

  @Builder BuildClassProduct() {
    Row() {
      Row() {
        TwoLevelListView({level2ItemNum: this.level2ItemNum, level1ItemBuilder: this.BuildClass.bind(this),
          level2ItemBuilder: this.BuildProduct.bind(this)});
      }
      .height('92%')
      .width('90%')
    }
    .justifyContent(FlexAlign.Center)
    .height('95%')
    .width('90%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({top: 6})
  }

  build() {
    NavDestination() {
      Column() {
        this.BuildClassProduct()
      }
      .height('100%')
      .width('100%')
    }
    .title('手动添加')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack
    })
    .onBackPressed(() => {
      const popDestinationInfo = this.pathStack.pop() // 弹出路由栈栈顶元素
      console.log('pop' + '返回值' + JSON.stringify(popDestinationInfo))
      return true
    })
    .backgroundColor('#F1F3F5')
  }
}