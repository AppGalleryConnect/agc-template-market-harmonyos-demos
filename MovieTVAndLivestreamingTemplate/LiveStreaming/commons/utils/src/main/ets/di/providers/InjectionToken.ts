import constructor from "../types/Constructor";
import {DelayedConstructor} from "../LazyHelpers";
import Transform from "../types/Transform";

type DIToken<T = any> =
  | constructor<T>
  | string
  | DelayedConstructor<T>;

export function isNormalToken(
  token?: DIToken<any>
): token is string {
  return typeof token === "string";
}

export function isConstructorToken(
  token?: DIToken<any>
): token is constructor<any> | DelayedConstructor<any> {
  return typeof token === "function" || token instanceof DelayedConstructor;
}

export interface TokenDescriptor {
  token: DIToken<any>;
  multiple: boolean;
}

export interface TransformDescriptor {
  token: DIToken<any>;
  transform: DIToken<Transform<any, any>>;
  transformArgs: any[];
}

export default DIToken;
