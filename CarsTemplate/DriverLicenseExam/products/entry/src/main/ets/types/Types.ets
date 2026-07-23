import { Video } from '@ohos_agcit/driver_license_exam_datasource';
import { LongTakeTransitionParam } from 'module_transition';

export interface TabListItem {
  label: string | Resource;
  icon: Resource;
  iconChecked: Resource;
}

export interface KEMUTabListItem {
  label: string | Resource;
}

export interface ServiceEntryItem {
  label: string | Resource;
  icon: Resource;
  tabIndex: number;
}

export interface SwiperBanner {
  imgUrl: Resource;
  href: string;
}

export interface MineServiceItem {
  label: Resource;
  icon: Resource;
  routePath: string;
}

export interface VideoDetailParam {
  video: Video;
  longTakeTransitionParam?: LongTakeTransitionParam;
}