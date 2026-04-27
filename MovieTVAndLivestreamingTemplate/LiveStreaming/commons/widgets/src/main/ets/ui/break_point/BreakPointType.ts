export enum BreakPointValue {
  SM = 'sm', // [0, 600)
  MD = 'md', // [600, 840)
  LG = 'lg', // [840, +∞)
}

export class BreakPointType<T> {
  private data: { [key: string]: T };

  constructor(data: { [key: string]: T }) {
    this.data = data;
  }

  public getValue(key: string): T | undefined {
    return (this.data && key) ? this.data[key] : undefined;
  }
}