import { CategoryItem, SubCategoryItem, ItemInfo, LayoutType } from 'category_list'
import { CategoryListView } from '../CategoryListView'
import { Constants } from 'common'
import { ValuationInfoHostPageBuilder } from './ValuationInfoHostPage'
import { OrderSubmitPageBuilder } from './OrderSubmitPage'
import { phoneRouterControl, NavPageInfo } from 'oh_router'
import { RouterMap } from 'common'

/**
 * @usage: 商品分类页面，展示全部、手机、平板、笔记本等分类标签，点击分类显示对应品牌列表，点击品牌弹出热卖型号面板
 * @layout: 页面采用 Stack 布局，底层是分类列表视图（CategoryListView），上层是可滑入的热卖型号面板
 * @constraints: 分类标签列表 tabList 包含 8 个固定分类，热卖型号面板从右侧滑入
 * @isGen: true
 * @fileType: page
 * @zhName: 商品分类页面
 * @subPage: ValuationInfoHostPage,OrderSubmitPage
 * @component: CategoryListView
 * @image: screenshots/homepage/productCategory.png
 */

interface SelectionPair {
  title: string;
  value: string
}

export interface OrderParams {
  modelName: string;
  imageSrc: ResourceStr;
  deviceType?: string;
  price?: number;
  selections?: SelectionPair[]
}

interface ProductCategoryParam { initIndex: number }

export interface SubmitData {
  modelName: string;
  imageSrc: ResourceStr;
  deviceType: string;
  price: number;
  selections: SelectionPair[]
}

export interface ValuationInfoParam {
  modelName: string;
  imageSrc: ResourceStr;
  deviceType?: string;
  onBack?: () => void;
  onSubmit?: (data: SubmitData) => void
}

@Builder
export function ProductCategoryPageBuilder(params: object) {
  ProductCategoryPage(params as ProductCategoryParam)
}

@ComponentV2
export struct ProductCategoryPage {
  @Param initIndex: number = 1
  @Local currentIndex: number = this.initIndex
  @Local themeColor: ResourceColor = 'rgba(255, 75, 75, 1)'
  @Local productList: SubCategoryItem[] = []
  @Local layoutType: LayoutType = LayoutType.GRID
  @Local showRightPanel: boolean = false
  @Local panelTranslateX: number = 360
  @Local hotModelItems: SubCategoryItem[] = []
  @Local currentDeviceType: string = 'phone'

  aboutToAppear(): void {
    this.switchData(this.tabList[this.currentIndex])
  }

