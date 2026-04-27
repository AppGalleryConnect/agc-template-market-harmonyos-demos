import { Logger, NetConnectionUtil, SafeJson } from '@agctemplate/utils';
import { PageStateKind } from '../const/PageStateKind';
import { BottomStatus, ObservedWaterFlowData } from './observed/ObservedWaterFlowData';

export interface WaterFlowPageResult<T> {
  resultOk: boolean,
  curPageData: T[],
  totalCount: number,
  reqId?: string,
}

const TAG = 'WaterFlowDataSource'

export abstract class WaterFlowDataSource<T extends ObservedWaterFlowData> implements IDataSource {
  requestId?: string; // 请求id，用于舍弃旧请求
  enableBottomStatusView: boolean = false; // 是否展示WaterFlow底部状态
  dataPageStatus: PageStateKind = PageStateKind.LOADING; // 控制页面的加载中、内容展示、无内容等页面状态
  loadingObservedData: T;
  failObservedData: T;
  listeners: DataChangeListener[] = [];
  pageIndex: number = 1;
  pageDataTotalCount?: number;
  isCurPageLoading: boolean = false;
  isCurPageLoadFail: boolean = false;
  isUseEmptyPageState: boolean = false //空数据是否使用自定义空页面
  firstPageData: T[] = []; // 首页数据，需要保证firstPageData有值时size与每页请求数量相等
  pageData: T[] = []; // 总列表

  constructor(enableBottomStatusView: boolean, loadingObservedData: T,
    failObservedData: T) {
    this.enableBottomStatusView = enableBottomStatusView;
    this.loadingObservedData = loadingObservedData;
    this.failObservedData = failObservedData;
  }

  public abstract getNextPageDataFromServer(): Promise<boolean>;

  public async innerGetNextPageDataFromServer(request: () => Promise<WaterFlowPageResult<T>>): Promise<boolean> {
    if (this.pageIndex === 1) {
      this.pageDataTotalCount = undefined;
    }
    this.updateStatus(true, false);
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
          if (this.pageIndex === 1) {
            this.pageData = [];
            this.pageDataTotalCount = response.totalCount ?? 0;
          }
          this.updateStatus(false, true);
          return false;
        }
        this.addData(response.curPageData);
        if (this.pageIndex === 1) {
          this.pageDataTotalCount = response.totalCount ?? 0;
        }
        this.updateStatus(false, false);
        this.pageIndex++;
        return true;
      } catch (error) {
        Logger.error(TAG, `getListData error: ${SafeJson.ohAegJsonStringify(error)}`)
        this.updateStatus(false, true);
      }
    }
    return false;
  }

  public isAllDataGet(): boolean {
    // 数据全部加载
    if (this.pageDataTotalCount !== undefined) {
      if (this.pageDataTotalCount === 0) {
        return true;
      }
      if (this.pageData.length && this.pageData[this.pageData.length - 1].bottomStatus !== BottomStatus.NONE) {
        return this.pageData.length > this.pageDataTotalCount;
      }
      return this.pageData.length >= this.pageDataTotalCount;
    }
    return false;
  }

  public reset(): void {
    this.pageData = [];
    this.pageIndex = 1;
    this.pageDataTotalCount = undefined;
    this.updateStatus(true, false);
    this.notifyDataReload();
  }

  public getPageData(): T[] {
    return this.pageData
  }

  public getFirstPageData(): T[] {
    return this.firstPageData;
  }

  protected setFirstPageData(pageData: T[]): void {
    this.firstPageData = pageData;
  }

  protected updateStatus(isLoading: boolean, isFail: boolean): void {
    if (!NetConnectionUtil.getInstance().isNetworkAvailable()) {
      this.dataPageStatus = PageStateKind.NETWORK_ERROR;
      return;
    }
    this.isCurPageLoadFail = isFail;
    this.isCurPageLoading = isLoading;
    this.updatePageStatus();
    this.updateBottomStatus();
  }

  private updatePageStatus(): void {
    // 判断
    if (this.firstPageData.length || this.pageData.length) {
      // 有值
      this.dataPageStatus = PageStateKind.CONTENT;
      return;
    }
    if (this.isCurPageLoading) {
      this.dataPageStatus = PageStateKind.LOADING;
      return;
    }
    if (this.isCurPageLoadFail) {
      this.dataPageStatus = PageStateKind.LOADING_FAIL;
      return;
    }

    if (this.isUseEmptyPageState) {
      this.dataPageStatus = PageStateKind.EMPTY_PAGE;
      return;
    }

    this.dataPageStatus = PageStateKind.NO_RESULT;
  }

  private updateBottomStatus(): void {
    if (!this.enableBottomStatusView || this.dataPageStatus !== PageStateKind.CONTENT) {
      // 如果没有内容展示
      return;
    }
    if (this.pageData.length > 1) {
      // 如果最后一个数据已经是一个状态item
      if (this.pageData[this.pageData.length - 1].bottomStatus !== BottomStatus.NONE) {
        // 在尾部替换状态item
        this.isCurPageLoading ? this.pageData.splice(-1, 1, this.loadingObservedData) :
          (this.isCurPageLoadFail ? this.pageData.splice(-1, 1, this.failObservedData) : this.pageData.splice(-1, 1))
        this.notifyDataChange(this.pageData.length - 1);
      } else {
        // 在尾部追加状态item
        if (this.isCurPageLoading) {
          this.pageData.push(this.loadingObservedData);
          this.notifyDataAdd(this.pageData.length - 1);
        } else if (this.isCurPageLoadFail) {
          this.pageData.push(this.failObservedData);
          this.notifyDataAdd(this.pageData.length - 1);
        }
      }
    }
  }

  // 当前已获得的数量
  totalCount(): number {
    if (this.pageData.length) {
      return this.pageData.length;
    }
    return this.firstPageData.length;
  }

  getData(index: number): T {
    if (this.pageData.length) {
      return this.pageData[index];
    }
    return this.firstPageData[index];
  }

  private addData(appendData: T[]): void {
    if (this.enableBottomStatusView && this.pageData.length &&
      this.pageData[this.pageData.length - 1].bottomStatus !== BottomStatus.NONE) {
      // 删除尾部状态
      this.pageData.pop();
      this.notifyDataDelete(this.pageData.length);
    }
    if (this.pageIndex === 1) {
      this.pageData = [];
      this.notifyDataReload();
    }
    this.pageData = [...this.pageData, ...appendData];
    if (this.pageIndex === 1) {
      if (this.firstPageData.length) {
        this.notifyDataReload();
        return;
      }
      for (let i = 0; i < this.pageData.length; i++) {
        this.notifyDataAdd(i);
      }
      return;
    }
    for (let i = this.pageData.length - appendData.length; i < this.pageData.length; i++) {
      this.notifyDataAdd(i);
    }
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
