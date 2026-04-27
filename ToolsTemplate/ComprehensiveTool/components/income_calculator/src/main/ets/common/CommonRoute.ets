let pathStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
}

export const getInstance = (): NavPathStack => {
  return pathStack;
}