  build() {
    NavDestination() {
      Stack() {
        Column() {
          CategoryListView({
            categoryTabs: this.tabList,
            productList: this.productList,
            initIndex: this.currentIndex,
            layoutType: this.layoutType,
            themeColor: this.themeColor,
            tabBarScroller: new Scroller(),
            subBarScroller: new Scroller(),
            scroller: new Scroller(),
            itemBuilderParam: this.itemBuilder,
            onTabClick: (tabItem: CategoryItem) => {
              this.switchData(tabItem)
            },
            onItemClick: (item: ItemInfo) => {
              if (this.layoutType === LayoutType.GRID) {
                this.openPanel()
              }
            },
          })
        }.height('100%').width('100%')

        if (this.showRightPanel) {
          Row() {
            // 左侧竖条提示：点击返回
            Column({ space: 2 }) {
              Image($r('app.media.img_vertical_back'))
                .width(18)
                .height(18)
              Text('点').fontSize(12).fontColor('#FFFFFF')
              Text('击').fontSize(12).fontColor('#FFFFFF')
              Text('返').fontSize(12).fontColor('#FFFFFF')
              Text('回').fontSize(12).fontColor('#FFFFFF')
            }
            .width('14%')
            .height('100%')
            .justifyContent(FlexAlign.Center)
            .backgroundColor('rgba(0,0,0,0.6)')
            .onClick(() => {
              this.closePanel()
            })

            // 右侧面板内容：热卖型号列表
            Column({ space: 12 }) {
              Text('热卖型号')
                .fontSize(16)
                .fontWeight(FontWeight.Medium)
                .fontColor('rgba(0,0,0,1)')
                .margin({ top: 12 })
                .padding({ left: 16 })
                .width('100%')
                .textAlign(TextAlign.Start)
              List() {
                ForEach(this.hotModelItems.length > 0 ? this.hotModelItems[0].itemList : [],
                  (gridItem: ItemInfo, idx: number) => {
                    ListItem() {
                      Row() {
                        // 左侧缩略图卡片
                        Row() {
                          Image(gridItem.imgSrc)
                            .width(44)
                            .height(44)
                            .objectFit(ImageFit.Cover)
                            .borderRadius(8)
                        }
                        .width(56)
                        .height(56)
                        .justifyContent(FlexAlign.Center)
                        .alignItems(VerticalAlign.Center)
                        .backgroundColor('rgba(0,0,0,0.05)')
                        .borderRadius(8)

                        Text(gridItem.title)
                          .fontSize(14)
                          .fontWeight(FontWeight.Regular)
                          .fontColor('rgba(0,0,0,0.95)')
                          .margin({ left: 12 })
                      }
                      .height(64)
                      .alignItems(VerticalAlign.Center)
                      .padding({ left: 16, right: 16 })
                      .onClick(() => {
                        const dev: string = this.currentDeviceType
                        const params: ValuationInfoParam = {
                          modelName: gridItem.title,
                          imageSrc: gridItem.imgSrc?? '',
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
                      })
                    }
                  }, (gridItem: ItemInfo, idx: number) => JSON.stringify(gridItem) + idx)
              }
              .lanes(1)
              .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
              .width('100%')
              .divider({ strokeWidth: 0, color: Color.Transparent })
            }
            .width('86%')
            .height('100%')
            .backgroundColor(Color.White)
            .shadow({
              radius: 12,
              color: 'rgba(0,0,0,0.15)',
              offsetX: -2,
              offsetY: 0
            })
          }
          .height('100%')
          .width('100%')
          .justifyContent(FlexAlign.End)
          .translate({ x: this.panelTranslateX })
        }
      }
    }.hideToolBar(true).title('全部分类').padding({ top: Constants.PADDING_7XL })
    .onBackPressed(() => {
      phoneRouterControl.popPage()
      return true
    })
  }

  @Builder
  itemBuilder(item: ItemInfo) {
    Column() {
      Image(item.imgSrc)
        .height(48)
        .width(48)

      Text(item.title)
        .fontSize(10)
        .fontColor('rgba(0, 0, 0, 0.85)')
        .margin({ top: 2 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }

  switchData(tabItem: CategoryItem) {
    if (tabItem.id === '1') {
      this.productList = this.listBrands
      this.layoutType = LayoutType.GRID
      this.currentDeviceType = 'phone'
      this.hotModelItems = this.listPhoneModels
      this.showRightPanel = false
    } else if (tabItem.id === '2') {
      this.hotModelItems = this.listPhoneModels
      this.currentDeviceType = 'phone'
      this.productList = this.listBrands
      this.layoutType = LayoutType.GRID
      this.showRightPanel = false
    } else {
      if (tabItem.id === '4') {
        this.hotModelItems = this.listComputerModels
        this.currentDeviceType = 'computer'
        this.productList = this.listBrands
        this.layoutType = LayoutType.GRID
        this.showRightPanel = false
      } else {
        this.showRightPanel = false
        this.productList = this.listBrands
        this.layoutType = LayoutType.GRID
      }
    }
  }

  openPanel(): void {
    this.showRightPanel = true
    this.panelTranslateX = 360
    animateTo({ duration: 250, curve: Curve.EaseOut }, () => {
      this.panelTranslateX = 0
    })
  }

  closePanel(): void {
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.panelTranslateX = 360
    })
    setTimeout(() => {
      this.showRightPanel = false
    }, 200)
  }

  @Local listPhoneModels: SubCategoryItem[] = [{
    id: 'p1', label: '热卖型号', itemList: [
      { id: 'm1', title: 'HUAWEI Pura 80 Pro', imgSrc: $r('app.media.image_demo_phone3') },
      { id: 'm2', title: 'HUAWEI Pura 80', imgSrc: $r('app.media.image_demo_phone2') },
      { id: 'm3', title: 'HUAWEI Pura 70 Pro', imgSrc: $r('app.media.image_demo_phone3') },
      { id: 'm4', title: 'HUAWEI Pura 70', imgSrc: $r('app.media.image_demo_phone2') },
      { id: 'm5', title: 'HUAWEI Mate 80 Pro', imgSrc: $r('app.media.image_demo_phone3') },
      { id: 'm6', title: 'HUAWEI Mate 80', imgSrc: $r('app.media.image_demo_phone2') },
      { id: 'm7', title: 'HUAWEI Mate 70 Pro', imgSrc: $r('app.media.image_demo_phone3') },
      { id: 'm8', title: 'HUAWEI Mate 70', imgSrc: $r('app.media.image_demo_phone2') },
    ]
  }]
  @Local listComputerModels: SubCategoryItem[] = [{
    id: 'c1', label: '热卖型号', itemList: [
      { id: 'c1', title: 'HUAWEI MateBook X Pro', imgSrc: $r('app.media.img_demo_notebookA') },
      { id: 'c2', title: 'HUAWEI MateBook 14', imgSrc: $r('app.media.img_demo_notebookB') },
      { id: 'c3', title: 'HUAWEI MateBook 16s', imgSrc: $r('app.media.img_demo_notebookA') },
      { id: 'c4', title: 'HUAWEI MateBook D 14', imgSrc: $r('app.media.img_demo_notebookB') },
      { id: 'c5', title: 'HUAWEI MateBook D 15', imgSrc: $r('app.media.img_demo_notebookA') },
      { id: 'c6', title: 'HUAWEI MateBook E', imgSrc: $r('app.media.img_demo_notebookB') },
      { id: 'c7', title: 'HUAWEI MateBook 13', imgSrc: $r('app.media.img_demo_notebookA') },
      { id: 'c8', title: 'HUAWEI MateBook 15', imgSrc: $r('app.media.img_demo_notebookB') },
    ]
  }]
  @Local listBrands: SubCategoryItem[] = [{
    id: 'b1', label: '热卖品牌', itemList: [
      { id: 'b1', title: '华为', imgSrc: $r('app.media.img_huawei') },
      { id: 'b2', title: '品牌1', imgSrc: $r('app.media.img_huawei') },
      { id: 'b3', title: '品牌2', imgSrc: $r('app.media.img_huawei') },
      { id: 'b4', title: '品牌3', imgSrc: $r('app.media.img_huawei') },
      { id: 'b5', title: '品牌4', imgSrc: $r('app.media.img_huawei') },
      { id: 'b6', title: '品牌5', imgSrc: $r('app.media.img_huawei') },
      { id: 'b7', title: '品牌6', imgSrc: $r('app.media.img_huawei') },
      { id: 'b8', title: '品牌7', imgSrc: $r('app.media.img_huawei') },
      { id: 'b9', title: '品牌8', imgSrc: $r('app.media.img_huawei') },
    ]
  }]
  @Local tabList: CategoryItem[] = [
    { id: '1', label: '全部', iconUrl: '' },
    { id: '2', label: '手机', iconUrl: '' },
    { id: '3', label: '平板', iconUrl: '' },
    { id: '4', label: '笔记本', iconUrl: '' },
    { id: '5', label: '手表', iconUrl: '' },
    { id: '6', label: '智能穿戴', iconUrl: '' },
    { id: '7', label: '拍照摄像', iconUrl: '' },
    { id: '8', label: '无人机', iconUrl: '' },
  ]
}
