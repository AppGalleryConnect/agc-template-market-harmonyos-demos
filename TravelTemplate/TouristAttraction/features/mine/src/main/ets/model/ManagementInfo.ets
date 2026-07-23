export interface ManagementInfo {
  id: ManagementType;
  title: ResourceStr;
  icon: Resource;
  click: () => void;
}

export enum ManagementType {
  ADDRESSES = 0, TOURISTS = 1, HOTLINES = 2
}

export enum ManagementPath {
  ADDRESSES_PAGE = 'Addresses', TOURISTS_PAGE = 'TouristsPage', HOTLINES_PAGE = 'Hotlines'
}

export function getManagementModuleInfo(pathStack: NavPathStack) {
  return [{
    id: ManagementType.TOURISTS,
    title: '常用旅客',
    icon: $r('sys.symbol.portrait'),
    click: () => {
      pathStack.pushPathByName(ManagementPath.TOURISTS_PAGE, null);
    },
  }, {
    id: ManagementType.ADDRESSES,
    title: '我的地址',
    icon: $r('sys.symbol.local'),
    click: () => {
      pathStack.pushPathByName(ManagementPath.ADDRESSES_PAGE, false);
    },
  }, {
    id: ManagementType.HOTLINES,
    title: '服务热线',
    icon: $r('sys.symbol.service'),
    click: () => {
      pathStack.pushPathByName(ManagementPath.HOTLINES_PAGE, null);
    },
  }] as ManagementInfo[];
}