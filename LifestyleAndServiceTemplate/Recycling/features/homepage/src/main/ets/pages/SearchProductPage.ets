import { AppStorageV2, LengthMetrics, PersistenceV2, promptAction } from '@kit.ArkUI';
import { NavPageInfo, phoneRouterControl } from 'oh_router';
import { PhoneMediaType, SearchProductPageVM } from '../viewmodel/SearchProductPageVM';
import { SearchProductComponent } from '../components/SearchProductComponent';
import { ProductInfoManager } from '../utils/ProductInfoManager';
import { ProductInfo } from '../viewmodel/MainPageVM';
import { DeleteHistoryListDialog } from '../components/DeleteHistoryListDialog';
import { MockData } from '../data/MockData';
import { BreakpointModel, RouterMap, UserInfo } from 'common';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { OrderParams, SubmitData, ValuationInfoParam } from '../components/valuation/ProductCategoryPage';
import { OrderSubmitPageBuilder } from '../components/valuation/OrderSubmitPage';
import { ValuationInfoHostPageBuilder } from '../components/valuation/ValuationInfoHostPage';
import { LoginPageBuilder } from 'person';

/**
 * @usage: 商品搜索页面，提供搜索输入、历史搜索、热门搜索和搜索结果展示功能，支持按商品类型分类筛选。
 * @layout: 采用垂直布局（Column），顶部为搜索组件，下方为搜索内容区域（历史搜索、热门搜索或搜索结果）。
 * @isGen: true
 * @fileType: page
 * @zhName: 商品搜索页面
 * @subPage: ValuationInfoHostPage,OrderSubmitPage
 * @component: SearchProductComponent,DeleteHistoryListDialog
 * @image: screenshots/homepage/searchProductComponent.png
 */

@Builder
export function SearchProductPageBuilder() {
  SearchProductPage()
}

@Entry
@ComponentV2
struct SearchProductPage {
  @Provider('appPathStack') appPathStack: NavPathStack = new NavPathStack();
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  private searchController: SearchProductPageVM = SearchProductPageVM.instance;
  private controller: TabsController = new TabsController();
  @Local searchKey: string = '';
  @Local textWidth: number = 0;
  // 列表项的宽度
  @Local listItemWidth: number = 0
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();
  // 屏幕的宽度
  @Local screenWidth: number = 0;
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  build() {
    NavDestination() {
      Column() {
        SearchProductComponent({
          appPathStack: this.appPathStack,
          hotSearchBuilder: this.hotSearch.bind(this),
          historySearchBuilder: this.historySearch.bind(this),
          searchResultBuilder: this.searchResult.bind(this),
          getSearchResult: this.getSearchResult.bind(this),
          phoneSelectBuilder: this.phoneMediaSearch.bind(this),
          photoSelectBuilder: this.cameraMediaSearch.bind(this),
          watchSelectBuilder: this.watchMediaSearch.bind(this),
          backFunc: () => {
            if (this.searchController.searchCondition) {
              this.searchController.isShowResult = false;
              this.searchController.searchCondition = ''
            } else {
              phoneRouterControl.popPage()
            }

          }
        });
      }
      .width('100%')
      .height('100%')
      .margin({ top: 20 })
    }
    .hideTitleBar(true)
    .hideToolBar(true)
    .onBackPressed(() => {
      if (this.searchController.searchCondition) {
        this.searchController.isShowResult = false;
        this.searchController.searchCondition = ''
      } else {
        phoneRouterControl.popPage()
      }
      return true;
    })
  }

