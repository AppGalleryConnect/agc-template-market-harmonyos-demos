import curves from '@ohos.curves';
import util from '@ohos.util';

import { Any, SimpleLength } from '@common/customtypes';

import { TabSwiperRenderUnit, TabSwiperViewData, TabLayoutMode } from './model/TabSwiperTypes';
import { TabSwiperContext } from './model/TabSwiperContext';
import { TrackNodeController } from './nodes/TrackNodeController';

/**
 * 当前组件使用 Swiper 作为内核, 对其实现了进一步封装与功能拓展
 *
 * 相关概念:
 *
 * 1. TabSwiper: 组件名, 其含义强调了 Tab 与 Swiper 互相交互这一概念
 *
 * 2. TabsBar:   组成 TabSwiper 的区域之一, 由 Track & TabsContainer & Tab & Indicator & Other 共同构成
 *    -> Track         - 页签容器所处的轨道, 使容器拥有水平滑动的能力, 其中超出 Track 的内容会被剪裁 (也可以自适应容器大小)
 *    -> TabsContainer - 页签容器, 用于承载多个 Tab 并嵌入了一个 Indicator
 *    -> Tab           - 页签
 *    -> Indicator     - 滑动指示器
 *    -> Other         - 可以通过减小 Track 宽度来留出空间, 在 TabsBar 嵌入其它自定义组件
 *
 * 3. Swiper:    组成 TabSwiper 的区域之一, 由多个 TabContent 共同构成
 *    -> TabContent    - 每个 Tab 都会关联一个 Content, 称之为 TabContent
 *
 * @since 13
 */
@ComponentV2
export struct TabSwiper {

  /* TabSwiper 的视图数据 (由多个渲染单元构成) */
  @Param
  public viewData: TabSwiperViewData = [];

  /* 是否禁用划动切换 */
  @Param
  public disableSwipe: boolean = false;

  /* 页签间距基准值 (影响: 页签与行首、页签与行尾、页签与页签) */
  @Param
  public tabSpacingBase: number = 0;

  /**
   * 页签布局模式
   *
   * 组件会基于 tabSpacingBase(后称 space) 和每个 Tab 的大小进行判断, 如果其预见依此布局后 TabsContainer 的宽度将小于 Track,
   * 则实际的 Spacing 会取 space + x, 使最终布局后的宽度与 Track 相等
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
  @Param
  public tabLayoutMode: TabLayoutMode = 'SpaceEvenly';

  /* 页签容器最小高度 (页签容器会在最高 Tab 和当前属性之间抉择实际高度) */
  @Param
  public tabsContainerMinHeight: number = 0;

  /* 轨道宽度 (永远不会超出 TabSwiper 宽度, 例如 '200%' 将被视为 '100%') */
  @Param
  public trackWidth: SimpleLength = '100%';

  /* 轨道高度 (取 auto 时自适应页签容器高度) */
  @Param
  public trackHeight: SimpleLength = 'auto';

  /* 轨道小于 TabSwiper 宽度时, 在 TabsBar 区域的水平对齐方式 */
  @Param
  public trackHorizontalAlignment: HorizontalAlign = HorizontalAlign.Start;

  /* 轨道边缘划动效果 */
  @Param
  public trackEdgeEffectMode: EdgeEffect = EdgeEffect.Spring;

  /* 轨道边缘划动效果额外选项 */
  @Param
  public trackEdgeEffectOptions: EdgeEffectOptions = { alwaysEnabled: true };

  /* 页签区域的位置 (顶部或底部) */
  @Param
  public barPosition: BarPosition = BarPosition.Start;

  /* 是否将页签区域覆盖在 Swiper 区域 */
  @Param
  public barOverlap: boolean = false;

  /* 页签区域背景颜色 */
  @Param
  public barBackgroundColor: ResourceColor = Color.Transparent;

  /* 页签区域背景模糊效果 */
  @Param
  public barBackgroundBlurStyle: BlurStyle = BlurStyle.NONE;

  /* 页签区域背景模糊效果选项 */
  @Param
  public barBackgroundBlurStyleOptions: BackgroundBlurStyleOptions = {};

  /* 是否扩展页签区域的安全区 */
  @Param
  public barExpandSafeArea: boolean = false;

