import { ModelItemContentInfo } from '../types/Index';

export class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: ModelItemContentInfo[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  getAllData(): ModelItemContentInfo[] {
    return this.originDataArray
  }

  public getData(index: number): ModelItemContentInfo {
    return this.originDataArray[index];
  }

  addData(index: number, data: ModelItemContentInfo): void {
    this.originDataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  pushData(data: ModelItemContentInfo): void {
    this.originDataArray.push(data);
    this.notifyDataAdd(this.originDataArray.length - 1);
  }

  pushDataArray(...items: ModelItemContentInfo[]): void {
    for (let data of items) {
      this.originDataArray.push(data);
      this.notifyDataAdd(this.originDataArray.length - 1);
    }
  }

  notifyDataReload() {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  notifyDataAdd(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  notifyDataDelete(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  notifyDataChange(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataMove(from: number, to: number) {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
  }

  notifyDatasetChange(operations: DataOperation[]) {
    this.listeners.forEach(listener => {
      listener.onDatasetChange(operations);
    });
  }

  setData(dataArray?: ModelItemContentInfo[]) {
    if (dataArray) {
      this.originDataArray = dataArray
    } else {
      this.originDataArray = []
    }
    this.notifyDataReload()
  }
}