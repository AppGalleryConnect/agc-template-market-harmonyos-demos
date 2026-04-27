import { AppStorageV2 } from '@kit.ArkUI'

export interface BankCard {
  bankName: string;
  cardNo: string;
  bankIcon: ResourceStr;
  rotateColor: string[]
}

export interface AddressItem {
  name: string
  phone: string
  // 1 家庭，2 公司，3 学校
  type: number
  region: string
  detail: string
  isDefault: boolean
}

@ObservedV2
export class ValuationStore {
  @Trace bankCards: BankCard[] = [
    {
      bankIcon: $r('app.media.icon_china_bank'),
      bankName: '中国银行',
      cardNo: '95************6688',
      rotateColor: ['rgba(255, 75, 75, 1)', 'rgba(184, 28, 34, 1)']
    },
    {
      bankIcon: $r('app.media.icon_china_bank'),
      bankName: '中国银行',
      cardNo: '95************6688',
      rotateColor: ['rgba(255, 75, 75, 1)', 'rgba(184, 28, 34, 1)']
    }
  ]
  @Trace addresses: AddressItem[] = [
    {
      name: '张三',
      phone: '138****0000',
      type: 1,
      region: '辽宁省沈阳市浑南区',
      detail: '中软国际大厦(创业路东50米)',
      isDefault: true
    },
    {
      name: '李四',
      phone: '139****0000',
      type: 2,
      region: '江苏省南京市江宁区',
      detail: '竹山路61号万达广场3-1幢',
      isDefault: false
    }
  ]
  @Trace selectedPickupDate: number | null = null
  @Trace selectedPickupRegion: string = ''
  @Trace selectedPickupDetail: string = ''
  @Trace selectedName: string = ''
  @Trace selectedPhone: string = ''
}

export function connectValuationStore(): ValuationStore {
  return AppStorageV2.connect(ValuationStore, () => new ValuationStore())!
}

export class ValuationStoreAPI {
  /**
   * 获取估价模块的全局数据（银行卡、地址）
   */
  static get(): ValuationStore {
    return connectValuationStore()
  }

  /**
   * 新增银行卡
   * @param card 银行卡对象，例如：{ bankName: '中国银行', cardNo: '****1234' }
   */
  static addBankCard(card: BankCard) {
    const s = connectValuationStore();
    s.bankCards.push(card)
  }

  /**
   * 编辑银行卡
   * @param index 目标下标
   * @param patch 完整银行卡对象（推荐）
   */
  static updateBankCard(index: number, patch: BankCard) {
    const s = connectValuationStore();
    if (index >= 0 && index < s.bankCards.length) {
      s.bankCards[index] = patch
    }
  }

  /**
   * 删除银行卡
   * @param index 目标下标
   */
  static removeBankCard(index: number) {
    const s = connectValuationStore();
    if (index >= 0 && index < s.bankCards.length) {
      s.bankCards.splice(index, 1)
    }
  }

  /**
   * 新增地址
   * @param address 地址对象，例如：{ name, phone, type, region, detail, isDefault }
   */
  static addAddress(address: AddressItem) {
    const s = connectValuationStore();
    s.addresses.push(address)
  }

  /**
   * 编辑地址（支持部分字段）
   * @param index 目标下标
   * @param patch 需更新的字段集合
   */
  static updateAddress(index: number, patch: Partial<AddressItem>) {
    const s = connectValuationStore();
    if (index >= 0 && index < s.addresses.length) {
      const cur = s.addresses[index]
      const next: AddressItem = {
        name: patch.name !== undefined ? patch.name : cur.name,
        phone: patch.phone !== undefined ? patch.phone : cur.phone,
        type: patch.type !== undefined ? patch.type : cur.type,
        region: patch.region !== undefined ? patch.region : cur.region,
        detail: patch.detail !== undefined ? patch.detail : cur.detail,
        isDefault: patch.isDefault !== undefined ? patch.isDefault : cur.isDefault
      }
      s.addresses[index] = next
    }
  }

  /**
   * 删除地址
   * @param index 目标下标
   */
  static removeAddress(index: number) {
    const s = connectValuationStore();
    if (index >= 0 && index < s.addresses.length) {
      s.addresses.splice(index, 1)
    }
  }

  /**
   * 设置默认地址（该方法会保证仅一个默认地址）
   * @param index 目标下标
   */
  static setDefaultAddress(index: number) {
    const s = connectValuationStore();
    if (index < 0 || index >= s.addresses.length) {
      return
    }
    for (let i = 0; i < s.addresses.length; i++) {
      const cur = s.addresses[i]
      s.addresses[i] = {
        name: cur.name,
        phone: cur.phone,
        type: cur.type,
        region: cur.region,
        detail: cur.detail,
        isDefault: i === index
      }
    }
  }

  /**
   * 获取默认地址
   */
  static getDefaultAddress(): AddressItem | null {
    const s = connectValuationStore();
    const idx = s.addresses.findIndex(a => a.isDefault);
    return idx >= 0 ? s.addresses[idx] : null;
  }

  /**
   * 根据默认地址同步估价页选中地址；若无地址则清空
   */
  static syncSelectedAddressToDefault() {
    const s = connectValuationStore();
    if (!s.addresses || s.addresses.length === 0) {
      s.selectedPickupRegion = '';
      s.selectedPickupDetail = '';
      return;
    }
    const def = ValuationStoreAPI.getDefaultAddress();
    if (def) {
      s.selectedPickupRegion = def.region;
      s.selectedPickupDetail = def.detail;
    } else {
      s.selectedPickupRegion = '';
      s.selectedPickupDetail = '';
    }
  }
}
