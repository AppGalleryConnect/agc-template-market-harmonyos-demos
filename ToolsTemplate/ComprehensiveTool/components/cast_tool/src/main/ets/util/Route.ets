let pathStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
};

export const getInstance = (): NavPathStack => {
  return pathStack;
};

export enum RouterMap {
  //  首页
  HOME = 'CastPage',
  //  文件列表
  LIST = 'FileListPage',
  //  控制页面
  CONTROLLER = 'CastControllerPage'
}