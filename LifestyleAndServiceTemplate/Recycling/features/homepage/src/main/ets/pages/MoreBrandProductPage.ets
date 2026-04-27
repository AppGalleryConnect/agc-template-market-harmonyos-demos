import { Constants, UserInfo } from 'common';
import { CategoryItem, SubCategoryItem, ItemInfo, LayoutType } from 'category_list';
import { RouterMap } from 'common';
import { NavPageInfo, phoneRouterControl } from 'oh_router';
import { CategoryListView } from '../components/CategoryListView';
import { OrderSubmitPageBuilder } from '../components/valuation/OrderSubmitPage';
import { OrderParams, SubmitData, ValuationInfoParam } from '../components/valuation/ProductCategoryPage';
import { ValuationInfoHostPageBuilder } from '../components/valuation/ValuationInfoHostPage';
import { MockData } from '../data/MockData';
import { LoginPageBuilder } from 'person';
import { PersistenceV2 } from '@kit.ArkUI';

@Builder
export function MoreBrandProductPageBuilder(param: Object) {
  MoreBrandProductPage({ category: param as string })
}

@Entry
@ComponentV2
struct MoreBrandProductPage {
  @Local currentIndex: number = 0
  @Local themeColor: ResourceColor = 'rgba(255, 75, 75, 1)'
  // 类别
  @Param category: string = '手机'
  @Local recipeCategoryList: SubCategoryItem[] = []
  @Local tabList: CategoryItem[] = MockData.phoneBrandTabList
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  aboutToAppear(): void {
    this.refreshCategoryList()
  }

  // 重新刷新商品列表
  refreshCategoryList() {
    if (this.category === '手机') {
      this.recipeCategoryList = [...MockData.phoneList1.concat(MockData.phoneList2)]
      this.tabList = MockData.phoneBrandTabList
    } else if (this.category === '平板') {
      this.recipeCategoryList = [...MockData.padList1.concat(MockData.padList2)]
      this.tabList = MockData.padBrandTabList
    } else if (this.category === '笔记本') {
      this.recipeCategoryList = [...MockData.notebookList1.concat(MockData.notebookList2)]
      this.tabList = MockData.notebookBrandTabList
    } else if (this.category === '手表') {
      this.recipeCategoryList = [...MockData.watchList1.concat(MockData.watchList2)]
      this.tabList = MockData.watchBrandTabList
    } else if (this.category === '智能穿戴') {
      this.recipeCategoryList = [...MockData.iWatchList1.concat(MockData.iWatchList2)]
      this.tabList = MockData.iWatchBrandTabList
    } else if (this.category === '相机') {
      this.recipeCategoryList = [...MockData.cameraProductList1.concat(MockData.cameraProductList2)]
      this.tabList = MockData.cameraBrandTabList
    } else if (this.category === '无人机') {
      this.recipeCategoryList = [...MockData.noPersonProductList1.concat(MockData.noPersonProductList2)]
      this.tabList = MockData.noPersonBrandTabList
    }
    // 重置列表标题
    this.recipeCategoryList.forEach((item: SubCategoryItem) => {
      item.label =
        `${this.category === '手表' ? '品牌1' : '华为'}${this.category}${item.label.split(this.category)[1]}`
    })
  }

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
            if (!this.userInfo.isLogin) {
              phoneRouterControl.jumpPage({
                pageName: RouterMap.LOGIN_PAGE,
                builder: wrapBuilder(LoginPageBuilder)
              })
              return
            }
            const dev: string = this.category === '手机' ? 'phone' : 'computer'
            const params: ValuationInfoParam = {
              modelName: itemDetail.title,
              imageSrc: $r(`app.media.${itemDetail.imgSrc}`)?? '',
              deviceType: dev,
              onBack: () => phoneRouterControl.popPage(),
              onSubmit: (data: SubmitData) => {
                const orderParam: OrderParams = {
                  modelName: data.modelName,
                  imageSrc: data.imageSrc,
                  deviceType: data.deviceType,
                  price: data.price,
                  selections: data.selections
                }
                const orderPage: NavPageInfo = {
                  pageName: RouterMap.VALUATION_ORDER_PAGE,
                  builder: wrapBuilder(OrderSubmitPageBuilder),
                  param: orderParam
                }
                phoneRouterControl.jumpPage(orderPage)
              }
            }
            const pageInfo: NavPageInfo = {
              pageName: RouterMap.VALUATION_INFORMATION_PAGE,
              builder: wrapBuilder(ValuationInfoHostPageBuilder),
              param: params
            }
            phoneRouterControl.jumpPage(pageInfo)
          },
        })
      }.height('100%').width('100%')
    }.hideToolBar(true).title('更多').padding({ top: Constants.PADDING_7XL })
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
    this.refreshCategoryList()
    this.recipeCategoryList = this.getProductListTitle(tabItem.id);
  }

  // 修改商品列表的标题显示
  getProductListTitle(index: string): SubCategoryItem[] {
    const list = this.recipeCategoryList.filter((item: SubCategoryItem) => true)
    if ('2' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌1' : '华为'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('3' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌2' : '品牌1'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('4' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌3' : '品牌2'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('5' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌4' : '品牌3'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('6' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌5' : '品牌4'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('7' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌6' : '品牌5'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('8' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌7' : '品牌6'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('9' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌8' : '品牌7'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('10' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌9' : '品牌8'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('11' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌10' : '品牌9'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('12' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌11' : '品牌10'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('13' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌12' : '品牌11'}${this.category}${item.label.split(this.category)[1]}`
      })
    } else if ('14' === index) {
      list.forEach((item: SubCategoryItem) => {
        item.label =
          `${this.category === '手表' ? '品牌13' : '品牌12'}${this.category}${item.label.split(this.category)[1]}`
      })
    }
    return list
  }
}