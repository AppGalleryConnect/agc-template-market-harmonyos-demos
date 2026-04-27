let pathStack: NavPathStack;

export const setNavPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
}

export const getNavPathStack = (): NavPathStack => {
  return pathStack;
}