  @Builder
  hotSearch() {
    Column() {
      Row() {
        Text('热门搜索').fontSize(14).fontColor('rgba(0,0,0,0.90)');
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
        ForEach(this.searchController.hotSearch, (item: string) => {
          Text(item)
            .labelBaseStyle()
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchResult();
            });
        }, (item: string, index) => item + index.toString());
      };
    };
  }

  @Builder
  historySearch() {
    Column() {
      Row() {
        Text('历史搜索').fontSize(14).fontColor('rgba(0,0,0,0.90)');

        Blank();

        Row() {
          Image($r('app.media.ic_trash_btn'))
            .width(24)
            .height(24)

          Text('清空').fontSize(14).fontColor('rgba(0, 0, 0, 0.6)').lineHeight(15).margin({ left: 4 })
        }
        .alignItems(VerticalAlign.Center)
        .margin({ right: 16 })
        .onClick(() => {
          promptAction.openCustomDialog({
            builder: () => {
              this.deleteDialog()
            },
            alignment: DialogAlignment.Center,
            width: '90%'
          }).then((id) => {
            this.searchController.deleteDialogId = id
          })
        });

      }.justifyContent(FlexAlign.SpaceBetween).width('100%');

      if (this.searchController.historySearch.length > 0) {
        Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(8), cross: LengthMetrics.vp(8) } }) {
          ForEach(this.searchController.historySearch, (item: string, index: number) => {
            Row() {
              Text(item)
                .height(15)
                .fontSize(12)
                .fontColor('rgba(25, 25, 25, 1)')

              Image($r('app.media.ic_close_btn'))
                .width(16)
                .height(16)
                .margin({ left: 8 })
                .onClick(() => {
                  this.searchController.historySearch.splice(index, 1);
                });
            }
            .alignItems(VerticalAlign.Center)
            .padding({
              top: 6,
              bottom: 6,
              left: 12,
              right: 8,
            })
            .borderRadius(14)
            .backgroundColor('rgba(0, 0, 0, 0.05)')
            .focusable(true)
            .focusOnTouch(true)
            .onClick(() => {
              this.searchController.searchCondition = item;
              this.searchController.isShowResult = true;
              this.searchController.updateHistorySearch(item);
              this.getSearchResult();
            });

          }, (item: string, index) => item + index.toString());
        }.margin({ top: 10 })
      } else {
        Row() {
          Text('暂无历史搜索').fontSize(14).fontColor('rgba(102, 102, 102, 1)')
            .margin({ top: 14 })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
      }

    }
    .padding({
      bottom: px2vp(AppStorage.get('bottomRectHeight')),
    });
  }

  // 手机数码
  @Builder
  phoneMediaSearch() {
    Column() {
      Row() {
        Text('手机数码').fontSize(14).fontColor('rgba(0,0,0,0.90)');
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      // 横向列表
      Row() {
        List({ space: 8 }) {
          ForEach(this.searchController.phoneSelectDevices, (item: PhoneMediaType, index: number) => {
            ListItem() {
              Column() {
                Image(item.image)
                  .width(50)
                  .height(50)
                  .margin({ top: 10 })

                Text(item.name)
                  .fontSize(10)
                  .lineHeight(15)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4, bottom: 6 })
                  .fontColor('rgba(0, 0, 0, 0.9)')

              }
              .width(74)
              .height(84)
              .borderRadius(8)
              .alignItems(HorizontalAlign.Center)
              .borderWidth(1)
              .borderColor('rgba(232, 235, 237, 1)')
            }.width(74).height(84)
          }, (item: PhoneMediaType, index: number) => JSON.stringify(item) + index)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }.width('100%').height(84)
    };
  }

  // 摄影摄像
  @Builder
  cameraMediaSearch() {
    Column() {
      Row() {
        Text('摄影摄像').fontSize(14).fontColor('rgba(0,0,0,0.90)');
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      // 横向列表
      Row() {
        List({ space: 8 }) {
          ForEach(this.searchController.photoSelectDevices, (item: PhoneMediaType, index: number) => {
            ListItem() {
              Column() {
                Image(item.image)
                  .width(50)
                  .height(50)
                  .margin({ top: 10 })

                Text(item.name)
                  .fontSize(10)
                  .lineHeight(15)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4, bottom: 6 })
                  .fontColor('rgba(0, 0, 0, 0.9)')

              }
              .width(74)
              .height(84)
              .borderRadius(8)
              .alignItems(HorizontalAlign.Center)
              .borderWidth(1)
              .borderColor('rgba(232, 235, 237, 1)')
            }.width(74).height(84)
          }, (item: PhoneMediaType, index: number) => JSON.stringify(item) + index)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }.width('100%').height(84)
    };
  }

  // 腕表
  @Builder
  watchMediaSearch() {
    Column() {
      Row() {
        Text('腕表').fontSize(14).fontColor('rgba(0,0,0,0.90)');
      }.justifyContent(FlexAlign.SpaceBetween).margin({ bottom: 12 }).width('100%');

      // 横向列表
      Row() {
        List({ space: 8 }) {
          ForEach(this.searchController.watchSelectDevices, (item: PhoneMediaType, index: number) => {
            ListItem() {
              Column() {
                Image(item.image)
                  .width(50)
                  .height(50)
                  .margin({ top: 10 })

                Text(item.name)
                  .fontSize(10)
                  .lineHeight(15)
                  .textAlign(TextAlign.Center)
                  .margin({ top: 4, bottom: 6 })
                  .fontColor('rgba(0, 0, 0, 0.9)')

              }
              .width(74)
              .height(84)
              .borderRadius(8)
              .alignItems(HorizontalAlign.Center)
              .borderWidth(1)
              .borderColor('rgba(232, 235, 237, 1)')
            }.width(74).height(84)
          }, (item: PhoneMediaType, index: number) => JSON.stringify(item) + index)
        }
        .listDirection(Axis.Horizontal)
        .scrollBar(BarState.Off)
      }.width('100%').height(84)
    };
  }

  @Builder
  deleteDialog() {
    DeleteHistoryListDialog({
      onDeleted: () => {
        this.searchController.historySearch = [];
        promptAction.closeCustomDialog(this.searchController.deleteDialogId)
      },
      onCanceled: () => {
        promptAction.closeCustomDialog(this.searchController.deleteDialogId)
      }
    })
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column() {
      Row() {
        Text(title)
          .fontSize(14)
          .fontColor(this.searchController.fileTypeIndex === index ? Color.White : Color.Black)
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor(this.searchController.fileTypeIndex === index ? 'rgba(255, 75, 75, 1)' : Color.White)
      .borderRadius(20)
      .padding({
        top: 4,
        bottom: 4,
        left: 8,
        right: 8
      })
      .width(this.collapseExpandState ? '100%' : 'auto')
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .margin({ left: index === 0 ? 16 : 0 })
    .height(28)
    .width(this.collapseExpandState ? (this.screenWidth - 16) / this.searchController.fileTypeTitles.length : 'auto')
    .layoutWeight(this.collapseExpandState ? 1 : 0)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.searchController.fileTypeIndex === index) {
        return
      }
      this.searchController.fileTypeIndex = index;
    })
  }

  @Builder
  searchResult() {
    Column() {
      if (this.searchController.searchResult.productList.length === 0) {
        Image($r('app.media.ic_no_search_result_found'))
          .width(120)
          .height(120)
          .margin({
            top: 120
          })

        Text('暂时没有搜索到您要找的内容呢')
          .fontSize(14)
          .fontColor('rgba(0,0,0,0.40)')
      } else {
        Column() {
          Tabs({
            barPosition: BarPosition.Start,
            controller: this.controller,
            index: this.searchController.fileTypeIndex
          }) {
            ForEach(this.searchController.fileTypeTitles, (item: string, index: number) => {
              TabContent() {
                Column() {
                  // 搜索结果
                  Text('搜索结果')
                    .fontSize(16)
                    .fontColor('rgba(0, 0, 0, 0.9)')
                    .margin({ left: 16, top: 16, bottom: 12 })
                  if (this.getSearchResultByFileType().length === 0) {
                    Column() {
                      Image($r('app.media.ic_no_search_result_found'))
                        .width(120)
                        .height(120)
                        .margin({
                          top: 120
                        })

                      Text('暂时没有搜索到您要找的内容呢')
                        .fontSize(14)
                        .fontColor('rgba(0,0,0,0.40)')
                    }
                    .width('100%')
                    .alignItems(HorizontalAlign.Center)
                    .justifyContent(FlexAlign.Center)

                  } else {
                    // 结果展示
                    List() {
                      ForEach(this.getSearchResultByFileType(), (item: ProductInfo, i: number) => {
                        ListItem() {
                          this.buildProductInfoItem(item)
                        }
                      }, (item: ProductInfo, index: number) => JSON.stringify(item) + index)
                    }
                    .padding({ bottom: 16 })
                    .layoutWeight(1)
                    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
                  }

                }
                .width('100%')
                .height('100%')
                .alignItems(HorizontalAlign.Start)

              }.tabBar(this.tabBuilder(item, index))
            }, (item: string) => item)
          }
          .width('100%')
          .layoutWeight(1)
          .barHeight(40)
          .barMode(BarMode.Scrollable)
          .onChange((index: number) => {
            this.searchController.fileTypeIndex = index;
          })
        }.onAreaChange((oldArea, newArea) => {
          this.screenWidth = parseInt(newArea.width.toString())
        });
      }

    }
    .layoutWeight(1);
  }

  // 商品列表
  @Builder
  buildProductInfoItem(item: ProductInfo) {
    Row() {
      // 商品图片
      Image(item.image)
        .width(80)
        .height(80)
        .borderRadius(8)

      Column() {
        // 价格描述
        RelativeContainer() {
          Image($r('app.media.ic_new_99'))
            .width(18)
            .height(10)
            .alignRules({
              top: { anchor: '__container__', align: VerticalAlign.Top },
              left: { anchor: '__container__', align: HorizontalAlign.Start }
            })
            .margin({ top: 2 })

          Text(item.name)
            .fontSize(14)
            .fontColor('rgba(0, 0, 0, 0.6)')
            .fontWeight(FontWeight.Regular)
            .textIndent(24)
            .maxLines(2)
            .lineHeight(14)
            .margin({ right: 16 })

        }.height(32)

        // 价格描述
        Row() {
          Text('¥')
            .fontSize(10)
            .fontColor('rgba(0, 0, 0, 0.85)')
            .fontWeight(FontWeight.Regular)
            .margin({
              top: 4
            })

          Text(item.price.toString())
            .height('100%')
            .fontSize(16)
            .fontColor('rgba(0, 0, 0, 0.85)')
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .margin({
              left: 1
            })
        }
        .height(19)
        .margin({
          top: 8
        })
      }
      .alignItems(HorizontalAlign.Start)
      .height(80)
      .justifyContent(FlexAlign.Start)
      .layoutWeight(1)
      .margin({ left: 16 })
    }
    .width('100%')
    .padding({ left: 17, right: 16 })
    .margin({ bottom: 16 })
    .onClick(() => {
      if (!this.userInfo.isLogin) {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.LOGIN_PAGE,
          builder: wrapBuilder(LoginPageBuilder)
        })
        return
      }
      const dev: string = item.labels === '手机' ? 'phone' : 'computer'
      const params: ValuationInfoParam = {
        modelName: item.name,
        imageSrc: item.image,
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

  getSearchResult() {
    // 将所有的类型商品整合成新的商品列表
    const allProductList: ProductInfo[] = MockData.phoneProductList.concat(MockData.padProductList)
      .concat(MockData.notebookProductList)
      .concat(MockData.watchProductList)
      .concat(MockData.iWatchProductList)
      .concat(MockData.cameraProductList)
      .concat(MockData.noPersonProductList)
    this.searchController.searchResult = new ProductInfoManager('搜索结果',
      allProductList.filter(item => item.name.toLowerCase()
        .includes(this.searchController.searchCondition.toLowerCase()) ||
      item.labels.includes(this.searchController.searchCondition)))
    // 重新定位到全部的tab
    this.searchController.fileTypeIndex = 0
  }

  // 根据当前的tab显示结果
  getSearchResultByFileType(): ProductInfo[] {
    if (this.searchController.fileTypeIndex === 0) {
      return this.searchController.searchResult.productList
    } else if (this.searchController.fileTypeIndex === 1) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '手机')
    } else if (this.searchController.fileTypeIndex === 2) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '平板')
    } else if (this.searchController.fileTypeIndex === 3) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '笔记本')
    } else if (this.searchController.fileTypeIndex === 4) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '手表')
    } else if (this.searchController.fileTypeIndex === 5) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '智能穿戴')
    } else if (this.searchController.fileTypeIndex === 6) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '拍照摄像')
    } else if (this.searchController.fileTypeIndex === 7) {
      return this.searchController.searchResult.productList.filter(item => item.labels === '无人机')
    }
    return []
  }
}

@Extend(Text)
function labelBaseStyle() {
  .padding({
    top: 6,
    bottom: 6,
    left: 12,
    right: 12,
  })
  .fontSize(12)
  .borderRadius(15)
  .fontColor('rgba(25, 25, 25, 1)')
  .backgroundColor('rgba(0, 0, 0, 0.05)')
  .focusable(true)
  .focusOnTouch(true);
}