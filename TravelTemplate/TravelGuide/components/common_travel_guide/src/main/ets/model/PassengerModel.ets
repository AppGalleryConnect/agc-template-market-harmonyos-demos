import { Type } from '@kit.ArkUI'

@ObservedV2
export class PassengerInfo {
  @Trace id: string = Date.now().toString()
  // 姓名
  @Trace name: string = ''
  // 手机号
  @Trace phone: string = ''
  // 证件号码
  @Trace idNumber: string = ''
  // 座位号
  @Trace seatNo?: string = '14车12A号'

  getEncryptionPhone(){
    const reg = /(\d{3})\d{4}(\d{4})/;
    return this.phone.toString().replace(reg,'$1****$2')
  }

  getEncryptionID(){
    const reg = /(\d{5})\d{11}(\d{2})/;
    return this.idNumber.replace(reg,'$1***********$2')
  }
}


// 我的常用旅客信息
@ObservedV2
export class MyPassengerList {
  @Type(PassengerInfo)
  @Trace list: PassengerInfo[] = []
  // 是本人的旅客ID
  @Trace mySelfId: string = ''

  add(data: PassengerInfo) {
    this.list.unshift(data)
  }

  editData(data: PassengerInfo) {
    let index = this.list.findIndex(item => item.id === data.id)
    this.list.splice(index, 1, data)
  }

  deleteById(id: string) {
    this.list = this.list.filter(item => item.id !== id)
  }
}