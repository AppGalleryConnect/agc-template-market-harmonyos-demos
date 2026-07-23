export interface SignIn {
  coinNumber: number // 金币数量
  isClaim: boolean // 是否获得奖励
  isLookAD: boolean // 是否需要看广告
}

@ObservedV2
export class SignInClass {
  coinNumber: number
  @Trace isClaim: boolean
  @Trace isLookAD: boolean

  constructor(coinNumber: number, isClaim: boolean = false, isLookAD: boolean = false) {
    this.coinNumber = coinNumber
    this.isClaim = isClaim
    this.isLookAD = isLookAD
  }
}

// 将普通对象重建
export function fromPlain(obj: SignIn): SignInClass {
  const instance = new SignInClass(35)
  instance.coinNumber = obj.coinNumber
  instance.isClaim = obj.isClaim
  instance.isLookAD = obj.isLookAD
  return instance
}

// 将当前实例转换为普通对象
export function toPlainObject(obj: SignIn): SignIn {
  return {
    coinNumber: obj.coinNumber,
    isClaim: obj.isClaim,
    isLookAD: obj.isLookAD
  }
}