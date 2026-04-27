@ObservedV2
export class Context {
  @Trace
  public navPathStack: NavPathStack = new NavPathStack();
  @Trace
  public onSelect: () => void = () => {
  };
  @Trace
  public onPushPath: ((id: number) => void) | undefined = undefined
}

export const ctx = new Context()
