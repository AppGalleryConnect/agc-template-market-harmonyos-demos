let stack: NavPathStack;

export const getInstance = () => {
  return stack;
}

export const setPathStack = (pathStack: NavPathStack) => {
  stack = pathStack;
}