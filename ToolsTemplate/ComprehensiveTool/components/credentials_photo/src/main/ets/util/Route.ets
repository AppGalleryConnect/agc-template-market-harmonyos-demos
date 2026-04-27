let pathStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
};

export const getInstance = (): NavPathStack => {
  return pathStack;
};

export enum RouterMap {
  //  首页
  HOME = 'CredentialsPage',
  //  保存页面
  SAVE = 'SavePhotoPage',
  //  编辑页面
  EDIT = 'PhotoEditPage'
}