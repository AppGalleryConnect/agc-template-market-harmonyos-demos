export class CalculatorVM {
  public static _stack: NavPathStack = new NavPathStack()

  public static getStack(): NavPathStack {
    return CalculatorVM._stack;
  }
  public static setStack(stack: NavPathStack): NavPathStack {
    return CalculatorVM._stack = stack;
  }
}