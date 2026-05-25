/*
  未成年模式
 */

@ObservedV2
export class MinorsMode {
  @Trace isMinorsMode: boolean

  constructor(value: boolean) {
    this.isMinorsMode = value
  }
}