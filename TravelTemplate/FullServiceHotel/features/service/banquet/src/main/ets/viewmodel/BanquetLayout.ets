export default class BanquetLayout {
  private _type: string;

  private _icon: PixelMap | ResourceStr | DrawableDescriptor;

  private _capacity: string;

  public get type(): string {
    return this._type;
  }

  public get icon(): PixelMap | ResourceStr | DrawableDescriptor {
    return this._icon;
  }

  public get capacity(): string {
    return this._capacity;
  }

  constructor(type: string, icon: PixelMap | ResourceStr | DrawableDescriptor, capacity: string) {
    this._type = type;
    this._icon = icon;
    this._capacity = capacity;
  }
}
