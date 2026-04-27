let navStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  navStack = navPathStack;
}

export const getInstance = (): NavPathStack => {
  return navStack;
}