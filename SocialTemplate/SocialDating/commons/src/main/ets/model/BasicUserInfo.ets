export class BasicUserInfo {
  private _uid: number | null = null;

  public set uid(value: number | null) {
    this._uid = value;
  }

  public get uid(): number | null {
    return this._uid;
  }

  private _hwUnionId: string | null = null;

  public set hwUnionId(value: string | null) {
    this._hwUnionId = value;
  }

  public get hwUnionId(): string | null {
    return this._hwUnionId;
  }

  private _userNo: string | null = null;

  public set userNo(value: string | null) {
    this._userNo = value;
  }

  public get userNo(): string | null {
    return this._userNo;
  }

  private _nickName: string | null = null;

  public set nickName(value: string | null) {
    this._nickName = value;
  }

  public get nickName(): string | null {
    return this._nickName;
  }

  private _profileUrl: string | null = null;

  public set profileUrl(value: string | null) {
    this._profileUrl = value;
  }

  public get profileUrl(): string | null {
    return this._profileUrl;
  }

  private _realNameAuthFlag: number = 0;

  public set realNameAuthFlag(value: number) {
    this._realNameAuthFlag = value;
  }

  public get realNameAuthFlag(): number {
    return this._realNameAuthFlag;
  }

  private _isVip: number | null = null;

  public set isVip(value: number | null) {
    this._isVip = value;
  }

  public get isVip(): number | null {
    return this._isVip;
  }

  private _gender: number | null = null;

  public set gender(value: number | null) {
    this._gender = value;
  }

  public get gender(): number | null {
    return this._gender;
  }
}