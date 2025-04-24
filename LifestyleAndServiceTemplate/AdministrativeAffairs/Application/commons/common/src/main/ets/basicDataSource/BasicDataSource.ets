class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): T {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
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

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  notifyDatasetChange(operations: DataOperation[]): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange(operations);
    })
  }
}

export class LazyDataSource<T> extends BasicDataSource<T> {
  private dataArray: T[] = [];
  private originalDataArray: T[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): T {
    return this.dataArray[index];
  }

  /**
   * 清除数据
   * selectNumber:医院等级
   */
  public clearData() {
    this.dataArray = []
  }

  /**
   * 过滤
   * selectNumber:医院等级
   */
  public filterData(selectNumber: number) {
    this.dataArray = selectNumber ?
    this.originalDataArray.filter((item: ESObject) => item.level === selectNumber) : this.originalDataArray
    this.notifyDataReload()
  }

  /**
   * 过滤classifieds
   * 便民服务
   */
  public filterClassifieds(selectList: string[]) {
    this.dataArray = selectList.length ?
    this.originalDataArray.filter((item: ESObject) => {
      return selectList.every((element: string) => {
        return item.classifieds.some((value: Record<string, string>) => value.name === element) as boolean
      }) as boolean
    }) :
    this.originalDataArray
    this.notifyDataReload()
  }

  /**
   * 筛选
   * searchValue:搜索关键词
   */
  public searchData(searchValue: string) {
    this.dataArray = searchValue ?
    this.originalDataArray.filter((item: ESObject) => item.name.includes(searchValue) as boolean) :
    this.originalDataArray
    this.notifyDataReload()
  }

  public pushData(data: T): void {
    this.dataArray.push(data);
    this.originalDataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }
}