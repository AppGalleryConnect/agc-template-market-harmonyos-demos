export class TokenReq {
  authorizeCode: string;

  constructor(tokenReq: any) {
    this.authorizeCode = tokenReq?.authorizeCode
  }
}