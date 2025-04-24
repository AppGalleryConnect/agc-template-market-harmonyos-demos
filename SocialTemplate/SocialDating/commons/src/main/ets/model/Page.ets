export class Page{
  totalCount: number = 0;
  totalPages: number = 0;
  curPage: number =1;
  pageSize: number = 10;

  constructor(totalCount: number, totalPages: number, curPage: number, pageSize: number) {
    this.totalCount = totalCount;
    this.totalPages = totalPages;
    this.curPage = curPage;
    this.pageSize = pageSize;
  }
}
