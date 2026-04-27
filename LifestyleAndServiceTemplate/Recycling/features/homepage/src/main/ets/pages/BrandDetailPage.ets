import { BreakpointModel, Constants } from 'common'
import { FilterView } from '../components/FilterView'
import { ProductView } from '../components/ProductView'
import { CommonPageVM } from '../viewmodel/CommonPageVM'
import { ProductInfo } from '../viewmodel/MainPageVM'
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { AppStorageV2 } from '@kit.ArkUI'
import { MockData } from '../data/MockData'
import { phoneRouterControl } from 'oh_router'

@Builder
export function BrandDetailPageBuilder(info: Object) {
  BrandDetailPage({ brand: info as string })
}

@ComponentV2
export struct BrandDetailPage {
  private readonly logTag: string = 'BrandDetailPage'
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  @Local messagePageVM: CommonPageVM = new CommonPageVM()
  // 传入的品牌对象
  @Param @Require brand: string
  // Grid双列字符串
  @Local gridTwoColumnsModel: string = GridRowColSetting.getColumnCountModel(2)
  // 型号下标
  @Local modelIndex: number = 0

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.gridTwoColumnsModel = GridRowColSetting.getColumnCountModel(2)
  }

  aboutToAppear(): void {
    // 更新商品列表
    if (this.brand.indexOf('手机') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.phoneProductList
      this.modelIndex = 1
    } else if (this.brand.indexOf('平板') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.padProductList
      this.modelIndex = 2
    } else if (this.brand.indexOf('笔记本') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.notebookProductList
      this.modelIndex = 3
    } else if (this.brand.indexOf('手表') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.watchProductList
      this.modelIndex = 4
    } else if (this.brand.indexOf('智能穿戴') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.iWatchProductList
      this.modelIndex = 5
    } else if (this.brand.indexOf('相机') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.cameraProductList
      this.modelIndex = 6
    } else if (this.brand.indexOf('无人机') >= 0) {
      // 获取筛选条件对象
      this.messagePageVM.productList = MockData.noPersonProductList
      this.modelIndex = 7
    }

  }

  @Builder
  render() {
    Scroll() {
      Column() {
        // 筛选条件
        FilterView({
          vm: this.messagePageVM,
          modelIndex: this.modelIndex,
          isFixed: true,
          onchange: (res) => {
          }
        }) {
          Scroll() {
            // 商品列表
            Column() {
              Grid() {
                ForEach(this.messagePageVM.getSelectProductList(), (item: ProductInfo, index: number) => {
                  GridItem() {
                    ProductView({
                      product: item
                    })
                  }
                  .width('100%')
                }, (item: ProductInfo, index: number) => JSON.stringify(item) + index)
              }
              .width('100%')
              .columnsTemplate(this.gridTwoColumnsModel)
              .columnsGap(8)
              .rowsGap(8)

            }
            .width('100%')
            .padding({
              left: 16,
              right: 16
            })
          }
          .width('100%')
          .layoutWeight(1)
          .align(Alignment.Top)
          .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor('rgba(255, 255, 255, 1)')
    }
    .width('100%')
    .height('100%')
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })

  }

  build() {
    NavDestination() {
      this.render()
    }
    .padding({ top: Constants.PADDING_4XL })
    .title(`${this.brand}`)
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}