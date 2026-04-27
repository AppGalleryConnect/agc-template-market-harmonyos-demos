/**
 * 线路规划数据模型
 */
export interface RouteItem {
  id: string
  title: string
  days: number
  locations: number
  attractions: string[]
  coverImage: ResourceStr
  city: string
}

/**
 * 线路详情页参数
 */
export interface RouteDetailParams {
  route: RouteItem
}

export interface RouteListParams {
  city: string
  days: number
}

