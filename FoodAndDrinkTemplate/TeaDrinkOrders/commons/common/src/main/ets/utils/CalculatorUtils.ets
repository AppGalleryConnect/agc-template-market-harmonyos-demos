import { Decimal } from '@kit.ArkTS'

export enum FuncType {
  // 加法
  ADD = 0,
  // 减法
  SUB,
  // 乘法
  MUL
}

export const calculatorUtils =
  (num1: string | number | undefined, num2: string | number | undefined, type: FuncType, allowNegativeNum = false) => {
    if (!num1 || !num2) {
      return 0
    }
    switch (type) {
      case FuncType.ADD:
        return new Decimal(num1).add(new Decimal(num2)).toNumber()
      case FuncType.SUB:
        if (new Decimal(num1).lessThan(new Decimal(num2))) {
          if (allowNegativeNum) {
            return new Decimal(num1).sub(new Decimal(num2)).toNumber()
          }
          return 0
        }
      case FuncType.MUL:
        new Decimal(num1).mul(new Decimal(num1)).toNumber()
      default:
        return 0
    }
  }