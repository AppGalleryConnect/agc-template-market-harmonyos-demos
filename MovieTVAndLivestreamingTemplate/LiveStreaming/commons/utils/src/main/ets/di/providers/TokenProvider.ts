import DIToken from "./InjectionToken";

export default interface TokenProvider<T> {
  token: DIToken<T>;
}

