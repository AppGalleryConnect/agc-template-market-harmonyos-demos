export interface CommodityTabBarData {
  type: CommodityTabBarType;
  title: ResourceStr;
}

export enum CommodityTabBarType {
  SPECIAL = 0,
  CULTURE = 1,
}

export const COMMODITY_TABS_INFO: CommodityTabBarData[] = [
  {
    type: CommodityTabBarType.SPECIAL,
    title: '特色商品',
  },
  {
    type: CommodityTabBarType.CULTURE,
    title: '文旅商品',
  }
]