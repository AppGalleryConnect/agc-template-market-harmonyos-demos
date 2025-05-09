import { ComponentEntryProxy } from '@common/customtypes';

@ComponentV2
export struct IRow {

  @Param
  public spacing: number = 0;

  @Param
  public singleComponentMinWidth: number = 0;

  @Param
  public viewData: ComponentEntryProxy[] = [];

  private limit: MeasureResult = { width: 0, height: 0 };

  onMeasureSize(_: GeometryInfo, children: Measurable[], constraint: ConstraintSizeOptions): SizeResult {
    /**
     * 由于 ConstraintSizeOptions 中的属性不一定是 number 类型
     *
     * 因此约定了第 1 个元素为占位元素, 其宽高固定为 '100%', 用于计算出 number 类型的测量约束
     *
     * 测量结束后, 占位元素将被隐藏
     */
    this.limit = children[0].measure(constraint);
    this.hide(children, 0);
    let remainingWidth: number = this.limit.width;
    let maxHeight: number = 0;
    for (let i: number = 1; i < children.length; i++) {
      const result: MeasureResult = children[i].measure(constraint);
      maxHeight = Math.max(maxHeight, result.height);
      if (result.width <= remainingWidth) {
        remainingWidth = remainingWidth - result.width - this.spacing;
      } else if (remainingWidth > this.singleComponentMinWidth) {
        children[i].measure({
          minWidth: constraint.minWidth,
          maxWidth: remainingWidth,
          minHeight: constraint.minHeight,
          maxHeight: constraint.maxHeight
        });
        remainingWidth = 0;
      } else {
        this.hide(children, i);
      }
    }
    this.limit.height = maxHeight;
    return { width: this.limit.width, height: this.limit.height };
  }

  onPlaceChildren(_: GeometryInfo, children: Layoutable[]): void {
    let right: number = 0;
    for (let i: number = 1; i < children.length; i++) {
      children[i].layout({
        x: right,
        y: (this.limit.height - children[i].measureResult.height) / 2
      });
      right = right + children[i].measureResult.width + this.spacing;
    }
  }

  build(): void {
    this.buildContainer()
  }

  private hide = (children: Measurable[], index: number): void => {
    if (index >= 0 && children.length > index) {
      children[index].measure({ minWidth: 0, minHeight: 0, maxWidth: 0, maxHeight: 0 });
    }
  }

  @Builder
  buildContainer() {
    Row()
      .width('100%')
      .height('100%')
    ForEach(this.viewData, (v: ComponentEntryProxy) => {
      v.wrappedBuilder.builder(...v.args);
    })
  }
}
