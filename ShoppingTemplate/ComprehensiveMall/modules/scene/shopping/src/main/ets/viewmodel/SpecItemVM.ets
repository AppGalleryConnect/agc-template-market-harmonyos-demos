

/**
 * 用于商品规格选择器的模态页面和逻辑层
 *
 */
@ObservedV2
export class SpecItemVM {

  // 规格项 UUID
  public id: string = '';

  // 所属 key
  public key: string = '';

  // 规格项类型
  public type: 'text' | 'image_text' = 'text';

  // 文本内容
  @Trace
  public text: string = '';

  // 图片资源
  @Trace
  public image?: string = undefined;

  // 是否可选
  @Trace
  public isSelectable: boolean = false;

  // 是否缺货
  @Trace
  public isInStock: boolean = false;

  // 是否已选中
  @Trace
  public isSelected: boolean = false;
}
