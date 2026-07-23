import { FilterSelectionItem, ProductCardItem } from 'lib_network';
import { buildCommonEmptyStatus, ProductListSkeleton } from 'lib_widget';
import { GridProductCardView, ListProductCardView } from './ProductFlowCards';
import { ProductWaterFlowVM } from '../viewmodels/ProductWaterFlowVM';
import { SortTypeMap } from '../commons/Enums';
import { WaterFlowScaleUtil } from '../utils/WaterFlowScaleUtil';

@ComponentV2
export struct ProductWaterFlow {
  /** 请求商品列表的接口入参 */
  @Param
  categoryId: string = ''
  @Param
  keyword: string = ''
  @Param
  slotId: string = ''
  @Param
  sortType: SortTypeMap = SortTypeMap.DEFAULT
  @Param
  filterList: FilterSelectionItem[] = []
  /** 是否以宫格模式显示 */
  @Param
  isGrid: boolean = false;
  /** 列表背景色 */
  @Param
  bgColor: ResourceColor = $r('app.color.background_color_grey');
  /** 是否跳转推荐商品轮播 */
  @Param
  openSwiper: boolean = false
  @Event
  handleProductClick: (id: string) => void;
  @Event
  handleBack: () => void;
  private vm: ProductWaterFlowVM = new ProductWaterFlowVM()

  @Monitor('categoryId', 'keyword', 'slotId', 'sortType', 'filterList')
  async refreshList() {
    this.vm.categoryId = this.categoryId;
    this.vm.keyword = this.keyword;
    this.vm.slotId = this.slotId;
    this.vm.sortType = this.sortType;
    this.vm.filterList = this.filterList;
    this.vm.isGrid = this.isGrid;
    await this.vm.refreshList()
  }

  aboutToAppear(): void {
    this.refreshList()
  }

  build() {
    Column() {
      if (this.vm.isLoading && !this.vm.dataList.length) {
        ProductListSkeleton({
          isVertical: this.isGrid,
        })
      } else {
        if (!this.vm.dataList.length) {
          buildCommonEmptyStatus()
        } else {
          WaterFlow({
            scroller: this.vm.scroller,
            footer: this.buildWaterFlowFoot(),
          }) {
            Repeat(this.vm.dataList)
              .each((ri: RepeatItem<ProductCardItem>) => {
                FlowItem() {
                  if (!this.isGrid) {
                    GridProductCardView({ product: ri.item });
                  } else {
                    ListProductCardView({ product: ri.item });
                  }
                }
                .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
                .id(this.vm.testId + '/' + ri.item.productId)
                .onClick(() => {
                  if (this.openSwiper) {
                    this.vm.jumpToSwiperPage(this.vm.testId + '/' + ri.item.productId)
                  } else {
                    this.handleProductClick?.(ri.item.productId);
                  }
                });
              })
          }
          .cachedCount(4)
          .columnsTemplate(this.vm.columnTemplate)
          .columnsGap(12)
          .rowsGap(12)
          .edgeEffect(this.vm.edgeEffect)
          .onReachEnd(() => {
            this.vm.getDataList();
          })
          .onScrollStop(() => {
            this.vm.scrollHeight = this.vm.scroller.currentOffset().yOffset;
            if (this.vm.scrollHeight === 0 && this.vm.startBack) {
              this.handleBack?.();
              this.vm.startBack = false;
            }
          })
          .layoutWeight(1)
          .nestedScroll({
            scrollForward: NestedScrollMode.PARENT_FIRST,
            scrollBackward: NestedScrollMode.SELF_FIRST,
          })
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
          .animation({ duration: 300, curve: Curve.Smooth })
          .gesture(
            PinchGesture({ fingers: 2 })
              .onActionUpdate((event: GestureEvent) => {
                WaterFlowScaleUtil.handlePinchUpdate(event.scale);
              }),
          )

          if (this.vm.showButton) {
            this.buildBackTopButton();
          }
        }
      }
    }
    .backgroundColor(this.bgColor)
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP]);
  }

  @Builder
  buildBackTopButton() {
    if (this.vm.showButton) {
      Image($r('app.media.ic_back_top_button'))
        .width(40)
        .height(40)
        .position(this.vm.backButtonPosition)
        .onClick(() => {
          this.vm.handleBackToTop()
        });
    }
  }

  @Builder
  buildWaterFlowFoot() {
    Row() {
      if (this.vm.dataList.length && this.vm.isLoading) {
        LoadingProgress().width(32);
      } else if (!this.vm.isLoading) {
        Text(this.vm.reachEnd ? '已经到达底部' : '向上滑动加载数据')
          .fontSize(12)
          .fontColor($r('app.color.font_color_level3'));
      }
    }
    .width('100%')
    .constraintSize({ minHeight: 128 })
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Top)
    .padding(16);
  }
}
