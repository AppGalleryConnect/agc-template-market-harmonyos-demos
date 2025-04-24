export interface ManagementInfo {
  id: ManagementType;
  title: ResourceStr;
  icon: ResourceStr;
  click: (event: ClickEvent) => void;
}

export enum ManagementType {
  ADDRESSES = 0,
  TOURISTS = 1,
  HOTLINES = 2
}

export enum ManagementPath {
  ADDRESSES_PAGE = 'Addresses',
  TOURISTS_PAGE = 'TouristsPage',
  HOTLINES_PAGE = 'Hotlines'
}

export function getManagementModuleInfo(pathStack: NavPathStack) {
  return [
    {
      id: ManagementType.TOURISTS,
      title: '常用旅客',
      icon: $r('app.media.tourists_manage'),
      click: () => {
        pathStack.pushPathByName(ManagementPath.TOURISTS_PAGE, null);
      },
    },
    {
      id: ManagementType.ADDRESSES,
      title: '我的地址',
      icon: $r('app.media.address_manage'),
      click: () => {
        pathStack.pushPathByName(ManagementPath.ADDRESSES_PAGE, false);
      },
    },
    {
      id: ManagementType.HOTLINES,
      title: '服务热线',
      icon: $r('app.media.hotlines'),
      click: () => {
        pathStack.pushPathByName(ManagementPath.HOTLINES_PAGE, null);
      },
    },
  ] as ManagementInfo[];
}