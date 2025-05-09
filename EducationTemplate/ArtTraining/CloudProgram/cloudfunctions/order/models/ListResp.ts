export class ListResp<T> {
  totalCount: number;
  returnCount: number;
  orderList: T[];

  constructor(totalCount, returnCount, list?: T[]) {
    this.totalCount = totalCount;
    this.returnCount = returnCount;
    this.orderList = list ?? [];
  }
}

module.exports = { ListResp };
