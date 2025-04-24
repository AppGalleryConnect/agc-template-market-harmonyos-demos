export class DataUtil {
  /**
   * 替换元素解决List中的元素改变后UI不刷新的问题
   */
  public static replaceListItem<T>(list: T[], index: number, item: T): void {
    list.splice(index, 1, item)
  }

  /**
   * 将一个列表中的object对象转换成具体的类型
   *
   * @param list 待添加的列表
   * @param items object对象列表
   * @param itemConstructor 构造具体类型对象的方法
   */
  public static pushItems<T>(list: T[], items: object[], itemConstructor: () => T, clearList: boolean = true): void {
    if (clearList) {
      list.length = 0
    }

    for (let item of items) {
      list.push(this.copyObject(itemConstructor(), item as T))
    }
  }

  public static copyObject<T>(target: T, source: T): T {
    return Object.assign(target, source) as T
  }
}