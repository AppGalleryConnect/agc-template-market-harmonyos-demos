export class ListResp<T> {
  totalCount: number;
  returnCount: number;
  list: T[];

  constructor(totalCount, returnCount, list: T[]) {
    this.totalCount = totalCount;
    this.returnCount = returnCount;
    this.list = list;
  }
}

module.exports = { ListResp };
