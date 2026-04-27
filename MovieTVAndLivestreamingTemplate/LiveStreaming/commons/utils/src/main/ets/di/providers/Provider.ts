import ValueProvider from "./ValueProvider";
import ClassProvider from "./ClassProvider";
import TokenProvider from "./TokenProvider";
import FactoryProvider from "./FactoryProvider";

export function isValueProvider<T>(
  provider: Provider<T>
): provider is ValueProvider<T> {
  return (provider as ValueProvider<T>).value !== undefined;
}

export function isClassProvider<T>(
  provider: Provider<T>
): provider is ClassProvider<any> {
  return !!(provider as ClassProvider<T>).clazz;
}

export function isTokenProvider<T>(
  provider: Provider<T>
): provider is TokenProvider<any> {
  return !!(provider as TokenProvider<T>).token;
}

export function isFactoryProvider<T>(
  provider: Provider<T>
): provider is FactoryProvider<any> {
  return !!(provider as FactoryProvider<T>).factory;
}

export function isProvider(provider: any): provider is Provider {
  return (isValueProvider(provider) || isClassProvider(provider)
    || isTokenProvider(provider) || isFactoryProvider(provider));
}

type Provider<T = any> = ValueProvider<T> | ClassProvider<T> | TokenProvider<T> | FactoryProvider<T>;

export default Provider;
