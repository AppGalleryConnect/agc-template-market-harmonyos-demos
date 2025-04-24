export interface RouteLineListItem {
  routeId: number
  routeName: string
  routeDistance: number
  duration: number
  routeBanner: ResourceStr,
  attractionIds: number[],
}

export interface GetRouteLineListResp extends Array<RouteLineListItem> {}