import { Template } from 'lib_foundation';

// 寄件/收件人地址信息
@ObservedV2
export class AddressInfoModel {
  // 地址id
  @Trace addressId: number = 0;
  // 姓名
  @Trace name: string = '';
  // 手机号
  @Trace phone: string = '';
  // 地址
  @Trace fullAddress: string = '';
  // 省份
  @Trace province: string = '';
  // 城市
  @Trace city: string = '';
}

// 自定义模板信息
@ObservedV2
export class TemplateInfo {
  // 模板id
  id: number = 0;
  // 所属用户id
  userId: number = 0;
  // 模板名称
  @Trace name: string = '';
  // 物品名称
  goodsName: string = '';
  // 物品重量
  goodsWeight: number = 0;
  // 寄件方式
  shippingMethod: number = 0;
  // 支付方式
  paymentMethod: number = 0;

  constructor(template?: Template) {
    if (template) {
      this.id = template.id;
      this.userId = template.userId;
      this.name = template.name;
      this.goodsName = template.goodsName;
      this.goodsWeight = template.weight;
      this.shippingMethod = template.shippingMethod;
      this.paymentMethod = template.paymentMethod;
    }
  }
}

// 更多操作菜单信息
export interface MoreMenuItem {
  name: ResourceStr,
  fontColor?: ResourceColor,
  onClick: (template: TemplateInfo) => void
}