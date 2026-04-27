import { Constants } from 'common'
import { BrandView } from '../BrandView'
import { phoneRouterControl, NavPageInfo } from 'oh_router'
import { RouterMap } from 'common'
import { ProductCategoryPageBuilder } from './ProductCategoryPage'
import { CustomerServiceDialogBuilder } from 'valuation_information'
import { SearchProductPageBuilder } from '../../pages/SearchProductPage'

/**
 * @usage: 商品估价入口页面，展示回收类型选择网格，包括手机、平板、笔记本、手表、智能穿戴、拍照摄像、无人机等分类，点击分类跳转到商品分类页面
 * @layout: 页面采用垂直布局（Column），顶部是搜索输入框，下方是回收类型选择卡片，卡片内使用 Grid 网格布局展示 8 个分类图标
 * @constraints: 分类列表 categoryList 包含 8 个固定分类项，点击分类跳转到 ProductCategoryPage
 * @isGen: true
 * @fileType: page
 * @zhName: 商品估价页面
 * @subPage: ProductCategoryPage,SearchProductPage
 * @component: BrandView
 * @image: screenshots/homepage/valuation.png
 */

@Builder
export function ValuationPageBuilder() {
  ValuationPage()
}

@ComponentV2
export struct ValuationPage {
  @Local categoryList: CategoryItemVM[] = [
    { title: '手机', icon: $r('app.media.image_demo_phone2') },
    { title: '平板', icon: $r('app.media.img_demo_padA') },
    { title: '笔记本', icon: $r('app.media.img_demo_notebookA') },
    { title: '手表', icon: $r('app.media.img_demo_watchA') },
    { title: '智能穿戴', icon: $r('app.media.img_huawei') },
    { title: '拍照摄像', icon: $r('app.media.img_demo_cameraA') },
    { title: '无人机', icon: $r('app.media.img_demo_no_personA') },
    { title: '全部', icon: $r('app.media.img_more') },
  ]
  @Local showCustomerSheet: boolean = false

  @Builder
  customerServiceSheet() {
    CustomerServiceDialogBuilder('客服', '000-****-0000', () => {
      this.showCustomerSheet = false
    }, $r('app.media.ic_public_close_sheet'), 170)
  }

  getTargetTabIndex(title: string): number {
    switch (title) {
      case '全部':
        return 0
      case '手机':
        return 1
      case '平板':
        return 2
      case '笔记本':
        return 3
      case '手表':
        return 4
      case '智能穿戴':
        return 5
      case '拍照摄像':
        return 6
      case '无人机':
        return 7
      default:
        return 0
    }
  }

  build() {
    NavDestination() {
      Column() {
        // 输入框
        Row() {
          Image($r('app.media.icon_search'))
            .width(16)
            .height(16)
            .margin({
              left: 15,
              top: 12,
              bottom: 12
            })
          Text('请输入')
            .fontSize(16)
            .fontColor('rgba(0, 0, 0, 0.4)')
            .layoutWeight(1)
            .margin({
              left: '4%',
              right: '4%',
            })

          Blank();
          Text('搜索')
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.4)')
            .fontWeight(FontWeight.Regular)
        }
        .width('100%')
        .height(40)
        .alignItems(VerticalAlign.Center)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .padding({ right: 16 })
        .margin({ bottom: 12 })
        .borderRadius(40)
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.GOODS_SEARCH_PAGE,
            builder: wrapBuilder(SearchProductPageBuilder)
          });
        })

        Column() {
          Column() {
            Text('选择回收类型')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('rgba(0,0,0,1)')
              .margin({ left: 12, top: 15 })
              .textAlign(TextAlign.Start)
            Column() {
              Grid() {
                ForEach(this.categoryList, (item: CategoryItemVM, index: number) => {
                  GridItem() {
                    BrandView({
                      item: {
                        // 品牌图标
                        icon: item.icon,
                        // 品牌名称
                        name: item.title,
                      }
                    })
                      .onClick(() => {
                        const targetIndex: number = this.getTargetTabIndex(item.title)
                        const params: ProductCategoryParam = { initIndex: targetIndex }
                        const pageInfo: NavPageInfo = {
                          pageName: RouterMap.PRODUCT_CATEGORY_PAGE,
                          builder: wrapBuilder(ProductCategoryPageBuilder),
                          param: params
                        }
                        phoneRouterControl.jumpPage(pageInfo)
                      })
                  }
                  .width('100%')
                  .height('100%')
                }, (item: CategoryItemVM, index: number) => JSON.stringify(item) + index)
              }
              .width('100%')
              .height('100%')
              .rowsGap(4)
              .rowsTemplate('1fr 1fr')
              .columnsTemplate('1fr 1fr 1fr 1fr')
            }
            .width('100%')
            .height(140)
            // .padding({
            //   left: 16,
            //   right: 16
            // })
            .margin({
              top: 12,
              bottom: 12
            })
          }
          .width('100%')
          .borderRadius(12)
          .backgroundColor(Color.White)
          .borderWidth(0.5)
          .borderColor('rgba(0,0,0,0.08)')
          .shadow({
            radius: 8,
            color: 'rgba(0,0,0,0.06)',
            offsetX: 0,
            offsetY: 1
          })
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 8, right: 8 })
          .bindSheet($$this.showCustomerSheet, this.customerServiceSheet(),
            { detents: [170], preferType: SheetType.BOTTOM, showClose: false })
        }
      }
      .height('100%').width('100%')
      .padding({ left: 16, right: 16 })
    }
    .title('商品估价').hideToolBar(true)
    .padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }
}

interface CategoryItemVM {
  title: string
  icon: ResourceStr
}

interface ProductCategoryParam { initIndex: number }

