import { NodeController, FrameNode, BuilderNode, LayoutConstraint } from '@ohos.arkui.node';
import { UIContext } from '@ohos.arkui.UIContext';

import { CustomNodeConst as Const } from '../common/Const';
import { TabSwiperContext } from '../model/TabSwiperContext';
import { buildTrack } from './builder/Track';

/**
 * 当前 Controller 用于 TabsBar 中 Track 的起始占位节点, 最终会构建出以下结构
 * Component Tree:
 * ...
 *   -> NodeContainer    - (TrackNodeController)
 *   -> CustomFrameNode  - (TrackNode)
 *   -> BuilderProxyNode & Track           <- Track 组件是通过 BuilderNode 构建, 节点类型为 BuilderProxyNode
 *   -> Scroll
 *   -> NodeContainer    - (TabsNodeController)
 *   -> CustomFrameNode  - (TabsNode)
 *   -> JsView           - (TabsContainer) <- TabsContainer 也是通过 BuilderNode 构建, 但由于使用了自定义布局, 节点类型为 JsView
 * ...
 */
export class TrackNodeController extends NodeController {

  private ctx: TabSwiperContext;

  private node: TrackNode | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    if (!this.node) {
      this.node = new TrackNode(uiContext, this.ctx);
      this.node.build();
    }
    return this.node;
  }

  /**
   * 当前方法用于对 TabsContainer 和它的父节点进行标脏
   *
   * 应注意需要杜绝毫无征兆的直接调用此方法, 这可能会导致重复计算、动画不触发、甚至调用直接无效等不符合预期的行为发生。
   *
   * 最佳调用时机是在状态变量发生修改时, 因为无论是变量改动还是 setNeedsLayout 调用, 它们的本质
   * 都是对相关节点进行标记, 让其重新测量、重新布局、重新渲染, 最终呈现在下一帧。
   *
   * 先改变一个状态变量, 让系统以一个最常见的方式自行进入标记环节, 之后将调用逻辑在 @Monitor 中执行才是最稳定的做法。
   */
  public layout(): void {
    this.node?.getTabsContainer()?.setNeedsLayout();
  }

  constructor(ctx: TabSwiperContext) {
    super();
    this.ctx = ctx;
  }
}

class TrackNode extends FrameNode {

  private ctx: TabSwiperContext;

  private trackBuilder: BuilderNode<[TabSwiperContext]>;

  private track: FrameNode | null = null;

  private tabsContainer: FrameNode | null = null;

  public getTabsContainer(): FrameNode | null {
    return this.tabsContainer;
  }

  public onMeasure(constraint: LayoutConstraint): void {
    if (this.ctx.lastConstraint !== null) {
      this.ctx.layoutFlag = true;
      this.tabsContainer?.measure(this.ctx.lastConstraint); // 使用上一次的约束, 否则即便不是脏节点, 也有可能触发 onMeasureSize 从而更新 flag
      if (this.ctx.layoutFlag) {
        this.tabsContainer?.setNeedsLayout(); // setNeedsLayout 不仅仅会标记当前节点, 还会基于这个节点向上遍历, 直到找到一个非脏节点一并标记
      }
    }
    this.ctx.layoutFlag = false;
    this.track?.measure(constraint);
    this.setMeasuredSize(this.track?.getMeasuredSize() ?? Const.MIN_SIZE);
  }

  public onLayout(_: Position): void {
    this.track?.layout(Const.DEFAULT_POSITION);
    this.setLayoutPosition(Const.DEFAULT_POSITION);
  }

  public build(): void {
    if (!this.getFirstChild()) {
      this.trackBuilder.build(wrapBuilder(buildTrack), this.ctx, { nestingBuilderSupported: false });
      this.track = this.trackBuilder.getFrameNode();
      this.tabsContainer = this.track
                            ?.getFirstChild() // Scroll
                            ?.getFirstChild() // NodeContainer
                            ?.getFirstChild() // CustomFrameNode
                            ?.getFirstChild() ?? null; // JsView
      this.appendChild(this.track);
    }
  }

  constructor(uiContext: UIContext, ctx: TabSwiperContext) {
    super(uiContext);
    this.ctx = ctx;
    this.trackBuilder = new BuilderNode(uiContext);
  }
}
