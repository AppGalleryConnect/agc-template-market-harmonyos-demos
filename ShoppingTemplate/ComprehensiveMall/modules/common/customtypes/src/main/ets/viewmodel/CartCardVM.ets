

@ObservedV2
export class CartCardVM {

  public productId: string = '';

  public skuCode: string = '';

  public controller: ListScroller = new ListScroller();

  @Trace
  public skuDesc: string = '';

  @Trace
  public stock: number = 0;

  @Trace
  public count: number = 0;

  @Trace
  public banner: ResourceStr = '';

  @Trace
  public title: string = '';

  @Trace
  public serviceDesc: string = '';

  @Trace
  public price: number = 0;

  @Trace
  public isSelected: boolean = false;
}
