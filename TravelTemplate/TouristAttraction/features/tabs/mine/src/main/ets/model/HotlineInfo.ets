export interface HotlineInfo {
  id: HotlineType;
  title: ResourceStr;
  phone: string;
}

enum HotlineType {
  COUNSELING = 0,
  RESCUE = 1,
  COMPLAINTS = 2
}

export const HOTLINE_DATA: HotlineInfo[] = [
  {
    id: HotlineType.COUNSELING,
    title: '咨询电话',
    phone: '',
  }, {
  id: HotlineType.RESCUE,
  title: '救援电话',
  phone: '',
}, {
  id: HotlineType.COUNSELING,
  title: '投诉电话',
  phone: '',
}];