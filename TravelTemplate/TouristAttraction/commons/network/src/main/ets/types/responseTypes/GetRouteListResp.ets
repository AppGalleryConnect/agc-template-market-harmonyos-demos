export interface RouteLineListItem {
  routeId: number
  routeName: string
  routeDistance: number
  duration: number
  routeBanner: ResourceStr,
  attractionIds: number[],
  brief?: string
}

export interface GetRouteLineListResp extends Array<RouteLineListItem> {}