  /**
   * 该索引仅用于初始化, 禁止组件内外后续对其进行更新
   *
   * 原因:
   *   1. 无论是通过 $$ 还是 onChange 更新, 延迟表现都很不理想
   *      原因在于页面切换动画彻底结束时 Swiper 才会触发更新 (视觉上动画已经完成, 实际上依然有小幅抖动), 因此不推荐依赖索引来触发相关渲染
   *
   *   2. 更推荐使用 controller 控制页面切换, 而不是通过更新 index 触发页面切换
   *
   *   3. 当前组件内部不需要在初始化以外的生命周期维护索引
   * 注:
   *   1. @Param 不受 readonly 限制, 因此可通过与 @Once 配合, 实现组件内外仅在初始化时赋值一次
   *   2. swiperInitialIndex 的本质依然属于变量, 外部对其的赋值相当于第二次赋值, 不符合常量定义
   */
  @Param @Once
  public readonly swiperInitialIndex: number = 0;

  /* 是否扩展 Swiper 的安全区 */
  @Param
  public swiperExpandSafeArea: boolean = false;

  /* 是否开启 Swiper 的边缘剪切机制 */
  @Param
  public swiperClip: boolean = false;

  /* Swiper 边缘划动效果 */
  @Param
  public swiperEffectMode: EdgeEffect = EdgeEffect.None;

  /* Swiper 背景色 */
  @Param
  public swiperBackgroundColor: ResourceColor = Color.Transparent;

  /* 指示器宽度 */
  @Param
  public indicatorWidth: number = 0;

  /* 指示器高度 */
  @Param
  public indicatorHeight: number = 0;

  /* 指示器边框半径 */
  @Param
  public indicatorRadius: Length | BorderRadiuses | LocalizedBorderRadiuses = 0;

  /* 指示器颜色 */
  @Param
  public indicatorColor: ResourceColor = Color.Black;

  /* 指示器与页签容器底部的距离 */
  @Param
  public indicatorMarginBottom: number = 0;

  @Event
  public onChange: (index: number, id: string) => void = () => {};

  /* 当前是 Swiper 第几页 (从 0 开始计数) */
  private swiperIndex: number = ((): number => {
    if (this.swiperInitialIndex < 0) {
      return 0;
    } else if (this.swiperInitialIndex >= this.viewData.length) {
      return this.viewData.length - 1;
    } else {
      return this.swiperInitialIndex;
    }
  })();

  /* 当前页使用的数据源对应 Id */
  private dataId: string | null = this.viewData.length === 0 ? null : this.viewData[this.swiperIndex].id;

  private readonly swiperController: SwiperController = new SwiperController();

  private readonly TABS_BAR_ID: string = util.generateRandomUUID(false);

  private readonly ctx: TabSwiperContext = new TabSwiperContext();

  private readonly trackNodeController: TrackNodeController = new TrackNodeController(this.ctx);

  aboutToAppear(): void {
    this.ctx.swiperController = this.swiperController;
    this.ctx.attr.viewData = this.viewData;
    this.ctx.attr.tabSpacingBase = this.tabSpacingBase;
    this.ctx.attr.tabLayoutMode = this.tabLayoutMode;
    this.ctx.attr.tabsContainerMinHeight = this.tabsContainerMinHeight;
    this.ctx.attr.trackWidth = this.trackWidth;
    this.ctx.attr.trackHeight = this.trackHeight;
    this.ctx.attr.trackEdgeEffectMode = this.trackEdgeEffectMode;
    this.ctx.attr.trackEdgeEffectOptions = this.trackEdgeEffectOptions;
    this.ctx.attr.indicatorWidth = this.indicatorWidth;
    this.ctx.attr.indicatorHeight = this.indicatorHeight;
    this.ctx.attr.indicatorRadius = this.indicatorRadius;
    this.ctx.attr.indicatorColor = this.indicatorColor;
    this.ctx.attr.indicatorMarginBottom = this.indicatorMarginBottom;
    this.ctx.indicatorMoveStatus = {
      from: this.swiperIndex,
      to: this.swiperIndex,
      progress: 1
    };
    this.ctx.computeIndicatorOffsetX();
  }

