export class BasicDataSource<T> implements IDataSource {
  private listeners: DataChangeListener[] = [];
  private originDataArray: T[] = [];

  public totalCount(): number {
    return 0;
  }

  public getData(index: number): T {
    return this.originDataArray[index];
  }

  registerDataChangeListener(registerChangeListener: DataChangeListener): void {
    if (this.listeners.indexOf(registerChangeListener) < 0) {
      this.listeners.push(registerChangeListener);
    }
  }

  unregisterDataChangeListener(unregisterChangeListener: DataChangeListener): void {
    const position = this.listeners.indexOf(unregisterChangeListener);
    if (position >= 0) {
      this.listeners.splice(position, 1);
    }
  }

  notifyDataReload(): void {
    this.listeners.forEach(ele => {
      ele.onDataReloaded();
    })
  }

  notifyDataAdd(numberIndex: number): void {
    this.listeners.forEach(ele => {
      ele.onDataAdd(numberIndex);
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
}