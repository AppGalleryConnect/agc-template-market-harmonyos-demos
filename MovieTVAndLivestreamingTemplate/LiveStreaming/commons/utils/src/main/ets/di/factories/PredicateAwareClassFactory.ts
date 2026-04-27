import DIContainer from "../types/DependencyContainer";
import constructor from "../types/Constructor";
import FactoryFunction from "./FactoryFunction";

export default function predicateAwareClassFactory<T>(predicate: (diContainer: DIContainer) => boolean,
  trueConstructor: constructor<T>, falseConstructor: constructor<T>, useCaching = true): FactoryFunction<T> {
  let instance: T;
  let previousPredicate: boolean;
  return (diContainer: DIContainer) => {
    const currentPredicate = predicate(diContainer);
    if (!useCaching || previousPredicate !== currentPredicate) {
      if ((previousPredicate = currentPredicate)) {
        instance = diContainer.resolve(trueConstructor);
      } else {
        instance = diContainer.resolve(falseConstructor);
      }
    }
    return instance;
  };
}
