/**
 * 坐标信息
 */
export interface IPosition {
  latitude: number,
  longitude: number
}

/**
 * 物品信息
 */
export interface IGoods {
  id: number,
  name: string,
  weight: number,
  volume?: number,
  count?: number,
}

// 快递公司
export interface ICompany {
  id: number,
  name: string,
  value: string,
  price: number,
}

// 服务点
export interface IServicePoint {
  id: number,
  name: string,
  image: string,
  title: string,
  tips: string[],
  distance: string,
  positionName: string,
  position: IPosition,
}
