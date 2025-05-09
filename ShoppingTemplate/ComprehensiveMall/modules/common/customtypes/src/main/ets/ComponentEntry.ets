import { Any } from './CustomType';

/**
 * 表示一个组件封装器 WrappedBuilder 及其相关参数 args 共同构成的条目
 *
 * ComponentEntry - 将组件封装器与其执行时所需的参数绑定在一起, 以便在后续的操作中传递和执行
 *
 * @template T - 用于确保 args 的参数类型与参数数量和组件封装器所需参数一致
 */
export class ComponentEntry<T extends Object[]> {

  private _wrappedBuilder: WrappedBuilder<T>;

  private _args: T;

  get wrappedBuilder(): WrappedBuilder<T> {
    return this._wrappedBuilder;
  }

  get args(): T {
    return this._args;
  }

  constructor(wrappedBuilder: WrappedBuilder<T>, args: T) {
    this._wrappedBuilder = wrappedBuilder;
    this._args = args;
  }
}

export type ComponentEntryProxy = ComponentEntry<Any[]>;
