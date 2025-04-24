import { BasicDataSource } from './BasicDataSource';

@ObservedV2
export class MyDataSource<T> extends BasicDataSource<T> {
  @Trace
  private _dataArray: T[] = [];

  public getDataArray(): T[] {
    return this._dataArray;
  }

  public totalCount(): number {
    return this._dataArray.length;
  }

  public getData(index: number): T {
    return this._dataArray[index];
  }

  public addData(index: number, data: T): void {
    this._dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: T): void {
    this._dataArray.push(data);
    this.notifyDataAdd(this._dataArray.length - 1);
  }

  public reloadData(): void {
    this.notifyDataReload();
  }

  public deleteOneData(index: number) {
    this._dataArray.splice(index, 1)
    this.notifyDataDelete(index);
  }

  public clear() {
    this._dataArray.splice(0, this._dataArray.length)
    this.notifyDataReload()
  }
}