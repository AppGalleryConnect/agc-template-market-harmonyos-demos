import { IBaseStore } from 'utils';

export class StoreDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: IBaseStore[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  public getData(index: number): IBaseStore {
    return this.originDataArray[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  notifyDataAdd(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.ADD, index, count }]);
    })
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    })
  }

  notifyDataDelete(index: number, count: number): void {
    this.listeners.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.DELETE, index, count }]);
    })
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    })
  }

  // 在数组末尾，批量插入数据
  batchPushData(data: IBaseStore[]): void {
    const index = this.originDataArray.length;
    this.originDataArray.splice(index, 0, ...data);
    this.notifyDataAdd(index, data.length);
  }
}