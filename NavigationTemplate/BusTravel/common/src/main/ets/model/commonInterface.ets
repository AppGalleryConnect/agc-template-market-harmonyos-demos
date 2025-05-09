/*
tabInfo interface
*/
import { Callback } from '@ohos.base'

export interface TabInfo {
  index: number
  name?: string
  label?: Resource
  activeIcon?: Resource
  defaultIcon?: Resource
  flag?: boolean //首页tab悬浮标识
  component?: WrappedBuilder<[]>
}

/*
 * NavRouterInfo
 * */

export interface NavRouterInfo {
  url: string, // 需要跳转的路由名
  mode?: NavDestinationMode, // NavDestination类型
  param?: ESObject, // 跳转传参
  page?: ESObject;
  onPop?: Callback<PopInfo> // 回调函数
}

export interface SearchSet {
  lineName: string;
  startStation: string;
  endStation: string;
  coordX: number;
  coordY: number;
  stationName: string;
  sequence: number
}

export interface LineSet {
  lineName: string;
  startStation: string;
  endStation: string;
  lon: number;
  lat: number;
  orders: number
}


