import { iap } from '@kit.IAPKit';
import { ProductInfo } from 'membership';

export const privacy: string = '欢迎您使用我们的快递物流模板，您的信任对我们很重要，我们将严格遵守法律法规要求的安全保护措施，保护您的个人信息安全可控。'

export const PRIVACY_CONTENT =
  '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
    '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
    '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
    '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';

// todo: 替换为您配置的商品ID及对应的权益
export const PRODUCTS_INFO: ProductInfo[] = [
  {
    type: iap?.ProductType?.NONRENEWABLE,
    productId: '20253',
    privileges: [
      {
        id: 'privilege_1',
        icon: $r('app.media.ic_vip_one'),
        title: '月月领券',
        des: '每月超多好券等待领取',
      },
      {
        id: 'privilege_2',
        icon: $r('app.media.ic_vip_discount'),
        title: '会员寄件',
        des: '寄快递不限价格享9折优惠',
      },
    ],
  },
  {
    type: iap?.ProductType?.NONRENEWABLE,
    productId: '20252',
    privileges: [
      {
        id: 'privilege_1',
        icon: $r('app.media.ic_vip_one'),
        title: '月月领券',
        des: '每月超多好券等待领取',
      },
      {
        id: 'privilege_2',
        icon: $r('app.media.ic_vip_discount'),
        title: '会员寄件',
        des: '寄快递不限价格享9折优惠',
      },
    ],
  },
];