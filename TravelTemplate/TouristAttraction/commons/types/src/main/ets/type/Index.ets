import { AddressInfo } from './AddressInfo';

@ObservedV2
export class UserInfo {
  @Trace avatar: string = '';
  @Trace phone: string = '';
  @Trace nickname: string = '';
  @Trace gender: number = 2;
  @Trace birthday: string = '';
}

@ObservedV2
export class HuaweiAccountInfo {
  @Trace idToken?: string = '';
  @Trace openID?: string = '';
  @Trace unionID?: string = '';
  @Trace signOpenID?: string = '';
  @Trace authCode?: string = '';
  @Trace loginToken?: string = '';
}

@ObservedV2
export class ContactInfo {
  @Trace consult: string = '';
  @Trace rescue: string = '';
  @Trace complain: string = '';
}

@ObservedV2
export class LocationInfo {
  longitude: number = 0;
  latitude: number = 0;
}

export const cardTypeOptions = [
  '身份证',
];

export enum DeleteItems {
  Address = 0,
  Tourist = 1
}

export const enum AppStorageMap {
  ATTRACTION_LIST = 'attractionList',
  CATERING_LIST = 'cateringList',
  ACCOMMODATION_LIST = 'accommodationList',
  TOILET_LIST = 'toiletList'
}

export enum TabBarType {
  HOME = 0,
  TICKET = 1,
  GUIDE = 2,
  ORDER = 3,
  MINE = 4
}

export class FuncObj {
  deleteFunc: (id: string, func: () => void) => void = () => {
  };
  reloadFunc: () => void = () => {
  };
  id: string = '';

  constructor(deleteFunc: (id: string, func: () => void) => void, reloadFunc: () => void, id: string) {
    this.deleteFunc = deleteFunc;
    this.reloadFunc = reloadFunc;
    this.id = id;
  }
}

export class Params {
  deleteFunc: (id: string) => void = () => {
  };
  id: string = '';
  list: AddressInfo[] = [];

  constructor(deleteFunc: (id: string) => void, id: string, list: AddressInfo[]) {
    this.deleteFunc = deleteFunc;
    this.id = id;
    this.list = list;
  }
}

export class Page {
  index: number = 0;
}

