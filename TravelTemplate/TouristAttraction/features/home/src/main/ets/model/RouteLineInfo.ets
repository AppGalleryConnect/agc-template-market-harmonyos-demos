import { AttractionInfo } from 'types'

export class RouteLineInfo {
  routeId: number = 0
  routeName: string = ''
  routeDistance: number = 0
  duration: number = 0
  attractionIds: number[] = []
  introduction: string = ''
  routeBanner: ResourceStr = ''
  labels: string[] = []
  attractionCount: number = 0
  attractions: AttractionInfo[] = []
  brief: string = ''
}