export class RetBean {
  code: string;
  msg: string;

  constructor(retBean: any) {
    this.code = retBean?.code;
    this.msg = retBean?.msg;
  }
}