export interface DishesItem {
  id: string,
  name: string,
  img: ResourceStr,
  avatar: ResourceStr,
  userName: string,
  collection: number
}

// 轮播图信息
export interface BannerItem {
  url: ResourceStr,
  dishName: string,
  desc: string
}

export interface TabItem {
  label: string,
  icon: ResourceStr
}