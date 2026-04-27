export class PageReq {
  pageSize: number;
  pageNum: number;

  constructor(pageReq: any) {
    this.pageSize = pageReq?.pageSize
    this.pageNum = pageReq?.pageNum
  }
}