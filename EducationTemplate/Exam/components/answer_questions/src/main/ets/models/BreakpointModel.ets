/**
 * 业务options模型
 */
export interface BreakpointTypeOptions<T> {
  sm: T,
  md: T,
  lg: T,
  xl: T,
}

/**
 * 业务options类
 */
export class BreakpointType<T> {
  private options: BreakpointTypeOptions<T>;

  constructor(options: BreakpointTypeOptions<T>) {
    this.options = options;
  }

  public getValue(bp: BreakpointNameEnum) {
    return Reflect.get(this.options, bp) as T;
  }
}

/**
 * 断点名称
 */
export enum BreakpointNameEnum {
  SM = 'sm',
  MD = 'md',
  LG = 'lg',
  XL = 'xl',
}

/**
 * 断点取值
 */
export enum BreakpointValueEnum {
  SM = '600vp',
  MD = '840vp',
  LG = '1440vp',
}

/**
 * 栅格断点
 */
@ObservedV2
export class BreakpointModel {
  @Trace currentBreakpoint: BreakpointNameEnum = BreakpointNameEnum.SM;
}