import { Type } from '@kit.ArkUI';

export interface AirConditionInfo {
  id: string,
  brand: string,
  infraredList: InfraredInfo[]
}

export interface InfraredInfo {
  label: string,
  id: string,
  frequency: number,
  pattern: string
}

// 空调品牌
export interface BrandNameInfo {
  brandId: string,
  name: string,
  translation: string
}

// 首字母分类
export interface BrandGroupItem {
  firstName: string,
  group: BrandNameInfo[]
}

export enum WindSpeed {
  AUTO = '0',
  SLOW = '1',
  MIDDLE = '2',
  FAST = '3'
}

export enum WindDirection {
  UP = '0',
  CENTER = '1',
  BOTTOM = '2',
  AUTO = '3'
}

export enum WindMode {
  AUTO = '0',
  MANUAL = '1'
}

export enum RunMode {
  //  自动
  AUTO = '0',
  //  制热
  HOT = '1',
  //  制冷
  COLD = '2',
  //  通风
  WIND = '3',
  //  除湿
  DRY = '4'
}

@ObservedV2
export class AreaType {
  @Trace top: number = 0;
  @Trace bottom: number = 0;
}

// 遥控器信息
@ObservedV2
export class ControlInfo {
  @Trace id: string = '1';
  // 红外协议
  @Trace protocol: string = '';
  @Trace name: string = '空调';
  @Trace switchStatus: boolean = false;
  @Trace runMode: RunMode = RunMode.AUTO;
  @Trace temperature: number = 26;
  @Trace windSpeed: WindSpeed = WindSpeed.AUTO;
  @Trace windDirection: WindDirection = WindDirection.CENTER;
  @Trace windMode: WindMode = WindMode.AUTO;
  @Trace isScheduled: boolean = false;
  @Trace startTime: number = new Date().getTime();
  @Trace interval: number = 0;
  @Trace isSleep: boolean = false;

  constructor(id: string = '1', name: string = '空调', switchStatus: boolean = false, runMode: RunMode = RunMode.AUTO,
    temperature: number = 26,
    windSpeed: WindSpeed = WindSpeed.AUTO,
    windDirection: WindDirection = WindDirection.CENTER, windMode: WindMode = WindMode.AUTO,
    isScheduled: boolean = false, startTime: number = new Date().getTime(), interval: number = 0,
    isSleep: boolean = false, protocol: string = '') {
    this.id = id;
    this.name = name;
    this.switchStatus = switchStatus;
    this.runMode = runMode;
    this.temperature = temperature;
    this.windSpeed = windSpeed;
    this.windDirection = windDirection;
    this.windMode = windMode;
    this.isScheduled = isScheduled;
    this.startTime = startTime;
    this.interval = interval;
    this.isSleep = isSleep;
    this.protocol = protocol;
  }
}


// 创建的遥控器
@ObservedV2
export class MyControl {
  @Type(ControlInfo)
  @Trace list: ControlInfo[] = [];

  constructor(list: ControlInfo[] = []) {
    this.list = list;
  }

  addControl(data: ControlInfo) {
    this.list.push(data);
  }

  removeControl(id: string) {
    this.list = this.list.filter((item) => item.id !== id);
  }
}

export interface BrandParam {
  brandId: string,
  name: string
}

// 基本布局组件控制器
export class BaseLayoutController {
  switchClick = () => {

  };
  modeClick = () => {

  };
  windSpeedClick = () => {

  };
}
