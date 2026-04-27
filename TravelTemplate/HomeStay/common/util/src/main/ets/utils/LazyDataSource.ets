import Logger from './Logger';
import { ObservedArray } from './ObservedArray';

const TAG = '[BasicDataSource]';

class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): T | undefined {
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      Logger.info(TAG, 'add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      Logger.info(TAG, 'remove listener');
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    });
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    });
  }

  notifyDataChange(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataChange(index);
    });
  }

  notifyDataDelete(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataDelete(index);
    });
  }

  notifyDataMove(from: number, to: number): void {
    this.listeners.forEach(listener => {
      listener.onDataMove(from, to);
    });
  }
}

@ObservedV2
export default class LazyDataSource<T> extends BasicDataSource<T> {
  dataArray: T[] = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public addLastItem() {
    this.dataArray.splice(this.dataArray.length, 0, this.dataArray[this.dataArray.length-1]);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public getData(index: number): T {
    return this.dataArray[index];
  }

  public addData(index: number, data: T): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: T): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public replaceData(replaceData: T): void {
    let index = this.dataArray.indexOf(replaceData);
    this.dataArray.splice(index, 1, replaceData);
    this.notifyDataReload();
  }

  public pushArrayData(newData: ObservedArray<T>): void {
    this.clear();
    this.dataArray.push(...newData);
    this.notifyDataReload();
  }

  public appendArrayData(addData: ObservedArray<T>): void {
    this.dataArray.push(...addData);
    this.notifyDataReload();
  }

  public deleteData(index: number): void {
    this.dataArray.splice(index, 1);
    this.notifyDataDelete(index);
  }

  public getDataList(): ObservedArray<T> {
    return this.dataArray;
  }

  public clear(): void {
    this.dataArray.splice(0, this.dataArray?.length);
  }

  public isEmpty(): boolean {
    return this.dataArray.length === 0;
  }
}
