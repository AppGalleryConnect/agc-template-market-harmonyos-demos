import { IAddrInfo } from 'module_base';

@ObservedV2
export class AddressVM {
  @Trace
  public id: string = '';

  @Trace
  public name: string = ''; // 姓名

  @Trace
  public phone: string = ''; // 手机号

  @Trace
  public countryCode: string = ''; // 国家代码

  @Trace
  public country: string = ''; // 国家

  @Trace
  public province: string = ''; // 省

  @Trace
  public city: string = ''; // 市

  @Trace
  public district: string = ''; // 区

  @Trace
  public street: string = ''; // 街道

  @Trace
  public detail: string = ''; // 地址详述（如楼栋、门牌号等）

  @Trace
  public isDefault: boolean = false; // 是否为默认地址

  @Trace
  public createdAt: number = 0; // 地址创建时间

  @Trace
  public updatedAt: number = 0; // 地址更新时间

  @Computed
  public get title(): string {
    return [this.name, this.phone].filter(Boolean).join(' ');
  }

  @Computed
  public get region(): string {
    return [
      this.countryCode === 'CN' ? '' : this.country,
      this.province === this.city ? '' : this.province,
      this.city,
      this.district,
      this.street,
    ]
      .filter(Boolean)
      .join(' ');
  }

  @Computed
  public get fullAddress(): string {
    return [
      this.countryCode === 'CN' ? '' : this.country,
      this.province === this.city ? '' : this.province,
      this.city,
      this.district,
      this.street,
      this.detail,
    ]
      .filter(Boolean)
      .join(' ');
  }

  public assignFromDTO(address: IAddrInfo): void {
    this.id = address.id ?? '';
    this.name = address.name ?? '';
    this.phone = address.phone ?? '';
    this.countryCode = address.countryCode ?? '';
    this.country = address.country ?? '';
    this.province = address.province ?? '';
    this.city = address.city ?? '';
    this.district = address.district ?? '';
    this.street = address.street ?? '';
    this.detail = address.detail ?? '';
    this.isDefault = address.isDefault ?? false;
    this.createdAt = address.createdAt ?? 0;
    this.updatedAt = address.updatedAt ?? 0;
  }

  public toDTO(): IAddrInfo {
    return {
      id: this.id,
      name: this.name,
      phone: this.phone,
      countryCode: this.countryCode,
      country: this.country,
      province: this.province,
      city: this.city,
      district: this.district,
      street: this.street,
      detail: this.detail,
      isDefault: this.isDefault,
      createdAt: this.createdAt,
      updatedAt: this.updatedAt,
    };
  }
}
