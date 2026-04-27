import DIToken from "../providers/InjectionToken";
import TokenProvider from "../providers/TokenProvider";
import ValueProvider from "../providers/ValueProvider";
import ClassProvider from "../providers/ClassProvider";
import constructor from "./Constructor";
import RegistrationOptions from "./RegistrationOptions";

interface FactoryProvider<T> {
  factory: (diContainer: DIContainer) => T;
}

export default interface DIContainer {
  register<T>(
    token: DIToken<T>,
    provider: ValueProvider<T>
  ): DIContainer;
  register<T>(
    token: DIToken<T>,
    provider: FactoryProvider<T>
  ): DIContainer;
  register<T>(
    token: DIToken<T>,
    provider: TokenProvider<T>,
    options?: RegistrationOptions
  ): DIContainer;
  register<T>(
    token: DIToken<T>,
    provider: ClassProvider<T>,
    options?: RegistrationOptions
  ): DIContainer;
  register<T>(
    token: DIToken<T>,
    provider: constructor<T>,
    options?: RegistrationOptions
  ): DIContainer;

  registerSingleton<T>(
    from: DIToken<T>,
    to: DIToken<T>
  ): DIContainer;
  registerSingleton<T>(token: constructor<T>): DIContainer;

  registerType<T>(
    from: DIToken<T>,
    to: DIToken<T>
  ): DIContainer;

  registerInstance<T>(
    token: DIToken<T>,
    instance: T
  ): DIContainer;

  /**
   * Resolve a token into an instance
   *
   * @param token The dependency token
   * @return An instance of the dependency
   */
  resolve<T>(token: DIToken<T>): T;

  /**
   * get a instance or null from string token
   * @param token name
   * @returns instance or null
   */
  get<T>(token: string): T | null;

  resolveAll<T>(token: DIToken<T>): T[];

  /**
   * Check if the given dependency is registered
   *
   * @param token The token to check
   * @param recursive Should parent containers be checked?
   * @return Whether or not the token is registered
   */
  isRegistered<T>(token: DIToken<T>, recursive?: boolean): boolean;

  /**
   * Clears all registered tokens
   */
  reset(): void;

  clearInstances(): void;
  createChildContainer(): DIContainer;
}
