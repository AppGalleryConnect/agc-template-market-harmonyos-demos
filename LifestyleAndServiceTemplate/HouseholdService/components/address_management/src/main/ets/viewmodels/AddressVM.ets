import { AddressDTO } from '../models/AddressDTO';

@ObservedV2
export class AddressVM {
  @Trace
  public id: string = '';
  @Trace
  public name: string = '';
  @Trace
  public phone: string = '';
  @Trace
  public countryCode: string = '';
  @Trace
  public country: string = '';
  @Trace
  public province: string = '';
  @Trace
  public city: string = '';
  @Trace
  public district: string = '';
  @Trace
  public street: string = '';
  @Trace
  public detail: string = '';
  @Trace
  public isDefault: boolean = false;
  @Trace
  public createdAt: number = 0;
  @Trace
  public updatedAt: number = 0;
  private snapshot: string = '';

  constructor(dto?: AddressDTO) {
    if (dto) {
      this.assignFromDTO(dto);
    }
    this.refreshSnapshot();
  }

  @Computed
  public get title(): string {
    return [
      this.name,
      this.phone
    ].filter(Boolean).join(' ');
  }

  @Computed
  public get region(): string {
    return [
      this.countryCode === 'CN' ? '' : this.country,
      this.province === this.city ? '' : this.province,
      this.city,
      this.district,
      this.street
    ].filter(Boolean).join('');
  }

  @Computed
  public get fullAddress(): string {
    return [
      this.region,
      this.detail
    ].filter(Boolean).join('');
  }

  public refreshSnapshot(): void {
    this.snapshot = JSON.stringify(this.toDTO());
  }

  public hasChanges(): boolean {
    return this.snapshot !== JSON.stringify(this.toDTO());
  }

  public clearRegion(): void {
    this.countryCode = '';
    this.country = '';
    this.province = '';
    this.city = '';
    this.district = '';
    this.street = '';
  }

  public assignFromDTO(address: AddressDTO): void {
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

  public toDTO(): AddressDTO {
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
      updatedAt: this.updatedAt
    };
  }
}