  @Monitor(
    'viewData', 'viewData.length', 'tabSpacingBase', 'tabLayoutMode', 'tabsContainerMinHeight',
    'trackWidth', 'trackHeight', 'trackEdgeEffectMode', 'trackEdgeEffectOptions', 'indicatorWidth',
    'indicatorHeight', 'indicatorRadius', 'indicatorColor', 'indicatorMarginBottom'
  )
  onTabSwiperAttributeChange(iMonitor: IMonitor): void {
    for (let k of iMonitor.dirty) {
      let v: IMonitorValue<Any> | undefined = iMonitor.value<Any>(k);
      if (v) {
        switch (k) {
          case 'viewData':
            this.ctx.attr.viewData = v.now as TabSwiperViewData;
            break;
          case 'viewData.length':
            const size: number = v.now as number;
            if (size > 0) {
              let swiperIndex: number = ((): number => {
                for (let i: number = 0; i < this.ctx.attr.viewData.length; i++) {
                  if (this.ctx.attr.viewData[i].id === this.dataId) {
                    return i;
                  }
                }
                return this.swiperIndex < size ? this.swiperIndex : size - 1;
              })();
              if (swiperIndex !== this.swiperIndex || this.ctx.attr.viewData[swiperIndex].id !== this.dataId) {
                this.swiperIndex = swiperIndex;
                this.dataId = this.ctx.attr.viewData[swiperIndex].id;
                this.swiperController.changeIndex(this.swiperIndex, false);
                this.onChange(this.swiperIndex, this.dataId);
              }
            }
            break;
          case 'tabSpacingBase':
            this.ctx.attr.tabSpacingBase = v.now as number;
            this.trackNodeController.layout();
            break;
          case 'tabLayoutMode':
            this.ctx.attr.tabLayoutMode = v.now as TabLayoutMode;
            this.trackNodeController.layout();
            break;
          case 'tabsContainerMinHeight':
            this.ctx.attr.tabsContainerMinHeight = v.now as number;
            this.trackNodeController.layout();
            break;
          case 'trackWidth':
            this.ctx.attr.trackWidth = v.now as SimpleLength;
            break;
          case 'trackHeight':
            this.ctx.attr.trackHeight = v.now as SimpleLength;
            break;
          case 'trackEdgeEffectMode':
            this.ctx.attr.trackEdgeEffectMode = v.now as EdgeEffect;
            break;
          case 'trackEdgeEffectOptions':
            this.ctx.attr.trackEdgeEffectOptions = v.now as EdgeEffectOptions;
            break;
          case 'indicatorWidth':
            this.ctx.attr.indicatorWidth = v.now as number;
            break;
          case 'indicatorHeight':
            this.ctx.attr.indicatorHeight = v.now as number;
            break;
          case 'indicatorRadius':
            this.ctx.attr.indicatorRadius = v.now as Length | BorderRadiuses | LocalizedBorderRadiuses;
            break;
          case 'indicatorColor':
            this.ctx.attr.indicatorColor = v.now as ResourceColor;
            break;
          case 'indicatorMarginBottom':
            this.ctx.attr.indicatorMarginBottom = v.now as number;
            break;
        }
      }
    }
  }

