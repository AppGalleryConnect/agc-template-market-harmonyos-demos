export class ListResp<T> {
  totalCount: number;
  returnCount: number;
  courseList: T[];

  constructor(totalCount, returnCount, list?: T[]) {
    this.totalCount = totalCount;
    this.returnCount = returnCount;
    this.courseList = list ?? [];
  }
}

module.exports = { ListResp };
