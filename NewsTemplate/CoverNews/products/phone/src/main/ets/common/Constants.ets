import { TabBarType, TabItemModel } from '../models/TabModel';

export const TAB_LIST: TabItemModel[] = [
  {
    id: TabBarType.HOME,
    label: $r('app.string.tab_home'),
    icon: $r('app.media.ic_home_home_grey'),
    iconSelected: $r('app.media.ic_home_home_highlight'),
  },
  {
    id: TabBarType.MINE,
    label: $r('app.string.tab_mine'),
    icon: $r('app.media.ic_public_person'),
    iconSelected: $r('app.media.ic_public_person_highlight'),
  },
];