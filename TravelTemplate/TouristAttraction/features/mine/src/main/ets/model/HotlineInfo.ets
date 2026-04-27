import { HotlineUtil } from 'common';

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

export const hotlines: HotlineInfo[] = [
  {
    id: HotlineType.COUNSELING,
    title: '咨询电话',
    phone: HotlineUtil.getConsultPhone(),
  },
  {
    id: HotlineType.RESCUE,
    title: '救援电话',
    phone: HotlineUtil.getRescuePhone(),
  },
  {
    id: HotlineType.COUNSELING,
    title: '投诉电话',
    phone: HotlineUtil.getComplaintPhone(),
  }];