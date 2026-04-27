let pathStack: NavPathStack;

export const getInstance = () => {
  return pathStack;
}

export const setPathStack = (navPathStack: NavPathStack) => {
  pathStack = navPathStack;
}