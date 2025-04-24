export default class Benefit {
  private _name: string;

  private _icon: PixelMap | ResourceStr | DrawableDescriptor;

  public get name(): string {
    return this._name;
  }

  public get icon(): PixelMap | ResourceStr | DrawableDescriptor {
    return this._icon;
  }

  constructor(name: string, icon: PixelMap | ResourceStr | DrawableDescriptor) {
    this._name = name;
    this._icon = icon;
  }
}
