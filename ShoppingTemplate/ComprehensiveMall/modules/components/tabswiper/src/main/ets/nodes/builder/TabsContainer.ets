import { TabSwiperContext } from '../../model/TabSwiperContext';
import { TabSwiperRenderUnit, TabLayoutInfo } from '../../model/TabSwiperTypes';
import { CustomNodeConst as Const } from '../../common/Const';

@ComponentV2
struct TabsContainer {

  @Param
  public ctx: TabSwiperContext = new TabSwiperContext();

  /**
   * Tab 的测量受双重约束, 来自父组件的约束和自身约束
   *
   * 1. 来自父组件的约束将被自定义节点接管并重写
   *
   * 2. 自身约束使用 DEFAULT_CONSTRAINT_OPTIONS 表现为无约束, 使测量仅受一重因素影响
   */
  onMeasureSize(_: GeometryInfo, children: Measurable[]): SizeResult {
    if (this.ctx.layoutFlag) {
      this.ctx.layoutFlag = false;
      return this.ctx.tabsContainerSize;
    }
    let totalTabsWidth: number = 0;
    let maxChildrenHeight: number = 0;
    for (let i: number = 0; i < children.length; i++) {
      const result: MeasureResult = children[i].measure(Const.DEFAULT_CONSTRAINT_OPTIONS);
      maxChildrenHeight = maxChildrenHeight > result.height ? maxChildrenHeight : result.height;
      if (i < children.length - 1) {
        totalTabsWidth = totalTabsWidth + result.width;
      }
    }
    const gapCount: number = Math.max(children.length - 2, 0);
    const trackWidth: number = px2vp(this.ctx.lastConstraint?.percentReference.width ?? 0);
    this.ctx.computeTabLayoutData(gapCount, Math.max((trackWidth - totalTabsWidth), 0));
    this.ctx.tabsContainerSize = {
      width: totalTabsWidth + gapCount * this.ctx.tabSpacing + this.ctx.tabStartMargin + this.ctx.tabEndMargin,
      height: Math.max(maxChildrenHeight, this.ctx.attr.tabsContainerMinHeight)
    };
    return this.ctx.tabsContainerSize;
  }

  onPlaceChildren(_: GeometryInfo, children: Layoutable[]): void {
    const tabLayoutInfoList: TabLayoutInfo[] = [];
    if (children.length > 1) {
      let right: number = this.ctx.tabStartMargin;
      for (let i: number = 0; i < children.length - 1; i++) {
        tabLayoutInfoList.push({
          x: right,
          width: children[i].measureResult.width
        });
        children[i].layout({
          x: right,
          y: (this.ctx.tabsContainerSize.height - children[i].measureResult.height) / 2
        });
        right = right + children[i].measureResult.width + this.ctx.tabSpacing;
      }
    }
    this.ctx.tabLayoutInfoList = tabLayoutInfoList;
    this.ctx.computeIndicatorOffsetX(true);
    children[children.length - 1].layout({
      x: this.ctx.indicatorPositionX,
      y: this.ctx.tabsContainerSize.height - children[children.length - 1].measureResult.height
    });
  }

  build() {
    this.buildContainer()
  }

  @Builder
  buildContainer() {
    ForEach(
      this.ctx.attr.viewData,
      (r: TabSwiperRenderUnit, index: number) => {
        Column() {
          r.tab.wrappedBuilder.builder(...r.tab.args)
        }
        .onClick(() => this.ctx.swiperController.changeIndex(index, false))
      },
      (r: TabSwiperRenderUnit) => r.id
    )
    this.buildIndicator() // 将指示器排列在最后, 保证在兄弟组件 Z 序相同的情况下显示在最顶层
  }

  @Builder
  buildIndicator() {
    Column() {
      Column()
        .width(this.ctx.attr.indicatorWidth)
        .height(this.ctx.attr.indicatorHeight)
        .borderRadius(this.ctx.attr.indicatorRadius)
        .backgroundColor(this.ctx.attr.indicatorColor)
        .position({ x: -this.ctx.attr.indicatorWidth / 2, y: -this.ctx.attr.indicatorMarginBottom })
        .translate({ x: this.ctx.attr.indicatorOffsetX })
    }
    .width('1px')
    .height(this.ctx.attr.indicatorHeight)
    .hitTestBehavior(HitTestMode.None)
  }
}

@Builder
export function buildTabsContainer(context: TabSwiperContext) {
  /**
   * TabsContainer 作为自定义组件, 不要设置任何属性, 如 width('auto') 或 id('')
   *
   * 这可能会导致组件树额外生成 __Common__ 节点, 使树结构不符合算法约定
   */
  TabsContainer({ ctx: context })
}
