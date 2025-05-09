export interface SwiperInterface {
  id:string;
  image: Resource
}

export interface newsItem {
  id:string;
  image: Resource;
  title: Resource;
  time: Resource;
}
export interface HotNewsSegmentInterface{
  id:string;
  image: Resource;
  title: Resource;
  time: Resource;
  visit: Resource;
}

export interface LostFindSegmentInterface{
  id: string;
  time: Resource;
  type: Resource;
  line: Resource;
  description: Resource;
  image: Resource;
}

export interface NewsDetailSegmentInterface{
  title: Resource;
  time: Resource;
  visit: Resource;
  image: Resource;
  subtitle: Resource;
  content: Resource;
}