import { OHPage, phoneRouterControl } from 'oh_router';
import { BreakpointModel, Constants, RouterMap, TCLogger } from 'common';
import { BrandViewProps, MainPageVM, ProductInfo } from '../viewmodel/MainPageVM';
import { ProductView } from '../components/ProductView';
import { AppraisalView } from '../components/AppraisalView';
import { BrandView } from '../components/BrandView';
import { FilterView } from '../components/FilterView';
import { BrandDetailPageBuilder } from './BrandDetailPage';
import { SearchProductPageBuilder } from './SearchProductPage';
import { ProductCategoryListPageBuilder } from './ProductCategoryListPage';
import { CommonPageVM } from '../viewmodel/CommonPageVM';
import { MockData } from '../data/MockData';
import { RecyclingProcessDialog } from '../components/RecyclingProcessDialog';
import { GridRowColSetting } from 'common/src/main/ets/constant/GridRowColSetting';
import { AppStorageV2 } from '@kit.ArkUI';
import { ProductBrandDetailPageBuilder, JumpType, subPageType } from './ProductBrandDetailPage';
import { MoreBrandProductPageBuilder } from './MoreBrandProductPage';
import { CustomerServiceDialogBuilder } from 'valuation_information';

/**
 * @usage: 首页主页面，展示商品分类、品牌列表、估价入口、商品列表和筛选功能。包含搜索框、Tab 分类切换（全部、手机、平板、笔记本、手表、
 * 智能穿戴、相机、无人机）、品牌宫格展示、估价卡片、商品列表、筛选条件等功能。支持回收流程说明弹窗和客服热线弹窗。
 * @layout: 页面采用垂直布局（Column），顶部为搜索框（包含搜索入口、回收流程按钮、客服热线按钮），下方为 Tabs 组件实现的分类切换，
 * 每个 Tab 内容区包含品牌宫格（Grid 4列）、估价卡片（仅全部分类显示）、商品列表（Grid 2列）和筛选条件（非全部分类显示）。
 * @constraints: fileTypeTitles 数组定义分类标签，不建议修改。品牌列表数据来自 MockData，可根据需求调整。筛选功能仅在非"全部"分类下显示。
 * isFixed 状态控制筛选条件的吸顶效果。
 * @isGen: true
 * @fileType: page
 * @zhName: 首页主页面
 * @subPage: BrandDetailPage,SearchProductPage,ProductCategoryListPage,ProductBrandDetailPage,MoreBrandProductPage
 * @component: ProductView,AppraisalView,BrandView,FilterView,RecyclingProcessDialog
 * @image: screenshots/homepage/mainPage.png
 */

@ComponentV2
export struct MainPage {
  private readonly lotTag: string = 'MainPage';
  // 页面上边距
  private readonly topMargin: number = 20;
  controller: TabsController = new TabsController();
  vm: MainPageVM = MainPageVM.rootInstance;
  @Local breakPointModel: BreakpointModel = AppStorageV2.connect(BreakpointModel, () => new BreakpointModel())!;
  // Grid四列字符串
  @Local gridFourColumnsModel: string = GridRowColSetting.getColumnCountModel(4)
  // Grid双列字符串
  @Local gridTwoColumnsModel: string = GridRowColSetting.getColumnCountModel(2)
  // 是否折叠屏展开状态
  @Local collapseExpandState: boolean = GridRowColSetting.checkColumnCountModel();
  // 屏幕的宽度
  @Local screenWidth: number = 0;

  aboutToAppear(): void {
    // 为每个tab页面添加一个通用VM
    for (let index = 0; index < this.vm.fileTypeTitles.length; index++) {
      const commonVM: CommonPageVM = new CommonPageVM()
      this.vm.commonVMs.push(commonVM)
    }
  }

  @Monitor('breakPointModel.currentBreakpoint')
  breakPointChange() {
    this.gridFourColumnsModel = GridRowColSetting.getColumnCountModel(4)
    this.gridTwoColumnsModel = GridRowColSetting.getColumnCountModel(2)
    this.collapseExpandState = GridRowColSetting.checkColumnCountModel()
  }

