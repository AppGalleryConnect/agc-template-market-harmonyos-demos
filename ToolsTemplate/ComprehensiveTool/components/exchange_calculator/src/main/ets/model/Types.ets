@ObservedV2
export class ICurrencyData {
  /**
   *  银行中间价
   */
  bankConversionPri: number = 0;
  /**
   * 币种名称
   */
  name: string = '';
  /**
   * 国家名
   */
  country: string = '';
  /**
   * 国家旗帜
   */
  pic: ResourceStr = '';
}

@ObservedV2
export class AreaType {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}