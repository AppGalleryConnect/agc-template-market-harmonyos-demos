let stack: NavPathStack;

export const setPathStack = (navPathStack: NavPathStack) => {
  stack = navPathStack;
};

export const getInstance = (): NavPathStack => {
  return stack;
};