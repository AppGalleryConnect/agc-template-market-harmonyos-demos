import { NewsData } from './NewsData';

export class NewsDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];
  public dataArray: Array<NewsData> = [];

  public totalCount(): number {
    return this.dataArray.length;
  }

  public getData(index: number): NewsData {
    return this.dataArray[index];
  }

  public addData(index: number, data: NewsData): void {
    this.dataArray.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public pushData(data: NewsData): void {
    this.dataArray.push(data);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  public clear(): void {
    this.dataArray = [];
  }

  // Add a listener to the data source of the LazyForEach component.
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // Disable the listener for the corresponding LazyForEach component at the data source.
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // Notify the LazyForEach component that all subcomponents need to be reloaded.
  notifyDataReload(): void {
    this.listeners.forEach(listener => {
      listener.onDataReloaded();
    })
  }

  // Notify the LazyForEach component that a subcomponent needs to be added to the index.
  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // Notify the LazyForEach component that a subcomponent needs to be added to the index.
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
}
