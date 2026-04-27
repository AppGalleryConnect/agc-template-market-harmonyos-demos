import DIContainer from "./types/DependencyContainer";
import {
  isValueProvider,
  isClassProvider,
  isFactoryProvider,
  isNormalToken,
  isTokenProvider,
} from "./providers";
import Provider, { isProvider } from "./providers/Provider";
import FactoryProvider from "./providers/FactoryProvider";
import TokenProvider from "./providers/TokenProvider";
import ValueProvider from "./providers/ValueProvider";
import ClassProvider from "./providers/ClassProvider";
import DIToken, {
  isConstructorToken,
  TokenDescriptor,
} from "./providers/InjectionToken";

import constructor from "./types/Constructor";
import Lifecycle from "./types/Lifecycle";
import ResolutionContext from "./ResolutionContext";
import { DelayedConstructor } from "./LazyHelpers";
import Registry, { Registration } from "./Registry";
import RegistrationOptions from "./types/RegistrationOptions";


export type ParamInfo = TokenDescriptor | DIToken<any>;

/** Dependency Container */
class InternalDIContainer implements DIContainer {
  private registry_ = new Registry();

  public constructor(private parent?: InternalDIContainer) {}

  /**
   * Register a dependency provider.
   *
   * @param provider {Provider} The dependency provider
   */
  public register<T>(
    token: DIToken<T>,
    provider: ValueProvider<T>
  ): InternalDIContainer;
  public register<T>(
    token: DIToken<T>,
    provider: FactoryProvider<T>
  ): InternalDIContainer;
  public register<T>(
    token: DIToken<T>,
    provider: TokenProvider<T>,
    options?: RegistrationOptions
  ): InternalDIContainer;
  public register<T>(
    token: DIToken<T>,
    provider: ClassProvider<T>,
    options?: RegistrationOptions
  ): InternalDIContainer;
  public register<T>(
    token: DIToken<T>,
    provider: constructor<T>,
    options?: RegistrationOptions
  ): InternalDIContainer;
  public register<T>(
    token: DIToken<T>,
    providerOrConstructor: Provider<T> | constructor<T>,
    options: RegistrationOptions = { lifecycle: Lifecycle.Transient }
  ): InternalDIContainer {
    let provider: Provider<T>;

    if (!isProvider(providerOrConstructor)) {
      provider = { clazz: providerOrConstructor };
    } else {
      provider = providerOrConstructor;
    }

    // find the token graph for cycles
    if (isTokenProvider(provider)) {
      const path = [token];

      let tokenProvider: TokenProvider<T> | null = provider;
      while (tokenProvider !== null) {
        const currentToken = tokenProvider.token;
        if (path.includes(currentToken)) {
          throw new Error(
            `Token registration cycle detected! ${[...path, currentToken].join(
              " -> "
            )}`
          );
        }

        path.push(currentToken);

        const registration = this.registry_.get(currentToken);

        if (registration && isTokenProvider(registration.provider)) {
          tokenProvider = registration.provider;
          continue;
        }

        tokenProvider = null;
      }
    }

    if (options.lifecycle === Lifecycle.Singleton ||
        options.lifecycle === Lifecycle.ContainerScoped ||
        options.lifecycle === Lifecycle.ResolutionScoped
    ) {
      if (isValueProvider(provider) || isFactoryProvider(provider)) {
        throw new Error(
          `Cannot use lifecycle "${
          Lifecycle[options.lifecycle]
          }" with ValueProviders or FactoryProviders`
        );
      }
    }

    this.registry_.set(token, { provider, options });

    return this;
  }

  public registerType<T>(
    from: DIToken<T>,
    to: DIToken<T>
  ): InternalDIContainer {
    if (isNormalToken(to)) {
      return this.register(from, {
        token: to,
      });
    }

    return this.register(from, {
      clazz: to,
    });
  }

  public registerInstance<T>(
    token: DIToken<T>,
    instance: T
  ): InternalDIContainer {
    return this.register(token, {
      value: instance,
    });
  }

  public registerSingleton<T>(
    from: DIToken<T>,
    to: DIToken<T>
  ): InternalDIContainer;
  public registerSingleton<T>(
    token: constructor<T>,
    to?: constructor<any>
  ): InternalDIContainer;
  public registerSingleton<T>(
    from: DIToken<T>,
    to?: DIToken<T>
  ): InternalDIContainer {
    if (isNormalToken(from)) {
      if (isNormalToken(to)) {
        return this.register(
          from,
          {
            token: to,
          },
          { lifecycle: Lifecycle.Singleton }
        );
      } else if (to) {
        return this.register(
          from,
          {
            clazz: to,
          },
          { lifecycle: Lifecycle.Singleton }
        );
      }

      throw new Error(
        'Cannot register a type name as a singleton without a "to" token'
      );
    }

    let clazz = from;
    if (to && !isNormalToken(to)) {
      clazz = to;
    }

    return this.register(
      from,
      {
        clazz,
      },
      { lifecycle: Lifecycle.Singleton }
    );
  }

