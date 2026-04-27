import { DateModel, DateModelList } from './DateModel';

// Basic implementation of IDataSource to handle data listener
class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: DateModelList[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): DateModelList {
    return this.originDataArray[index];
  }

  // 该方法为框架侧调用，为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  // 该方法为框架侧调用，为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    })
  }

  // 通知LazyForEach组件将from索引和to索引处的子组件进行交换
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

export class DateListSource extends BasicDataSource {
  private dataArray: DateModelList[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public clearArray() {
    this.dataArray = [];
  }

  public getData(index: number): DateModelList {
    return this.dataArray[index];
  }

  public addData(index: number, data: DateModelList): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDatasetChange([
      { type: DataOperationType.ADD, index, count: 1 },
    ])
  }

  public addDataFromHead(data: DateModelList): void {
    this.dataArray.splice(0, 0, data);
    this.notifyDatasetChange([
      { type: DataOperationType.ADD, index: 0, count: 1 },
    ])
  }

  public pushData(data: DateModelList): void {
    this.dataArray.push(data);
    this.notifyDatasetChange([
      { type: DataOperationType.ADD, index: this.dataArray.length - 1, count: 1 },
    ])
  }

  public clearData(): void {
    while (this.dataArray.length) {
      this.dataArray.pop()
    }
  }

  public findDate(info: DateModel): number {
    let dateIndex = this.dataArray.findIndex(value => {
      let findList = value.filter(item => item.dateStr === info.dateStr && item.isToMonth)
      return findList.length
    })
    return dateIndex
  }
}