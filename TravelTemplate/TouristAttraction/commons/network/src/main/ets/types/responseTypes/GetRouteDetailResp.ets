import { AttractionListItem } from './GetAttractionListResp';

export interface GetRouteLineDetailResp {
  routeId: number;
  routeName: string;
  routeDistance: number;
  duration: number;
  attractions: AttractionListItem[];
  introduction: string;
  routeBanner: ResourceStr;
  labels: string[];
  brief: string;
}

export interface GetRouteLineDetailsResp extends Array<GetRouteLineDetailResp> {}