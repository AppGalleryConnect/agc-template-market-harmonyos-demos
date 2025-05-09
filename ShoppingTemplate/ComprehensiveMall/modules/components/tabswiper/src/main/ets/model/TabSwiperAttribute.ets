import { SimpleLength } from '@common/customtypes';
import { TabSwiperViewData, TabLayoutMode } from './TabSwiperTypes';

@ObservedV2
export class TabSwiperAttribute {

  /* TabSwiper 的视图数据 (由多个渲染单元构成) */
  @Trace
  public viewData: TabSwiperViewData = [];

  /* 页签间距基准值 (页签与行首、页签与行尾、页签与页签) */
  @Trace
  public tabSpacingBase: number = 0;

  /**
   * 页签布局模式
   *
   * 组件会基于 tabSpacingBase (后称 space) 对每个 Tab 进行初步的布局计算, 得出此时 TabsContainer 的宽度
   *
   * 当 TabsContainer 宽度小于 Track 宽度时, 组件会在 space 的基础上增加 x, 使总宽度等于 Track 的宽度
   *
   * SpaceBetween
   *
   *    1. 第一个元素到行首的距离
   *                           -> 0
   *    2. 最后一个元素到行尾的距离
   *                           -> 0
   *    3. 相邻元素之间的距离
   *                           -> space + x
   * SpaceAround
   *
   *    1. 第一个元素到行首的距离
   *                           -> (space + x) / 2
   *    2. 最后一个元素到行尾的距离
   *                           -> (space + x) / 2
   *    3. 相邻元素之间的距离
   *                           -> space + x
   * SpaceEvenly
   *
   *    1. 第一个元素到行首的距离
   *                           -> space + x
   *    2. 最后一个元素到行尾的距离
   *                           -> space + x
   *    3. 相邻元素之间的距离
   *                           -> space + x
   * Start & Center & End
   *
   *    1. space 仅用于元素之间的距离
   *
   *    2. x 仅用于元素与行首或行尾的距离, 即 TabsContainer 大于等于 Track 时, 三者布局效果等价于 SpaceBetween
   */
  @Trace
  public tabLayoutMode: TabLayoutMode = 'SpaceEvenly';

  /* 页签容器最小高度 (页签容器会在最高 Tab 和当前属性之间抉择实际高度) */
  @Trace
  public tabsContainerMinHeight: number = 0;

  /* 轨道宽度 (永远不会超出 TabSwiper 宽度, 例如 '200%' 将被视为 '100%') */
  @Trace
  public trackWidth: SimpleLength = '100%';

  /* 轨道高度 (取 auto 时自适应页签容器高度) */
  @Trace
  public trackHeight: SimpleLength = 'auto';

  /* 轨道边缘划动效果 */
  @Trace
  public trackEdgeEffectMode: EdgeEffect = EdgeEffect.Spring;

  /* 轨道边缘划动效果额外选项 */
  @Trace
  public trackEdgeEffectOptions: EdgeEffectOptions = { alwaysEnabled: true };

  /* 指示器宽度 */
  @Trace
  public indicatorWidth: number = 0;

  /* 指示器高度 */
  @Trace
  public indicatorHeight: number = 0;

  /* 指示器边框半径 */
  @Trace
  public indicatorRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0;

  /* 指示器颜色 */
  @Trace
  public indicatorColor: ResourceColor = Color.Black;

  /* 指示器水平方向偏移量 */
  @Trace
  public indicatorOffsetX: number = 0;

  /* 指示器与页签容器底部的距离 */
  @Trace
  public indicatorMarginBottom: number = 0;
}
