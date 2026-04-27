@ObservedV2
export class Context {
  @Trace
  public navPathStack: NavPathStack = new NavPathStack();
}

export const ctx = new Context()
