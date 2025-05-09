import { NodeController, FrameNode, BuilderNode, LayoutConstraint } from '@ohos.arkui.node';
import { UIContext } from '@ohos.arkui.UIContext';

import { CustomNodeConst as Const } from '../common/Const';
import { TabSwiperContext } from '../model/TabSwiperContext';
import { buildTabsContainer } from './builder/TabsContainer';

export class TabsNodeController extends NodeController {

  private ctx: TabSwiperContext;

  private node: TabsNode | null = null;

  makeNode(uiContext: UIContext): FrameNode | null {
    if (!this.node) {
      this.node = new TabsNode(uiContext, this.ctx);
      this.node.build();
    }
    return this.node;
  }

  constructor(ctx: TabSwiperContext) {
    super();
    this.ctx = ctx;
  }
}

/**
 * TabsContainer 使用了自定义布局, 每个 Tab 的测量受父组件约束, 因此当前节点用于重写约束, 解开 Tab 的测量限制
 *
 * 1. 使 Tab 的大小可以超过父组件, 如 Track 组件
 *
 * 2. 使 Tab 的宽高属性支持数字和百分比混合定义, 使用数字时将不受任何限制, 使用百分比时将参考父组件而不是无穷大
 */
class TabsNode extends FrameNode {

  private ctx: TabSwiperContext;

  private tabsContainerBuilder: BuilderNode<[TabSwiperContext]>;

  private tabsContainer: FrameNode | null = null;

  public onMeasure(constraint: LayoutConstraint): void {
    this.ctx.lastConstraint = {
      maxSize: Const.MAX_SIZE,
      minSize: Const.MIN_SIZE,
      percentReference: constraint.percentReference
    };
    this.tabsContainer?.measure(this.ctx.lastConstraint);
    this.setMeasuredSize(this.tabsContainer?.getMeasuredSize() ?? Const.MIN_SIZE);
  }

  public onLayout(_: Position): void {
    this.tabsContainer?.layout(Const.DEFAULT_POSITION);
    this.setLayoutPosition(Const.DEFAULT_POSITION);
  }

  public build(): void {
    if (!this.getFirstChild()) {
      this.tabsContainerBuilder.build(wrapBuilder(buildTabsContainer), this.ctx, { nestingBuilderSupported: false });
      this.tabsContainer = this.tabsContainerBuilder.getFrameNode();
      this.appendChild(this.tabsContainer);
    }
  }

  constructor(uiContext: UIContext, ctx: TabSwiperContext) {
    super(uiContext);
    this.ctx = ctx;
    this.tabsContainerBuilder = new BuilderNode(uiContext);
  }
}
