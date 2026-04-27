@ObservedV2
export class AddressInfo {
  @Trace id: string = Date.now().toString()
  // 收货人
  @Trace name: string
  // 手机号
  @Trace phone: string
  // 地区
  @Trace area: string
  // 详细地址
  @Trace detailAddress: string

  constructor(name: string, phone: string, area: string, detailAddress: string) {
    this.name = name
    this.phone = phone
    this.area = area
    this.detailAddress = detailAddress
  }

  getEncryptionPhone(){
    const reg = /(\d{3})\d{4}(\d{4})/;
    return this.phone.toString().replace(reg,'$1****$2')
  }

  getFullAddress(){
    return this.area + this.detailAddress
  }
}


// 我的常用地址信息
@ObservedV2
export class MyAddressList {
  @Trace list: AddressInfo[] = []

  add(data: AddressInfo) {
    this.list.unshift(data)
  }

  editData(data: AddressInfo) {
    let index = this.list.findIndex(item => item.id === data.id)
    this.list.splice(index, 1, data)
  }

  deleteById(id: string) {
    this.list = this.list.filter(item => item.id !== id)
  }
}