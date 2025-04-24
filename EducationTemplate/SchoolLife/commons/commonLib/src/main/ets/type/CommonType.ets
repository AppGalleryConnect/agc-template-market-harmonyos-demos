export class Pair<T1, T2> {
  first: T1;
  second: T2;

  constructor(first: T1, second: T2) {
    this.first = first;
    this.second = second;
  }
}

@ObservedV2
export class WindowConfig {
  @Trace windowTopHeight: number = 38.77;
  @Trace windowBottomHeight: number = 28;
}

@ObservedV2
export class FormCardRouteInfo {
  @Trace path: string = '';
}