import { LoginType } from '../common/Constant';

export class Channel {
  type: LoginType;
  name: string;
  icon: ResourceStr;
  click?: ESObject;
  extraInfo: ExtraInfo;

  constructor(type: LoginType, name: string, extraInfo: ExtraInfo, icon: ResourceStr, click?: ESObject) {
    this.type = type;
    this.name = name;
    this.icon = icon;
    this.click = click;
    this.extraInfo = extraInfo;
  }
}

export class ExtraInfo {
  appId: string = '';
  scope?: string;
  transaction?: string;
  state?: string;
}

export interface TypeInfo {
  type: LoginType,
  pathInfos: NavPathStack,
  extraInfo: ExtraInfo
}