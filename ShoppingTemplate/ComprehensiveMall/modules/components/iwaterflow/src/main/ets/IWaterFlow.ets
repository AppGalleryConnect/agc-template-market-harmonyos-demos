import { ComponentEntryProxy } from '@common/customtypes';
import { IWaterFlowLogic } from './logic/IWaterFlowLogic';

@ComponentV2
export struct IWaterFlow {

  @Param
  public logic: IWaterFlowLogic = new IWaterFlowLogic();

  @Param
  public template: string = '1fr 1fr';

  @Param
  public columnsGap: number = 10;

  @Param
  public rowsGap: number = 10;

  @Param
  public firstRowTopMargin: number = 0;

  @Param
  public footerPadding: Padding = {};

  @Param
  public color: ResourceColor = Color.Transparent;

  @Local
  private columnCount: number = 0;

  @Local
  private edgeEffect: EdgeEffect = EdgeEffect.None;

  @Monitor('template')
  onTemplateChange(iMonitor: IMonitor): void {
    for (let k of iMonitor.dirty) {
      let v: IMonitorValue<string> | undefined = iMonitor.value<string>(k);
      if (v) {
        this.columnCount = this.logic.calculateColumnCount(v.now);
        break;
      }
    }
  }

  aboutToAppear(): void {
    this.columnCount = this.logic.calculateColumnCount(this.template);
  }

  build(): void {
    if (this.logic.viewData.length !== 0) {
      WaterFlow({
        footer: this.buildFooter(),
        scroller: this.logic.scroller
      }) {
        ForEach(this.logic.viewData, (v: ComponentEntryProxy, index: number) => {
          FlowItem() {
            v.wrappedBuilder.builder(...v.args)
          }
          .margin(index < this.columnCount ? { top: this.firstRowTopMargin } : {})
        })
      }
      .height('100%')
      .columnsTemplate(this.template)
      .columnsGap(this.columnsGap)
      .rowsGap(this.rowsGap)
      .onReachEnd(this.logic.onReachEnd)
      .edgeEffect(this.logic.isEnd ? EdgeEffect.None : this.edgeEffect)
      .onScrollIndex((first: number) => {
        this.edgeEffect = first < this.columnCount ? EdgeEffect.None : EdgeEffect.Spring;
      })
      /**
       * 瀑布流通常在页面的最底部, 因此滚动容器联动方案采用如下设置
       *
       * 1. scrollForward: 在垂直模式下, 手势上划, 内容向上移动时
       *    -> 需要设置为 PARENT_FIRST, 保证外层有 Scroll 或其他滚动容器的情况下, 整个页面一起向上移动
       *    -> 此模式优先触发自身的边缘效果
       *
       * 2. scrollBackward: 在垂直模式下, 手势下划, 内容向下移动时
       *    -> 需要设置为 SELF_FIRST, 保证自身的内容下划完毕后再呈现瀑布流组件之外的内容
       *    -> 此模式优先触发父容器的边缘效果
       */
      .nestedScroll({ scrollForward: NestedScrollMode.PARENT_FIRST, scrollBackward: NestedScrollMode.SELF_FIRST })
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT], [SafeAreaEdge.BOTTOM])
      .backgroundColor(this.color)
    }
  }

  @Builder
  buildFooter() {
    Column() {
      if (this.logic.isEnd) {
        Text('已经到达底部')
          .fontSize(13)
      } else if (this.logic.isLoading) {
        LoadingProgress()
          .width(36)
          .height(36)
      } else {
        Text('向上滑动加载数据')
          .fontSize(13)
      }
    }
    .width('100%')
    .height(170)
    .padding(this.footerPadding)
    .justifyContent(FlexAlign.Start)
  }
}
