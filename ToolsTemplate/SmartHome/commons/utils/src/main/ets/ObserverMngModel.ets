
export class ObserverMngModel<T> {
  protected observers: T[] = []

  public registerObserver(observer: T): void {
    this.observers.push(observer)
  }

  public removeObserver(observer: T): void {
    const index = this.observers.indexOf(observer)
    if (index !== -1) {
      this.observers.splice(index, 1)
    }
  }
}