  public resolve<T>(
    token: DIToken<T>,
    context: ResolutionContext = new ResolutionContext()
  ): T {
    const registration = this.getRegistration(token);

    if (!registration && isNormalToken(token)) {
      throw new Error(
        `Try to resolveunregistered dependency token: "${token.toString()}"`
      );
    }

    if (registration) {
      const result = this.resolveRegistration(registration, context) as T;
      return result;
    }

    // No registration for this token, but since it's a constructor, return an instance
    if (isConstructorToken(token)) {
      const result = this.construct(token, context);
      return result;
    }

    throw new Error(
      "Attempted to construct an undefined constructor. Could mean a circular dependency problem. Try using `delay` function."
    );
  }

  public get<T>(
    token: string,
    context: ResolutionContext = new ResolutionContext()
  ): T | null {
    const registration = this.getRegistration(token);

    if (registration) {
      const result = this.resolveRegistration(registration, context) as T;
      return result;
    }

    //不支持其他provide类型，只支持normal中的token类型
    return null;
  }

  private resolveRegistration<T>(registration: Registration, context: ResolutionContext): T {
    // If we have already resolved this scoped, return it
    if (
      registration.options.lifecycle === Lifecycle.ResolutionScoped &&
      context.scopedResolutions.has(registration)
    ) {
      return context.scopedResolutions.get(registration);
    }

    const isSingleton = registration.options.lifecycle === Lifecycle.Singleton;
    const isContainerScoped = registration.options.lifecycle === Lifecycle.ContainerScoped;
    //返回实例，不用创建
    const returnInstance = isSingleton || isContainerScoped;

    let resolved: T;

    if (isValueProvider(registration.provider)) {
      resolved = registration.provider.value;
    } else if (isTokenProvider(registration.provider)) {
      resolved = returnInstance
        ? registration.instance ||
          (registration.instance = this.resolve(
            registration.provider.token,
            context
          ))
        : this.resolve(registration.provider.token, context);
    } else if (isClassProvider(registration.provider)) {
      resolved = returnInstance
        ? registration.instance ||
          (registration.instance = this.construct(
            registration.provider.clazz,
            context
          ))
        : this.construct(registration.provider.clazz, context);
    } else if (isFactoryProvider(registration.provider)) {
      resolved = registration.provider.factory(this);
    } else {
      resolved = this.construct(registration.provider, context);
    }

    // If this is a scoped dependency, store resolved instance in ResolutionContext
    if (registration.options.lifecycle === Lifecycle.ResolutionScoped) {
      context.scopedResolutions.set(registration, resolved);
    }

    return resolved;
  }

  public resolveAll<T>(
    token: DIToken<T>,
    context: ResolutionContext = new ResolutionContext()
  ): T[] | null {
    const registrations = this.getAllRegistrations(token);

    if (!registrations && isNormalToken(token)) {
      throw new Error(
        `Try to resolveunregistered dependency token: "${token.toString()}"`
      );
    }

    if (registrations) {
      const result = registrations.map((item) =>
      this.resolveRegistration<T>(item, context)
      );

      return result;
    }

    // No registration for this token, but since it's a constructor, return an instance
    const result = [this.construct(token as constructor<T>, context)];
    return result;
  }

  public isRegistered<T>(token: DIToken<T>, recursive = false): boolean {
    return (
      this.registry_.has(token) ||
        (recursive &&
          (this.parent || false) &&
        this.parent.isRegistered(token, true))
    );
  }

  public reset(): void {
    this.registry_.clear();
  }

  public clearInstances(): void {
    for (const [token, registrations] of this.registry_.entries()) {
      this.registry_.setAll(
        token,
        registrations
          // Clear ValueProvider registrations
          .filter((registration) => !isValueProvider(registration.provider))
            // Clear instances
          .map((registration) => {
            registration.instance = undefined;
            return registration;
          })
      );
    }
  }

  public createChildContainer(): DIContainer {
    const childContainer = new InternalDIContainer(this);

    for (const [token, registrations] of this.registry_.entries()) {
      if (
      registrations.some(
        ({ options }) => options.lifecycle === Lifecycle.ContainerScoped
      )
      ) {
        childContainer.registry_.setAll(
          token,
          registrations.map<Registration>((registration) => {
            if (registration.options.lifecycle === Lifecycle.ContainerScoped) {
              return {
                provider: registration.provider,
                options: registration.options,
              };
            }

            return registration;
          })
        );
      }
    }

    return childContainer;
  }

  private construct<T>(ctor: constructor<T> | DelayedConstructor<T>, context: ResolutionContext): T {
    if (ctor instanceof DelayedConstructor) {
      return ctor.createProxy((target: constructor<T>) =>
      this.resolve(target, context)
      );
    }
    //only support no params constructor
    return new ctor();
  }

  private getRegistration<T>(token: DIToken<T>): Registration | null {
    if (this.isRegistered(token)) {
      return this.registry_.get(token)!;
    }

    if (this.parent) {
      return this.parent.getRegistration(token);
    }

    return null;
  }

  private getAllRegistrations<T>(token: DIToken<T>): Registration[] | null {
    if (this.isRegistered(token)) {
      return this.registry_.getAll(token);
    }

    if (this.parent) {
      return this.parent.getAllRegistrations(token);
    }

    return null;
  }
}

export const instance: DIContainer = new InternalDIContainer();

export default instance;
