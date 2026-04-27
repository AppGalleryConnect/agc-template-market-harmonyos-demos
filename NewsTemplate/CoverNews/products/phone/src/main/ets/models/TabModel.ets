export enum TabBarType {
  HOME = 0,
  MINE
}

export class TabItemModel {
  id: TabBarType = TabBarType.HOME;
  label: ResourceStr = '';
  icon: ResourceStr = '';
  iconSelected: ResourceStr = '';
}