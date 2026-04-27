import { PageReq } from "./PageReq";

export class SearchPageReq extends PageReq {
  searchText: string = ''
  constructor(pageReq: any) {
    super({
      pageSize: pageReq?.pageSize,
      pageNum: pageReq?.pageNum
    })
    this.searchText = pageReq.category
  }
}