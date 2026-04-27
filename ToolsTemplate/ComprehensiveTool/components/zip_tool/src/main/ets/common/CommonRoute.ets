let pathStack: NavPathStack;

export const setPathStack = (stack: NavPathStack) => {
  pathStack = stack;
}

export const getInstance = (): NavPathStack => {
  return pathStack;
}