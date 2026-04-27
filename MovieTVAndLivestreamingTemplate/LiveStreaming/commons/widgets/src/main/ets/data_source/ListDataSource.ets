import { Logger } from '@agctemplate/utils';
import { PageStateKind } from '../const/PageStateKind';


export interface PageResult {
  resultOk: boolean,
  curPageData: Object[],
  totalCount: number,
  reqId?: string
}

const TAG = 'ListDataSource'

export abstract class ListDataSource implements IDataSource {
  requestId?: string; // 请求id，用于舍弃旧请求
  listeners: DataChangeListener[] = [];
  pageIndex: number = 1;
  pageDataTotalCount?: number;
  pageState: PageStateKind = PageStateKind.LOADING;
  isCurPageLoading: boolean = false;
  isCurPageLoadFail: boolean = false;
  isResetIndexOneData: boolean = true //是否重置第一页数据
  isUseEmptyPageState: boolean = false //空数据是否使用自定义空页面
  private pageData: Object[] = [];

  public abstract getNextPageDataFromServer(): Promise<boolean>;

  public async innerGetNextPageDataFromServer(request: () => Promise<PageResult>): Promise<boolean> {
    this.isCurPageLoading = true;
    if (!this.isAllDataGet()) {
      try {
        Logger.info(TAG, `request start reqId is ${this.requestId}`);
        let response = await request();
        Logger.info(TAG, `request finish reqId is ${this.requestId}`);
        Logger.info(TAG, `response reqId is ${response.reqId}`);
        if (this.pageIndex === 1 && response.reqId !== this.requestId) {
          // 用于多次点击查询时，保证展示的是最后一次查询的请求
          Logger.warn(TAG, `response reqId ${response.reqId} dropped`);
          return false;
        }
        if (!response.resultOk) {
          this.loadServerError();
          this.isCurPageLoading = false;
          return false;
        }
        this.addData(response.curPageData || []);
        if (this.pageIndex === 1) {
          this.pageDataTotalCount = response.totalCount ?? 0;
          if (this.pageDataTotalCount === 0) {
            this.pageState = this.isUseEmptyPageState ? PageStateKind.EMPTY_PAGE : PageStateKind.NO_RESULT;
          } else {
            this.pageState = PageStateKind.CONTENT;
          }
        }
        this.pageIndex++;
        this.isCurPageLoadFail = false;
        this.isCurPageLoading = false;
        return true;
      } catch (error) {
        Logger.error(TAG, `getListData error: ${error.message}`)
        this.loadServerError();
        this.isCurPageLoading = false;
      }
    }
    return false;
  }

  public isAllDataGet() {
    // 数据全部加载
    return this.pageDataTotalCount !== undefined &&
      (this.pageDataTotalCount === 0 || this.pageData.length >= this.pageDataTotalCount);
  }

  public reset(): void {
    this.pageData = [];
    this.pageIndex = 1;
    this.pageDataTotalCount = undefined;
    this.pageState = PageStateKind.LOADING;
    this.isCurPageLoading = false;
    this.isCurPageLoadFail = false;
    this.notifyDataReload();
  }

  public getPageData(): Object[] {
    return this.pageData
  }

  public setPageData(pageData: Object[]): void {
    this.pageData = pageData ?? [];
    this.notifyDataReload();
  }

  private loadServerError() {
    if (this.pageIndex === 1) {
      // 如果第一次加载就失败
      this.pageState = PageStateKind.LOADING_FAIL;
    }
    // 非第一次加载时失败，只进行底部刷新
    this.isCurPageLoadFail = true;
  }

  // 全部数量
  allDataCount(): number {
    return this.pageDataTotalCount ?? 0;
  }

  // 当前已获得的数量
  totalCount(): number {
    return this.pageData.length;
  }

  getData(index: number): Object {
    return this.pageData[index];
  }

  updateData(index: number, data: Object): boolean {
    if (this.pageData.length && index >= 0 && index < this.pageData.length) {
      this.pageData[index] = data;
      this.notifyDataChange(index);
      return true;
    }
    return false
  }

  addData(appendData: Object[]): void {
    if (this.isResetIndexOneData && this.pageIndex === 1) {
      this.setPageData([]);
    }
    this.pageData.push(...appendData);
    for (let i = this.pageData.length - appendData.length; i < this.pageData.length; i++) {
      this.notifyDataAdd(i);
    }
  }

  deleteData(index: number): void {
    this.pageData.splice(index, 1);
    if (this.pageDataTotalCount !== undefined) {
      this.pageDataTotalCount -= 1;
    }
    this.notifyDataDelete(index);
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const position = this.listeners.indexOf(listener);
    if (position >= 0) {
      this.listeners.splice(position, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知控制器数据变化
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  // 通知控制器数据删除
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  // 通知控制器数据位置变化
  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }

  //通知控制器数据批量修改
  notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange(operations);
    })
  }
}
