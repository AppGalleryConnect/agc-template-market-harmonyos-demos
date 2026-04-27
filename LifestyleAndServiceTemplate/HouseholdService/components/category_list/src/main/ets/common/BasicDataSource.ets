import { UtilLog } from '@hw-agconnect/util-log';
import { IGoodCategory } from 'module_base';

export class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: IGoodCategory[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  getAllData(): IGoodCategory[] {
    return this.originDataArray
  }

  public getData(index: number): IGoodCategory {
    return this.originDataArray[index];
  }

  addData(index: number, data: IGoodCategory): void {
    this.originDataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  pushData(data: IGoodCategory): void {
    this.originDataArray.push(data);
    this.notifyDataAdd(this.originDataArray.length - 1);
  }

  pushDataArray(...items: IGoodCategory[]): void {
    for (let data of items) {
      this.originDataArray.push(data);
      this.notifyDataAdd(this.originDataArray.length - 1);
    }
  }

  setData(dataArray?: IGoodCategory[]) {
    if (dataArray) {
      this.originDataArray = dataArray
    } else {
      this.originDataArray = []
    }
    this.notifyDataReload()
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      UtilLog.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      UtilLog.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload() {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  notifyDataChange(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number) {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
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
}