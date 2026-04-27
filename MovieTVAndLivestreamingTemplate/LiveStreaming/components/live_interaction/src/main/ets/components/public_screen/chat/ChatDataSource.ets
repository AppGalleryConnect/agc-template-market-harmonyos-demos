import { BaseChatMessage } from './BaseChatMesage';

/**
 * IDataSource处理数据监听的基本实现
 */
export abstract class BasicDataSource implements IDataSource {
  private listeners: DataChangeListener[] = [];

  // 获取数组长度
  public abstract totalCount(): number;

  // 获取指定索引数据
  public getData(index: number): void {
  }

  // 为LazyForEach组件向其数据源处添加listener监听
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  // 为对应的LazyForEach组件在数据源处去除listener监听
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  // 通知LazyForEach组件需要重载所有子组件
  notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  // 通知LazyForEach组件需要在index对应索引处添加子组件
  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }

  // 通知LazyForEach组件在index对应索引处数据有变化，需要重建该子组件
  notifyDataChange(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataChange(index);
    })
  }

  // 通知LazyForEach组件需要在index对应索引处删除该子组件
  notifyDataDelete(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataDelete(index);
    })
  }
}

export class ChatDataSource extends BasicDataSource {
  private data: BaseChatMessage[] = [];

  public totalCount(): number {
    return this.data.length;
  }

  /**
   * 获取指定索引数据
   * @param index
   * @returns
   */
  public getData(index: number): BaseChatMessage {
    return this.data[index];
  }

  /**
   * 改变单个数据
   * @param index
   * @param data
   */
  public addData(index: number, data: BaseChatMessage): void {
    this.data.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  public addDataList(appendData: BaseChatMessage[]): void {
    this.data.push(...appendData);
    for (let i = this.data.length - appendData.length; i < this.data.length; i++) {
      this.notifyDataAdd(i);
    }
  }

  /**
   * 添加数据
   * @param data
   */
  public pushData(data: BaseChatMessage): void {
    this.data.push(data);
    this.notifyDataAdd(this.data.length - 1);
  }

  public removeData(index: number, size: number) {
    this.data.splice(index, size);
    this.notifyDataReload()
  }
}