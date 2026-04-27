import constructor from "./types/Constructor";

export class DelayedConstructor<T> {
  private methods: ReadonlyArray<keyof ProxyHandler<any>> = [
    "get",
    "has",
    "set",
    "apply",
    "construct",
    "getPrototypeOf",
    "setPrototypeOf",
    "getOwnPropertyDescriptor",
    "defineProperty",
    "deleteProperty"
  ];

  constructor(private wrap: () => constructor<T>) {}

  private createHandler(delayedObject: () => T): ProxyHandler<object> {
    const handler: ProxyHandler<object> = {};
    this.methods.forEach((name: keyof ProxyHandler<any>): void => {
      handler[name] = (...args: any[]):any => {
        args[0] = delayedObject();
        const method = Reflect[name];
        return (method as any)(...args);
      };
    });
    return handler;
  }

  public createProxy(createObject: (ctor: constructor<T>) => T): T {
    const target: object = {};
    let inited = false;
    let value: T;
    const delayedObject: () => T = (): T => {
      if (!inited) {
        value = createObject(this.wrap());
        inited = true;
      }
      return value;
    };
    return new Proxy<any>(target, this.createHandler(delayedObject)) as T;
  }
}

export function delay<T>(
  wrappedConstructor: () => constructor<T>
): DelayedConstructor<T> {
  if (typeof wrappedConstructor === "undefined") {
    throw new Error(
      "Attempt to `delay` undefined. Constructor must be wrapped in a callback"
    );
  }
  return new DelayedConstructor<T>(wrappedConstructor);
}
