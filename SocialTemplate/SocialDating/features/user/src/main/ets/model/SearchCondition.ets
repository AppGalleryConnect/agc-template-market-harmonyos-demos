
export class SearchCondition{
  private _nickName: string | null = null;

  public set nickName(value: string | null) {
    this._nickName = value;
  }

  public get nickName(): string | null {
    return this._nickName;
  }

  private _userNo: string | null = null;

  public set userNo(value: string | null) {
    this._userNo = value;
  }

  public get userNo(): string | null {
    return this._userNo;
  }

  private _ageStart: number | null = null;

  public set ageStart(value: number | null) {
    this._ageStart = value;
  }

  public get ageStart(): number | null {
    return this._ageStart;
  }

  private _ageEnd: number | null = null;

  public set ageEnd(value: number | null) {
    this._ageEnd = value;
  }

  public get ageEnd(): number | null {
    return this._ageEnd;
  }

  private _gender: number | null = null;

  public set gender(value: number | null) {
    this._gender = value;
  }

  public get gender(): number | null {
    return this._gender;
  }

  private _heightStart: number | null = null;

  public set heightStart(value: number | null) {
    this._heightStart = value;
  }

  public get heightStart(): number | null {
    return this._heightStart;
  }

  private _heightEnd: number | null = null;

  public set heightEnd(value: number | null) {
    this._heightEnd = value;
  }

  public get heightEnd(): number | null {
    return this._heightEnd;
  }

  private _monthlyIncome: string | null = null;

  public set monthlyIncome(value: string | null) {
    this._monthlyIncome = value;
  }

  public get monthlyIncome(): string | null {
    return this._monthlyIncome;
  }

  private _education: string | null = null;

  public set education(value: string | null) {
    this._education = value;
  }

  public get education(): string | null {
    return this._education;
  }

  private _currentResidence: string | null = null;

  public set currentResidence(value: string | null) {
    this._currentResidence = value;
  }

  public get currentResidence(): string | null {
    return this._currentResidence;
  }

  private _originFrom: string | null = null;

  public set originFrom(value: string | null) {
    this._originFrom = value;
  }

  public get originFrom(): string | null {
    return this._originFrom;
  }

  private _ethnicGroup: string | null = null;

  public set ethnicGroup(value: string | null) {
    this._ethnicGroup = value;
  }

  public get ethnicGroup(): string | null {
    return this._ethnicGroup;
  }

  private _job: string | null = null;

  public set job(value: string | null) {
    this._job = value;
  }

  public get job(): string | null {
    return this._job;
  }

  private _hasChildren: string | null = null;

  public set hasChildren(value: string | null) {
    this._hasChildren = value;
  }

  public get hasChildren(): string | null {
    return this._hasChildren;
  }

  private _house: string | null = null;

  public set house(value: string | null) {
    this._house = value;
  }

  public get house(): string | null {
    return this._house;
  }

  private _hasBuyCar: string | null = null;

  public set hasBuyCar(value: string | null) {
    this._hasBuyCar = value;
  }

  public get hasBuyCar(): string | null {
    return this._hasBuyCar;
  }

  private _marriageStatus: string | null = null;


  public set marriageStatus(value: string | null) {
    this._marriageStatus = value;
  }

  public get marriageStatus(): string | null {
    return this._marriageStatus;
  }

  private _realNameAuth: string | null = null;

  public set realNameAuth(value: string | null) {
    this._realNameAuth = value;
  }

  public get realNameAuth(): string | null {
    return this._realNameAuth;
  }
}