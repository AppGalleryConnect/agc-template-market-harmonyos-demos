import { IGoods, ITemplate } from './Type';
import { CommonUtils } from '../common/Utils';
import { goodsList, address1, address2 } from 'module_base';

export class TemplateApi {
  static TEMPLATE_LIST: ITemplate[] =
    [
      {
        id: 1,
        name: '文件',
        sendAddress: address1,
        getAddress: address2,
        goods: {
          id: 1,
          name: '文件',
          weight: 1
        },
        shippingMethod: 1,
        paymentMethod: 1,
        weight: 1,
        time: '8:00 - 9:00'
      },
      {
        id: 2,
        name: '发票',
        sendAddress: address1,
        getAddress: address2,
        goods: {
          id: 3,
          name: '发票',
          weight: 1
        },
        shippingMethod: 1,
        paymentMethod: 1,
        weight: 1,
        time: '8:00 - 9:00'
      }
    ]
  static GOODS_LIST: IGoods[] = goodsList

  static getGoodsList(): Promise<IGoods[]> {
    return Promise.resolve(TemplateApi.GOODS_LIST);
  }

  static getTemplateList(): Promise<ITemplate[]> {
    return Promise.resolve(TemplateApi.TEMPLATE_LIST);
  }

  static getTemplate(id: number): Promise<ITemplate | undefined> {
    return Promise.resolve(TemplateApi.TEMPLATE_LIST.find(v => v.id === id));
  }

  static updateTemplate(data: ITemplate): Promise<boolean> {
    const target = TemplateApi.TEMPLATE_LIST.find(v => v.id === data.id);
    if (target) {
      CommonUtils.assign(target, data);
    }
    return Promise.resolve(true);
  }

  static deleteTemplate(id: number): Promise<boolean> {
    const targetIndex = TemplateApi.TEMPLATE_LIST.findIndex(v => v.id === id);
    if (targetIndex !== -1) {
      TemplateApi.TEMPLATE_LIST.splice(targetIndex, 1);
    }
    return Promise.resolve(true);
  }

  static addTemplate(data: ITemplate): Promise<boolean> {
    data.id = new Date().getTime();
    TemplateApi.TEMPLATE_LIST.splice(0, 0, data);
    return Promise.resolve(true);
  }
}