  // 搜索框
  @Builder
  searchBar() {
    Row() {
      Row() {
        Row() {
          Image($r('app.media.icon_search'))
            .width(16)
            .height(16)
            .margin({
              left: 15,
              top: 12,
              bottom: 12
            })

          Text('请输入搜索内容')
            .height(21)
            .fontSize(16)
            .fontColor('rgba(0, 0, 0, 0.4)')
            .fontWeight(FontWeight.Regular)
            .textAlign(TextAlign.Center)
            .margin({
              left: 10,
              top: 10,
              bottom: 9
            })

          Blank().layoutWeight(1)

          Image($r('app.media.ic_close'))
            .width(16)
            .height(16)
            .margin({
              top: 15,
              bottom: 15,
              right: 15
            })

        }
        .height(40)
        .layoutWeight(1)
        .borderRadius(20)
        .backgroundColor('rgba(0, 0, 0, 0.05)')
        .onClick(() => {
          phoneRouterControl.jumpPage({
            pageName: RouterMap.GOODS_SEARCH_PAGE,
            builder: wrapBuilder(SearchProductPageBuilder)
          });
        })

        Row() {
          Image($r('app.media.ic_trash_round'))
            .width(24)
            .height(24)
            .margin({ right: 8 })
            .onClick(() => {
              this.vm.showRecycleProcess = true
            })

          Image($r('app.media.ic_help_phone'))
            .width(24)
            .height(24)
            .onClick(() => {
              this.vm.showHotline = true
            })
        }
        .height('100%')
        .margin({
          left: 16,
          right: 16
        })
        .alignItems(VerticalAlign.Center)

      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height(56)
    .padding({
      left: 16,
      top: 8,
      bottom: 8
    })
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .bindSheet($$this.vm.showHotline, this.dealWithHotlineDialog(),
      {
        showClose: false,
        detents: [170],
        preferType: SheetType.BOTTOM,
      })
  }

  @Builder
  dealWithHotlineDialog() {
    CustomerServiceDialogBuilder('客服', '000-****-0000', () => {
      this.vm.showHotline = false
    }, $r('app.media.ic_public_close_sheet'), 170)
  }

  @Builder
  dealWithRecyclingProcessDialog() {
    RecyclingProcessDialog({
      vm: this.vm
    })
  }

  @Builder
  tabBuilder(title: string, index: number) {
    Column() {
      Row() {
        Text(title)
          .fontSize(14)
          .fontColor(this.vm.fileTypeIndex === index ? Color.White : Color.Black)
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor(this.vm.fileTypeIndex === index ? 'rgba(255, 75, 75, 1)' : Color.White)
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
    .margin({ left: index === 0 ? 16 : 0, right: index === this.vm.fileTypeTitles.length - 1 ? 16 : 0 })
    .height(28)
    .width(this.collapseExpandState ? (this.screenWidth - 16) / this.vm.fileTypeTitles.length : 'auto')
    .layoutWeight(this.collapseExpandState ? 1 : 0)
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      if (this.vm.fileTypeIndex === index) {
        return
      }
      this.vm.fileTypeIndex = index;
    })
  }

  // Tab选择布局
  @Builder
  tabSelect() {
    Tabs({ barPosition: BarPosition.Start, controller: this.controller, index: this.vm.fileTypeIndex }) {
      ForEach(this.vm.fileTypeTitles, (item: string, index: number) => {
        TabContent() {
          this.buildTabPage(index, new Scroller(), new Scroller())
        }.tabBar(this.tabBuilder(item, index))
      }, (item: string) => item)
    }
    .width('100%')
    .layoutWeight(1)
    .barHeight(40)
    .barMode(BarMode.Scrollable)
    .onChange((index: number) => {
      this.vm.fileTypeIndex = index;
    })
    .onAreaChange((oldArea, newArea) => {
      this.screenWidth = parseInt(newArea.width.toString())
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

  brandViewClick(index: number, item: BrandViewProps, i: number) {
    if (index === 0) {
      if (i === 7) {
        // 如果是“更多”项，则跳转到多级菜单页面
        phoneRouterControl.jumpPage({
          pageName: RouterMap.MULTI_LEVEL_CATEGORY_PAGE,
          builder: wrapBuilder(ProductCategoryListPageBuilder)
        })
      } else {
        phoneRouterControl.jumpPage({
          pageName: RouterMap.GOODS_TYPE_DETAIL_PAGE,
          builder: wrapBuilder(ProductBrandDetailPageBuilder),
          param: i + 1
        })
      }
    } else {
      subPageType.forEach((subPage: JumpType) => {
        if (index === subPage.index) {
          this.goJump(item, i, subPage)
        }
      })
    }

    // if (index === 1) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}手机`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '手机'
    //     })
    //   }
    // } else if (index === 2) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}平板`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '平板'
    //     })
    //   }
    // } else if (index === 3) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}笔记本`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '笔记本'
    //     })
    //   }
    //
    // } else if (index === 4) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}手表`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '手表'
    //     })
    //   }
    //
    // } else if (index === 5) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}智能穿戴`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '智能穿戴'
    //     })
    //   }
    //
    // } else if (index === 6) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}相机`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '相机'
    //     })
    //   }
    //
    // } else if (index === 7) {
    //   if (i !== 7) {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.BRAND_GOODS_PAGE,
    //       builder: wrapBuilder(BrandDetailPageBuilder),
    //       param: `${item.name}无人机`
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MORE_MODEL_PAGE,
    //       builder: wrapBuilder(MoreBrandProductPageBuilder),
    //       param: '无人机'
    //     })
    //   }
    //
    // } else if (index === 0) {
    //   if (i === 7) {
    //     // 如果是“更多”项，则跳转到多级菜单页面
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.MULTI_LEVEL_CATEGORY_PAGE,
    //       builder: wrapBuilder(ProductCategoryListPageBuilder)
    //     })
    //   } else {
    //     phoneRouterControl.jumpPage({
    //       pageName: RouterMap.GOODS_TYPE_DETAIL_PAGE,
    //       builder: wrapBuilder(ProductBrandDetailPageBuilder),
    //       param: i + 1
    //     })
    //   }
    // }
  }

  @Builder
  buildBand(index: number) {
    Column() {
      Grid() {
        ForEach(this.getBrandList(index), (item: BrandViewProps, i: number) => {
          GridItem() {
            BrandView({
              item: {
                // 品牌图标
                icon: item.icon,
                // 品牌名称
                name: item.name,
              },
              paddingWidth: i === this.getBrandList(index).length - 1 ? 8 : 0
            })
              .onClick(() => {
                this.brandViewClick(index, item, i)
              })
          }
          .width('100%')
          .layoutWeight(1)
        }, (item: BrandViewProps, index: number) => JSON.stringify(item) + index)
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
    .visibility(this.vm.commonVMs[index].isFixed && index !== 0 ? Visibility.None : Visibility.Visible)
  }

  @Builder
  buildProductList(index: number) {
    Column() {
      Grid() {
        ForEach(this.vm.commonVMs[index].getSelectProductList(), (item: ProductInfo, index: number) => {
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
    .margin({ top: 18 })
  }

  @Builder
  buildFilterList(index: number, scroller: Scroller, gridScroller: Scroller) {
    FilterView({
      vm: this.vm.commonVMs[index],
      modelIndex: index,
      isFixed: this.vm.commonVMs[index].isFixed,
      topMargin: 12,
      onchange: (res) => {
      },
      onDrawChange: (res: boolean) => {
        // 筛选条件展开状态
      }
    }) {
      // 商品列表
      Column() {
        Grid(gridScroller) {
          ForEach(this.vm.commonVMs[index].getSelectProductList(), (item: ProductInfo, index: number) => {
            GridItem() {
              ProductView({
                product: item
              })
                .onAreaChange((oldValue: Area, newValue: Area) => {
                  const rows: number = Math.ceil(this.vm.commonVMs[index].getSelectProductList().length /
                    (this.collapseExpandState ? 4 : 2))
                  // 获取内容区域的实际高度
                  this.vm.commonVMs[index].fixedLayoutHeight =
                    parseInt(newValue.height.toString()) * rows + 8 * (rows - 1)
                })
            }
            .width('100%')

          }, (item: ProductInfo, index: number) => JSON.stringify(item) + index)
        }
        .width('100%')
        .columnsTemplate(this.gridTwoColumnsModel)
        .columnsGap(8)
        .rowsGap(8)
        .edgeEffect(this.vm.commonVMs[index].isFixed ? EdgeEffect.Spring : EdgeEffect.None)
        .onScroll((xOffset: number, yOffset: number) => {
          // 如果是“全部”标签下，则不取消滑动
          if (index === 0) {
            return
          }
          const currentYOffset: number = gridScroller.currentOffset().yOffset
          if (currentYOffset < -100) {
            this.vm.commonVMs[index].isFixed = false
            scroller.scrollEdge(Edge.Top)
          }
        })
      }
      .width('100%')
      .layoutWeight(this.vm.commonVMs[index].isFixed ? 1 : 0)
      .padding({
        left: 16,
        right: 16
      })
      .onAreaChange((oldValue: Area, newValue: Area) => {
        // 获取Scroller容器高度
        this.vm.commonVMs[index].fixedListHeight = parseInt(newValue.height.toString())
      })
    }
  }

  @Builder
  buildTabPage(index: number, scroller: Scroller, gridScroller: Scroller) {
    Scroll(scroller) {
      // 样图展示
      Column() {
        // 品牌展示
        this.buildBand(index)

        // 如果是首页，显示估价布局
        if (index === 0) {
          // 估价
          Row() {
            AppraisalView({
              item: {
                // 宝贝名称
                name: '华为 Mart 60 Pro',
                // 宝贝图片
                image: $r('app.media.image_demo_phone3'),
                // 宝贝预估价格
                appraisalPrice: 3210
              }
            })
              .width('100%')
          }
          .width('100%')
          .padding({
            left: 16,
            right: 16
          })
          .margin({
            top: 12
          })
        }

        if (index === 0) {
          // 商品列表
          this.buildProductList(index)
        } else {
          // 筛选条件
          this.buildFilterList(index, scroller, gridScroller)
        }
      }
      .width('100%')
      .onAreaChange((oldValue: Area, newValue: Area) => {
        // 获取内容区域的实际高度
        this.vm.commonVMs[index].containerHeight = parseInt(newValue.height.toString())
      })
    }
    .width('100%')
    .height('100%')
    .align(Alignment.Top)
    .edgeEffect(EdgeEffect.Spring, { alwaysEnabled: false })
    .onAreaChange((oldValue: Area, newValue: Area) => {
      // 获取Scroller容器高度
      this.vm.commonVMs[index].scrollLayoutHeight = parseInt(newValue.height.toString())
    })
    .onScroll((xOffset: number, yOffset: number) => {
      // 如果是“全部”标签下，则不取消滑动
      if (index === 0) {
        return
      }

      const currentYOffset: number = scroller.currentOffset().yOffset
      if (currentYOffset > (this.collapseExpandState ? 70 : 140 + 30)) {
        this.vm.commonVMs[index].isFixed = true
        scroller.scrollEdge(Edge.Top)
      }
    })
    .onTouch((event: TouchEvent) => {
      // 如果是“全部”标签下，则不取消滑动
      if (index === 0) {
        return
      }
      if (!this.vm.commonVMs[index].isFixed || this.vm.commonVMs[index].isScrollable) {
        return
      }
      if (event.type === TouchType.Up) {
        // 如果下滑手势状态，达到阈值，则解除固定
        if (event.touches[0].y - this.vm.commonVMs[index].gestureY > 100 &&
          event.touches[0].x - this.vm.commonVMs[index].gestureX < 50) {
          this.vm.commonVMs[index].isFixed = false
          this.vm.commonVMs[index].gestureX = 0
          this.vm.commonVMs[index].gestureY = 0
        }
      } else if (event.type === TouchType.Down) {
        // 清空手势滑动状态
        this.vm.commonVMs[index].gestureX = event.touches[0].x
        this.vm.commonVMs[index].gestureY = event.touches[0].y
      } else if (event.type === TouchType.Move) {

      }
    })

  }

  @Builder
  render() {
    Column() {
      // 搜索框
      this.searchBar()

      // Tab选择布局
      this.tabSelect()
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .height('100%')
    .padding({ top: Constants.PADDING_7XL })
    .backgroundColor(Color.White)
    .bindSheet($$this.vm.showRecycleProcess, this.dealWithRecyclingProcessDialog(),
      {
        showClose: false,
        height: 448,
        enableOutsideInteractive: false,
        radius: {
          topLeft: 32,
          topRight: 32
        },
        preferType: SheetType.BOTTOM,
      })
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render()
      },
      pageBackgroundColor: $r('sys.color.background_primary')
    })
  }
}
