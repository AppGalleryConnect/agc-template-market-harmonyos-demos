import { BreakpointModel, Constants, RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { BrandView } from '../components/BrandView';
import { MockData } from '../data/MockData';
import { BrandViewProps, MainPageVM, ProductInfo } from '../viewmodel/MainPageVM';
import { BrandDetailPageBuilder } from './BrandDetailPage';
import { SearchProductPageBuilder } from './SearchProductPage';
import { AppStorageV2 } from '@kit.ArkUI';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { FilterView } from '../components/FilterView';
import { ProductView } from '../components/ProductView';
import { MoreBrandProductPageBuilder } from './MoreBrandProductPage';
import { CommonPageVM } from '../viewmodel/CommonPageVM';

/**
 * @usage: 商品品牌详情页面，根据商品类型展示对应品牌列表和商品列表，支持搜索和筛选功能
 * @layout: 页面采用可滚动布局（Scroll），顶部是搜索框，中间是品牌网格展示，下方是带筛选条件的商品列表
 * @constraints: 品牌数据和商品数据来自 MockData，支持折叠屏适配
 * @isGen: true
 * @fileType: page
 * @zhName: 商品品牌详情页面
 * @subPage: BrandDetailPage,SearchProductPage,MoreBrandProductPage
 * @component: BrandView,FilterView,ProductView
 * @image: screenshots/homepage/productBrandDetail.png
 */

@Builder
export function ProductBrandDetailPageBuilder(obj: Object) {
  ProductBrandDetailPage({ index: obj as number })
}

export interface JumpType {
  index: number
  param: string
}

export const subPageType: JumpType[] = [
  {
    index: 1,
    param: '手机'
  },
  {
    index: 2,
    param: '平板'
  },
  {
    index: 3,
    param: '笔记本'
  },
  {
    index: 4,
    param: '手表'
  },
  {
    index: 5,
    param: '智能穿戴'
  },
  {
    index: 6,
    param: '相机'
  },
  {
    index: 7,
    param: '无人机'
  }
]

@Entry
@ComponentV2
export struct ProductBrandDetailPage {
  private logTag: string = 'ProductBrandDetailPage'
  // 当前点击的商品类型下标
  @Param index: number = 0
  // 筛选对象
  @Local vm: MainPageVM = MainPageVM.rootInstance
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // Grid四列字符串
  @Local gridFourColumnsModel: string = GridRowColSetting.getColumnCountModel(4)
  // Grid双列字符串
  @Local gridTwoColumnsModel: string = GridRowColSetting.getColumnCountModel(2)
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();
  @Local productList: Array<ProductInfo> = MockData.phoneProductList
  // 筛选对象
  @Local commonPageVM: CommonPageVM = new CommonPageVM()

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.gridFourColumnsModel = GridRowColSetting.getColumnCountModel(4)
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
    this.gridTwoColumnsModel = GridRowColSetting.getColumnCountModel(2)
  }

  // 搜索框
  @Builder
  searchBar() {
    Row() {
      Row() {
        Image($r('app.media.back'))
          .width(40)
          .onClick(() => {
            // 返回
            phoneRouterControl.popPage()
          });

        Row() {
          Image($r('app.media.icon_search'))
            .margin({
              left: 15,
              top: 12,
              bottom: 12
            })
            .width(16)
            .height(16)

          Text('请输入搜索内容')
            .fontColor('rgba(0, 0, 0, 0.4)')
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
            .height(21)
            .fontSize(16)
            .margin({
              left: 10,
              top: 10,
              bottom: 9
            })

          Blank().layoutWeight(1)

          Image($r('app.media.ic_close'))
            .margin({
              top: 15,
              bottom: 15,
              right: 15
            })
            .width(16)
            .height(16)

        }
        .height(40)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .layoutWeight(1)
        .borderRadius(20)
        .margin({ left: 15 })
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.GOODS_SEARCH_PAGE,
            builder: wrapBuilder(SearchProductPageBuilder)
          });
        })

        Row() {
          Text('搜索')
            .fontColor('rgba(0, 0, 0, 0.9)')
            .fontSize(14)
            .fontWeight(FontWeight.Regular)
        }
        .margin({
          left: 16,
          right: 16
        })
        .height('100%')
        .alignItems(VerticalAlign.Center)

      }
      .width('100%')
      .height('100%')
    }
    .padding({
      left: 16,
      top: 8,
      bottom: 8
    })
    .width('100%')
    .height(56)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  jump(item: BrandViewProps, i: number) {
    subPageType.forEach((subPage: JumpType) => {
      if (this.index === subPage.index ) {
        this.goJump(item, i, subPage)
      }
    })
  }

  goJump(item: BrandViewProps, i: number, subPage: JumpType) {
    if (i !== 7) {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.BRAND_GOODS_PAGE,
        builder: wrapBuilder(BrandDetailPageBuilder),
        param: `${item.name}${subPage.param}`
      })
    } else {
      phoneRouterControl.jumpPage({
        pageName: RouterMap.MORE_MODEL_PAGE,
        builder: wrapBuilder(MoreBrandProductPageBuilder),
        param: `${subPage.param}`
      })
    }
  }

  // 商品品牌格子布局
  @Builder
  productBrandGridLayout() {
    // 品牌展示
    Column() {
      Grid() {
        ForEach(this.getBrandList(this.index), (item: BrandViewProps, i: number) => {
          GridItem() {
            BrandView({
              item: {
                // 品牌名称
                name: item.name,
                // 品牌图标
                icon: item.icon,
              },
              paddingWidth: i === this.getBrandList(this.index).length - 1 ? 8 : 0
            })
              .onClick(() => {
                this.jump(item, i)
              })
          }
          .width('100%')
          .layoutWeight(1)
        }, (item: BrandViewProps, idx: number) => JSON.stringify(item) + idx)
      }
      .width('100%')
      .height('100%')
      .rowsGap(12)
      .columnsTemplate(this.gridFourColumnsModel)
    }
    .width('100%')
    .height(this.collapseExpandState ? 70 : 140)
    .padding({
      left: 16,
      right: 16
    })
    .margin({
      top: 12
    })
  }

  // 获取品牌布局的数据
  getBrandList(index: number): Array<BrandViewProps> {
    if (index === 0) {
      // 返回全部分类列表
      return MockData.allBrandList
    } else if (index === 1) {
      // 返回手机分类列表
      return MockData.phoneBrandList
    } else if (index === 2) {
      // 返回平板分类列表
      return MockData.padBrandList
    } else if (index === 3) {
      // 返回笔记本分类列表
      return MockData.noteBookBrandList
    } else if (index === 4) {
      // 返回家电分类列表
      return MockData.watchBrandList
    } else if (index === 5) {
      // 返回智能穿戴
      return MockData.smartWatchBrandList
    } else if (index === 6) {
      // 返回相机分类列表
      return MockData.cameraBrandList
    } else if (index === 7) {
      // 获取无人机分类列表
      return MockData.noPersonBrandList
    }
    return []
  }

  // 商品列表
  @Builder
  productListLayout() {
    // 筛选条件
    FilterView({
      vm: this.commonPageVM,
      modelIndex: this.index,
      isFixed: false,
      topMargin: 12,
      onchange: (res) => {

      }
    }) {
      // 商品列表
      Column() {
        Grid() {
          ForEach(this.commonPageVM.getSelectProductList(), (item: ProductInfo, index: number) => {
            GridItem() {
              ProductView({
                product: item
              })
            }
            .width('100%')
          }, (item: ProductInfo, idx: number) => JSON.stringify(item) + idx)
        }
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .columnsTemplate(this.gridTwoColumnsModel)
      }
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // 搜索框布局
          this.searchBar()

          // 商品品牌格子布局
          this.productBrandGridLayout()

          // 筛选商品列表
          this.productListLayout()
        }
        .backgroundColor(Color.White)
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .align(Alignment.Top)
      .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    }.hideToolBar(true).hideTitleBar(true).padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })

  }
}