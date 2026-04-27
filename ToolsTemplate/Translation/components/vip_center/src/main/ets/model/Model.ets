@ObservedV2
export class VipUserInfo {
  @Trace avatar: string = ''
  @Trace userName: string = ''
  isVip: boolean = false
}
export class VipPackageItem {
  title: string = ''
  amount: number = 0
  duration:string = ''
  amountDes: string = ''
}

export class Benefits {
  title: string = ''
  icon: string = ''
}

export interface Operation {
  title: string
  id: string
}