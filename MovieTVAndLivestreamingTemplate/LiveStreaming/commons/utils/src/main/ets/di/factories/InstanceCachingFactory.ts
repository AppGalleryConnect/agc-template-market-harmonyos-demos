import DIContainer from "../types/DependencyContainer";
import FactoryFunction from "./FactoryFunction";

export default function instanceCachingFactory<T>(
  factoryFunc: FactoryFunction<T>
): FactoryFunction<T> {
  let instance: T;
  return (diContainer: DIContainer) => {
    if (instance === undefined) {
      instance = factoryFunc(diContainer);
    }
    return instance;
  };
}
