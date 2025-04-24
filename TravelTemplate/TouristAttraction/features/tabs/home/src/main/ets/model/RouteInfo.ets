import { AttractionInfo } from 'types'

export class RouteInfo {
  routeId: number = 0
  routeName: string = '';
  routeDistance: number = 0;
  duration: number = 0;
  attractions: AttractionInfo[] = [];
  routeBanner: string = ''
}