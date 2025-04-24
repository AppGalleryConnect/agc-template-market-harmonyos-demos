export interface FunctionModuleData {
  id: FunctionType;
  title: ResourceStr;
  icon: ResourceStr;
  click: (event: ClickEvent) => void;
}

export enum FunctionType {
  MALL = 0,
  TICKET = 1,
  CATERING = 2,
  ROUTE = 3,
  NOTE = 4,
}

export enum FunctionPath {
  MALL = 'Mall',
  TICKET = 'Tickets',
  CATERING = 'Catering',
  ROUTE = 'Route',
  NOTE = 'Note',
}

export function getFunctionModuleInfo(pathStack: NavPathStack) {
  return [
    {
      id: FunctionType.TICKET,
      title: '票务预约',
      icon: $r('app.media.ticket'),
      click: () => {
        pathStack.pushPathByName(FunctionPath.TICKET, true, false);
      },
    },
    {
      id: FunctionType.MALL,
      title: '特产文创',
      icon: $r('app.media.commodity'),
      click: () => {
        pathStack.pushPathByName(FunctionPath.MALL, null);
      },
    },
    {
      id: FunctionType.CATERING,
      title: '餐饮住宿',
      icon: $r('app.media.catering'),
      click: () => {
        pathStack.pushPathByName(FunctionPath.CATERING, null);
      },
    },
    {
      id: FunctionType.ROUTE,
      title: '游览路线',
      icon: $r('app.media.route'),
      click: () => {
        pathStack.pushPathByName(FunctionPath.ROUTE, null);
      },
    },
  ] as FunctionModuleData[];
}