@ObservedV2
export class AddressManagerPageVM {
  private static _instance: AddressManagerPageVM;

  public static get instance() {
    if (!AddressManagerPageVM._instance) {
      AddressManagerPageVM._instance = new AddressManagerPageVM();
    }
    return AddressManagerPageVM._instance;
  }

  // 地址列表
  @Trace addressList: AddressManagerItem[] = []
  // 删除对话框id
  @Trace deleteDialogId: number = -1
  // 标签数组-默认
  @Trace defaultTagArray: string[] = ['家', '公司', '学校']
  // 选定的标签下标
  @Trace selectedTagIndex: number = 0
  // 地址数组下标
  @Trace addressSelectedIndex: number = 0
}

/**
 * 地址管理类
 */
@ObservedV2
export class AddressManagerItem {
  // id
  @Trace id: string = ''
  // 住户姓名
  @Trace name: string = ''
  // 住户电话
  @Trace phone: string = ''
  // 住户地址
  @Trace address: string = ''
  // 是否默认
  @Trace isDefault: boolean = false
  // 住户备注：家/公司
  @Trace remark: string = ''
  // 所在地区
  @Trace area: string = ''
  // 详细地址
  @Trace detailAddress: string = ''

  constructor(id: string, name: string, phone: string, address: string, isDefault: boolean, remark: string,
    area: string, detailAddress: string) {
    this.id = id
    this.name = name
    this.phone = phone
    this.address = address
    this.isDefault = isDefault
    this.remark = remark
    this.area = area
    this.detailAddress = detailAddress
  }
}