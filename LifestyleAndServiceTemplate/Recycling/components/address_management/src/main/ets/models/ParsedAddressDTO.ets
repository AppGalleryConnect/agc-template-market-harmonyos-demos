/**
 * Parsed Address Data Transfer Object (DTO)
 */
export class ParsedAddressDTO {
  public name: string = '';         // 姓名
  public phone: string = '';        // 手机号
  public countryCode: string = '';  // 国家代码
  public country: string = '';      // 国家
  public province: string = '';     // 省
  public city: string = '';         // 市
  public district: string = '';     // 区
  public street: string = '';       // 街道
  public detail: string = '';       // 地址详述（如楼栋、门牌号等）

  public hasCompleteLocation(): boolean {
    // 一个有效的地址至少要到达三级行政区
    return !!(
      this.countryCode &&
      this.country &&
      this.province &&
      this.city &&
      this.district
    );
  }

  public clearAddress(): void {
    this.countryCode = '';
    this.country = '';
    this.province = '';
    this.city = '';
    this.district = '';
    this.street = '';
  }
}
