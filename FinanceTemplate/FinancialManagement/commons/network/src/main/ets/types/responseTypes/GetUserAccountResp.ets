export interface IUserAccount {
  id: number,
  userId: number,
  bankName: string,
  bankCardNo: string,
  bankAmount: number,
  positionAmount: number, //持仓总金额
  accumulatedEarnings: number, //累计收益
}