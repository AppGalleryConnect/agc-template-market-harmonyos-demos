import DIContainer from "../types/DependencyContainer";

type FactoryFunction<T> = (diContainer: DIContainer) => T;

export default FactoryFunction;
