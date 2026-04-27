/***
 * 参考开源代码 https://github.com/microsoft/tsyringe
 * 删除了装饰器、拦截器等功能
 * 对部分类、变量进行了重命名
 */

export {
  DIContainer,
  Lifecycle,
  RegistrationOptions,
  Frequency
} from "./types";
export * from "./factories";
export * from "./providers";
export {delay} from "./LazyHelpers";
export {instance as container} from "./DependencyContainer";