  build() {
    RelativeContainer() {
      Column() {
        this.buildSwiper()
      }
      .alignRules((this.barPosition === BarPosition.Start) ? {
        top: {
          anchor: this.TABS_BAR_ID,
          align: this.barOverlap ? VerticalAlign.Top : VerticalAlign.Bottom
        },
        bottom: {
          anchor: '__container__',
          align: VerticalAlign.Bottom
        }
      } : {
        top: {
          anchor: '__container__',
          align: VerticalAlign.Top
        },
        bottom: {
          anchor: this.TABS_BAR_ID,
          align: this.barOverlap ? VerticalAlign.Bottom : VerticalAlign.Top
        }
      })
      // 将 TabsBar 相关代码编写在 Swiper 之后, 使二者布局发生重叠时 TabsBar 永远渲染在最上层
      Column() {
        NodeContainer(this.trackNodeController)
          .width('auto')  // 自适应节点测量后的宽度
          .height('auto') // 自适应节点测量后的高度
      }
      .width('100%')
      .id(this.TABS_BAR_ID)
      .backgroundColor(this.barBackgroundColor)
      .backgroundBlurStyle(this.barBackgroundBlurStyle, this.barBackgroundBlurStyleOptions)
      .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
          this.barExpandSafeArea ? [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP] : [])
      .alignItems(this.trackHorizontalAlignment)
      .alignRules((this.barPosition === BarPosition.Start) ? {
        top: {
          anchor: '__container__',
          align: VerticalAlign.Top
        }
      } : {
        bottom: {
          anchor: '__container__',
          align: VerticalAlign.Bottom
        }
      })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildSwiper() {
    Swiper(this.swiperController) {
      /**
       * 如果需要在 itemGenerator 显式声明 index，则 keyGenerator 也要声明，
       * 否则 key 会被额外拼接为 index + '_' + r.id
       */
      ForEach(
        this.ctx.attr.viewData,
        (r: TabSwiperRenderUnit) => {
          Column() {
            r.tabContent.wrappedBuilder.builder(...r.tabContent.args)
          }
        },
        (r: TabSwiperRenderUnit) => r.id
      )
    }
    .width('100%')
    .height('100%')
    .clip(this.swiperClip)
    .expandSafeArea([SafeAreaType.SYSTEM, SafeAreaType.CUTOUT],
        this.swiperExpandSafeArea ? [SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP] : [])
    .backgroundColor(this.swiperBackgroundColor)
    .index(this.swiperInitialIndex)
    .autoPlay(false)
    .interval(undefined)
    .indicator(false)
    .loop(false)
    .duration(400)                                     // 动画时长取默认值 (需要与属性 curve 配合使用, 且在一些特殊的 curve 设置下, duration 值失效)
    .vertical(false)
    .itemSpace('0px')
    .displayMode(SwiperDisplayMode.STRETCH)            // 设置滑动一页的宽度为 Swiper 组件自身宽度
    .cachedCount(1)                                    // 预先缓存当前页的前一页与后一页
    .disableSwipe(this.disableSwipe)
    .curve(curves.interpolatingSpring(-1, 1, 328, 34)) // 当前使用了插值器弹簧曲线对象, 会导致即便设置 EdgeEffect.None, 依然可能在特殊情况发生小幅边缘弹性现象
    .displayCount(1, false)
    .effectMode(this.swiperEffectMode)
    .displayArrow(false, false)
    .nextMargin(0, true)
    .prevMargin(0, true)
    .nestedScroll(SwiperNestedScrollMode.SELF_ONLY)
    .indicatorInteractive(false)
    .onChange((index: number): void => {
      if (this.swiperIndex === index) {
        return;
      }
      this.ctx.indicatorMoveStatus = {
        from: this.swiperIndex,
        to: index,
        progress: 1
      };
      this.ctx.computeIndicatorOffsetX();
      this.swiperIndex = index;
      this.dataId = this.viewData[index].id;
      this.onChange(this.swiperIndex, this.dataId);
    })
    .onAnimationStart((_: number, targetIndex: number, __: SwiperAnimationEvent): void => {
      this.swiperIndex = targetIndex;
      this.dataId = this.ctx.attr.viewData[targetIndex].id;
      this.onChange(this.swiperIndex, this.dataId);
    })
    .onAnimationEnd((index: number, extraInfo: SwiperAnimationEvent): void => {
      index;
      extraInfo;
    })
    .onContentDidScroll((selectedIndex: number, index: number, position: number): void => {
      // 第一个页面正在右移, 指示器需要向左边缘移动
      if (index === 0 && position >= 0) {
        this.ctx.indicatorMoveStatus = {
          from: index,
          to: -1,
          progress: position
        };
      // 最后一个页面正在左移, 指示器需要向右边缘移动
      } else if (index === this.ctx.attr.viewData.length - 1 && position <= 0) {
        this.ctx.indicatorMoveStatus = {
          from: index,
          to: this.ctx.attr.viewData.length,
          progress: -position // position 小于等于 0, 而 progress 的含义是移动进度, 只有向量中的'量'
        };
      /**
       * 当前页面正在左移, 指示器需要右移
       *
       * 页面左移时, position 会从一个正值逐渐趋向 0, 当越过主轴起始位置时, 会变为负值
       */
      } else if (index > selectedIndex && position >= 0) {
        this.ctx.indicatorMoveStatus = {
          from: index - 1,
          to: index,
          progress: 1 - position
        };
        /**
         * 当前页面正在右移, 指示器需要左移
         *
         * 页面右移时, position 会从一个负值逐渐趋向 0, 当越过主轴起始位置时, 会变为正值
         */
      } else if (index < selectedIndex && position <= 0) {
        this.ctx.indicatorMoveStatus = {
          from: index + 1,
          to: index,
          progress: 1 + position
        };
      } else {
        return;
      }
      this.ctx.computeIndicatorOffsetX();
    })
  }
}
