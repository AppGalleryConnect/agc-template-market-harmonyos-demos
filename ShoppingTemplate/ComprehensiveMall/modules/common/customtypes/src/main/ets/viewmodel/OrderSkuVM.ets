

@ObservedV2
export class OrderSkuVM {

  public productId: string = '';

  public skuCode: string = '';

  @Trace
  public skuDesc: string = '';

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

}
