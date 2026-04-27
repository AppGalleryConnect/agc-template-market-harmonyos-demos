import { window } from '@kit.ArkUI';

export enum RouterType{
  PUSH,
  POP,
  REPLACE
}

export class BaseRouterOption {
  routerType?: RouterType
  styleOption?: StyleOption;
  userOption?: UserOption;
  eventOption?: EventOption;
}

export class NavRouterOption extends BaseRouterOption {
  // builder name
  builderName?: string;
  // 页面间跳转传递的数据
  params?: object;
  popCallback?: (popInfo: any) => void
}

export type StyleOption = {
  animated?: boolean;
  systemBarStyle?: window.SystemBarProperties; // 进入页面可设置状态栏的文字颜色
  restoreSystemBarStyle?:boolean; // 关闭页面时是否需要恢复状态栏
};

export type UserOption = {
  needLogin?: boolean;
  needRealNameAuth?: boolean
};

export type EventOption = {
  eventId?: string;
  eventParams?: { [key: string]: string };
};