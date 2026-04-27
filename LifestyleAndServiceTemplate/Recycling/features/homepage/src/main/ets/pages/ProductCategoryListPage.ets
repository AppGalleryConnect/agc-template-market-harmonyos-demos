import { Constants } from 'common';
import { CategoryItem, SubCategoryItem, ItemInfo, LayoutType } from 'category_list';
import { RouterMap } from 'common';
import { phoneRouterControl } from 'oh_router';
import { CategoryListView } from '../components/CategoryListView';
import { MockData } from '../data/MockData';
import { BrandDetailPageBuilder } from './BrandDetailPage';

/**
 * @usage: 商品分类列表页面，展示全部商品分类，支持一级分类切换和二级分类商品展示，点击商品跳转到品牌详情页。
 * @layout: 采用垂直布局（Column），内部为分类列表组件，左侧为一级分类，右侧为商品网格。
 * @isGen: true
 * @fileType: page
 * @zhName: 商品分类列表页面
 * @subPage: BrandDetailPage
 * @component: CategoryListView
 * @image: screenshots/homepage/productCategory.png
 */

@Builder
export function ProductCategoryListPageBuilder() {
  ProductCategoryListPage()
}

@Entry
@ComponentV2
struct ProductCategoryListPage {
  @Local currentIndex: number = 0
  @Local themeColor: ResourceColor = 'rgba(255, 75, 75, 1)'

  build() {
    NavDestination() {
      Column() {
        // 分类列表
        CategoryListView({
          categoryTabs: this.tabList,
          productList: this.recipeCategoryList,
          initIndex: this.currentIndex,
          layoutType: LayoutType.GRID,
          themeColor: this.themeColor,
          tabBarScroller: new Scroller(),
          subBarScroller: new Scroller(),
          scroller: new Scroller(),
          itemBuilderParam: this.itemBuilder,
          onTabClick: (tabItem: CategoryItem) => {
            this.getProductList(tabItem)
          },
          onItemClick: (itemDetail: ItemInfo, item: SubCategoryItem) => {
            // 待实现，跳转详情页
            if (item.label.indexOf('手机') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}手机`
              })
            } else if (item.label.indexOf('平板') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}平板`
              })
            } else if (item.label.indexOf('笔记本') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}平板`
              })
            } else if (item.label.indexOf('手表') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}手表`
              })
            } else if (item.label.indexOf('智能穿戴') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}智能穿戴`
              })
            } else if (item.label.indexOf('拍照摄像') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}拍照摄像`
              })
            } else if (item.label.indexOf('无人机') >= 0) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.BRAND_GOODS_PAGE,
                builder: wrapBuilder(BrandDetailPageBuilder),
                param: `${itemDetail.title}无人机`
              })
            }
          },
        })
      }.height('100%').width('100%')
    }.hideToolBar(true).title('全部分类').padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }

  @Builder
  itemBuilder(item: ItemInfo) {
    Column() {
      Image($r(`app.media.${item.imgSrc}`))
        .height(48)
        .width(48)

      Text(item.title)
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 0.85)')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  itemBuilder2(item: ItemInfo) {
    Column() {
      Text(item.title)
        .fontSize(12)
        .fontColor('rgba(0, 0, 0, 1)')
    }
    .height(44)
    .borderRadius(8)
    .backgroundColor('rgba(0, 0, 0, 0.05)')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }


  getProductList(tabItem: CategoryItem) {
    switch (tabItem.id) {
      case '2':
        this.recipeCategoryList = MockData.classList2;
        break;
      case '3':
        this.recipeCategoryList = MockData.classList3;
        break;
      case '4':
        this.recipeCategoryList = MockData.classList4;
        break;
      case '5':
        this.recipeCategoryList = MockData.classList5;
        break;
      case '6':
        this.recipeCategoryList = MockData.classList6;
        break;
      case '7':
        this.recipeCategoryList = MockData.classList7;
        break;
      case '8':
        this.recipeCategoryList = MockData.classList8;
        break;
      default:
        this.recipeCategoryList = [];
        break;
    }
  }

  @Local recipeCategoryList: SubCategoryItem[] = MockData.classList2
  @Local tabList: CategoryItem[] = MockData.tabList
}