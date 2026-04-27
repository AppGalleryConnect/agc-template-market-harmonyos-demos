let pathStack: NavPathStack;

export const getInstance = (): NavPathStack => {
  return pathStack;
}

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
}

