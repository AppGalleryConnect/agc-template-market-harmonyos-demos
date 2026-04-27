import constructor from "../types/Constructor";
import { DelayedConstructor } from "../LazyHelpers";

export default interface ClassProvider<T> {
  clazz: constructor<T> | DelayedConstructor<T>;
}

