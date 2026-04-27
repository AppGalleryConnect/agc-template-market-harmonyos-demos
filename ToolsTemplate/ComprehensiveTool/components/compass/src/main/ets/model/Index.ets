@ObservedV2
export class CompassItem {
  @Trace id: number;
  @Trace name: ResourceStr;

  constructor(id: number, name: ResourceStr) {
    this.id = id;
    this.name = name;
  }

  update(item: CompassItem) {
    this.id = item.id;
    this.name = item.name;
  }
}

export interface MountainInfo {
  name: string;
  center: number; // 中心角度
  start: number; // 开始角度
  end: number; // 结束角度
}