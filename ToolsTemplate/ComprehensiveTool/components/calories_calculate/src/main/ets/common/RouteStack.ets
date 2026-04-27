let routeStack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  routeStack = navPathStack;
}

export const getInstance = (): NavPathStack => {
  return routeStack;
}