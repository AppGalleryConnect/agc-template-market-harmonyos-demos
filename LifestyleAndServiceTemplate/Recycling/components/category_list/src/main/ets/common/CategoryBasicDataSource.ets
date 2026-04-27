import { SubCategoryItem } from '../types/Index';

export class CategoryBasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: SubCategoryItem[] = [];

  public totalCount(): number {
    return this.originDataArray.length;
  }

  getAllData(): SubCategoryItem[] {
    return this.originDataArray
  }

  public getData(index: number): SubCategoryItem {
    return this.originDataArray[index];
  }

  addData(index: number, data: SubCategoryItem): void {
    this.originDataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  pushData(data: SubCategoryItem): void {
    this.originDataArray.push(data);
    this.notifyDataAdd(this.originDataArray.length - 1);
  }

  pushDataArray(...items: SubCategoryItem[]): void {
    for (let data of items) {
      this.originDataArray.push(data);
      this.notifyDataAdd(this.originDataArray.length - 1);
    }
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  setData(dataArray?: SubCategoryItem[]) {
    if (dataArray) {
      this.originDataArray = dataArray
    } else {
      this.originDataArray = []
    }
    this.notifyDataReload()
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
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