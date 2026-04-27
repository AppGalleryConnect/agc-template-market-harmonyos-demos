let navStack: NavPathStack;

export const setStack = (navPathStack: NavPathStack) => {
  navStack = navPathStack;
}

export const getStack = (): NavPathStack => {
  return navStack;
}