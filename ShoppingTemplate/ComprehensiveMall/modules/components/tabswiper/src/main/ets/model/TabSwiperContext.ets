import { LayoutConstraint } from '@ohos.arkui.node';

import { TabSwiperAttribute } from './TabSwiperAttribute';
import { TabLayoutInfo, IndicatorMoveStatus } from './TabSwiperTypes';

export class TabSwiperContext {

  // TabSwiper 中需要跨组件共享的, 状态变量性质的属性
  public attr: TabSwiperAttribute = new TabSwiperAttribute();

  public swiperController: SwiperController = new SwiperController();

  // 上一次测量 TabsContainer 时使用的布局约束
  public lastConstraint: LayoutConstraint | null = null;

  /**
   * 在自定义节点的 onMeasure 方法中对 TabsContainer 调用 setNeedsLayout 之前，
   * 需要先发起一次试探性的测量，如果 flag 被更改，说明测量成功触发，无需调用 setNeedsLayout 强行附加标记。
   */
  public layoutFlag: boolean = false;

  // Tab 与行首的距离
  public tabStartMargin: number = 0;

  // Tab 与 Tab 的距离
  public tabSpacing: number = 0;

  // Tab 与行尾的距离
  public tabEndMargin: number = 0;

  // TabsContainer 的大小
  public tabsContainerSize: SizeResult = { width: 0, height: 0 };

  // 页签布局信息表
  public tabLayoutInfoList: TabLayoutInfo[] = [];

  public indicatorMoveStatus: IndicatorMoveStatus = {
    from: 0,
    to: 0,
    progress: 1
  };

  // 指示器在页签容器中的位置
  public indicatorPositionX: number = 0;

  /**
   * 计算页签布局相关数据
   *
   * @param gapCount    页签之间的间隔数量
   * @param block       当前空白
   * @param baseSpacing 间距基准值
   */
  public computeTabLayoutData = (gapCount: number, block: number): void => {
    const update = (spacing: number, start: number, end: number): void => {
      this.tabSpacing = spacing;
      this.tabStartMargin = start;
      this.tabEndMargin = end;
    };
    let calcSpacing: number = 0;
    const baseSpacing: number = Math.max(this.attr.tabSpacingBase, 0);
    switch (this.attr.tabLayoutMode) {
      case 'SpaceBetween':
        calcSpacing = gapCount > 0 ? Math.max(block / gapCount, baseSpacing) : baseSpacing;
        update(calcSpacing, 0, 0);
        break;
      case 'SpaceAround':
        calcSpacing = Math.max(block / (gapCount + 1), baseSpacing);
        update(calcSpacing, calcSpacing / 2, calcSpacing / 2);
        break;
      case 'SpaceEvenly':
        calcSpacing = Math.max(block / (gapCount + 2), baseSpacing);
        update(calcSpacing, calcSpacing, calcSpacing);
        break;
      case 'Start':
        calcSpacing = Math.max((block - baseSpacing * gapCount), 0);
        update(baseSpacing, 0, calcSpacing);
        break;
      case 'Center':
        calcSpacing = Math.max((block - baseSpacing * gapCount), 0) / 2;
        update(baseSpacing, calcSpacing, calcSpacing);
        break;
      case 'End':
        calcSpacing = Math.max((block - baseSpacing * gapCount), 0);
        update(baseSpacing, calcSpacing, 0);
        break;
    }
  }

  /**
   * 这个方法用于计算指示器的水平偏移
   *
   * indicatorPositionX: 指示器在页签容器中的位置 (非状态变量, 修改后需要等待下一次布局才会生效)
   * indicatorOffsetX:   指示器相对于自身位置的偏移量 (状态变量)
   *
   * @param isNative 表示当前方法的调用是否是在 onPlaceChildren 中发起的
   */
  public computeIndicatorOffsetX = (isNative?: boolean): void => {
    if (this.tabLayoutInfoList.length === 0) {
      return;
    }
    // 获取本次移动中, 指示器出发点所对应 Tab 的布局信息, 并计算更精准的锚点数据
    const from: number = this.indicatorMoveStatus.from;
    if (from < 0 || from >= this.attr.viewData.length) {
      return;
    }
    const tab1: TabLayoutInfo = this.tabLayoutInfoList[from];
    const anchor1: number = tab1.x + tab1.width / 2;
    // 获取目标点, 正式开始计算偏移量
    const to: number = this.indicatorMoveStatus.to;
    if (to < -1 || to > this.attr.viewData.length) {
      return;
    }
    const offset: number = ((): number => {
      // 指示器需要向左边缘移动
      if (to === -1) {
        return anchor1 * (1 - this.indicatorMoveStatus.progress);
      // 指示器需要向右边缘移动
      } else if (to === this.attr.viewData.length) {
        return anchor1 + (tab1.width / 2 + this.tabEndMargin) * this.indicatorMoveStatus.progress;
      // 指示器不需要移动
      } else if (to === from) {
        return anchor1;
      // 指示器需要向目标锚点移动
      } else {
        const tab2: TabLayoutInfo = this.tabLayoutInfoList[to];
        const anchor2: number = tab2.x + tab2.width / 2;
        return anchor1 + (anchor2 - anchor1) * this.indicatorMoveStatus.progress;
      }
    })();
    // 计算 indicatorPositionX 或 indicatorOffsetX, 使指示器最终呈现的偏移量效果与刚刚计算的 offset 一致
    if (isNative) {
      this.indicatorPositionX = offset - this.attr.indicatorOffsetX;
    } else {
      this.attr.indicatorOffsetX = offset - this.indicatorPositionX;
    }
  }
}
