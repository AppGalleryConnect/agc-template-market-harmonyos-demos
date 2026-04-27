import { media } from '@kit.MediaKit';
const TAG = '[VideoPlayDataSource]'
/**
 * 视频播放数据,提供给video player使用
 */
export interface VideoPlayData {
  getUrl(): string | media.AVFileDescriptor
  getPlayTime():number
  getPic(): ResourceStr
  getType(): number
}

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

@ObservedV2
export class VideoPlayDataSource extends BasicDataSource {
  @Trace videoList: Array<VideoPlayData> = [];

  // 获取数组长度
  public totalCount(): number {
    return this.videoList.length;
  }

  // 获取指定索引数据
  public getData(index: number): VideoPlayData {
    return this.videoList[index];
  }

  // 改变单个数据
  public addData(index: number, data: VideoPlayData): void {
    this.videoList.splice(index, 0, data);
    this.notifyDataAdd(index);
  }

  // 添加数据
  public pushData(data: VideoPlayData): void {
    this.videoList.push(data);
    this.notifyDataAdd(this.videoList.length - 1);
  }

  // 替换所有数据
  public replaceData(data: Array<VideoPlayData>): void {
    this.videoList = data.slice();
    this.notifyDataReload();
  }

  public deleteData(index: number): void {
    if (index >= 0 && index < this.videoList.length) {
      this.videoList.splice(index, 1);
      this.notifyDataDelete(index);
    }
  }

  // 清空所有数据
  public clearData(): void {
    this.videoList.splice(0, this.videoList.length);
    this.notifyDataReload();
  }
}
