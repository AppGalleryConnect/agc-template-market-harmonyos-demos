export enum InvoiceType {
  ENTERPRISE = '企业',
  INDIVIDUAL = '个人',
  NON_ENTERPRISE_UNIT = '非企业性单位'
}

@ObservedV2
export class InvoiceInfo {
  @Trace id: string = Date.now().toString()
  // 类型
  @Trace type: InvoiceType = InvoiceType.ENTERPRISE
  // 抬头
  @Trace title: string = ''
  // 税号
  @Trace taxID: string = ''
  // 是否需要增值税专用发票
  @Trace isNeedVAD: boolean = false

  constructor(type?: InvoiceType, title?: string, taxID?: string, isNeedVAD?: boolean) {
    this.type = type || this.type
    this.title = title ?? this.title
    this.taxID = taxID ?? this.taxID
    this.isNeedVAD = isNeedVAD ?? this.isNeedVAD
  }
}


// 发票列表
@ObservedV2
export class InvoiceList {
  @Trace list: InvoiceInfo[] = []

  add(data: InvoiceInfo) {
    this.list.unshift(data)
  }

  editData(data: InvoiceInfo) {
    let index = this.list.findIndex(item => item.id === data.id)
    this.list.splice(index, 1, data)
  }

  deleteById(id: string) {
    this.list = this.list.filter(item => item.id !== id)
  }
}