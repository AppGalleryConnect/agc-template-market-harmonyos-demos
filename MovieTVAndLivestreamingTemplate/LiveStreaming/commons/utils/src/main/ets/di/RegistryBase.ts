import { DIToken } from "./index";

export default abstract class RegistryBase<T> {
  protected _registryMap = new Map<DIToken<any>, T[]>();

  public entries(): IterableIterator<[DIToken<any>, T[]]> {
    return this._registryMap.entries();
  }

  public getAll(key: DIToken<any>): T[] {
    this.ensure(key);
    return this._registryMap.get(key)!;
  }

  public get(key: DIToken<any>): T | null {
    this.ensure(key);
    const value = this._registryMap.get(key)!;
    return value[value.length - 1] || null;
  }

  public set(key: DIToken<any>, value: T): void {
    this.ensure(key);
    this._registryMap.get(key)!.push(value);
  }

  public setAll(key: DIToken<any>, value: T[]): void {
    this._registryMap.set(key, value);
  }

  public has(key: DIToken<any>): boolean {
    this.ensure(key);
    return this._registryMap.get(key)!.length > 0;
  }

  public clear(): void {
    this._registryMap.clear();
  }

  private ensure(key: DIToken<any>): void {
    if (!this._registryMap.has(key)) {
      this._registryMap.set(key, []);
    }
  }
}
