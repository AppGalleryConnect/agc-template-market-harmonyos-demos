export class CommonRsp{
  retCode:number;

  retMsg:string|null;

  constructor(retCode: number, retMsg: string | null) {
    this.retCode = retCode;
    this.retMsg = retMsg;
  }
}
