import { iap } from '@kit.IAPKit';
import { ProductInfo } from 'membership';

export const PRIVACY_CONTENT =
  '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
    '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
    '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
    '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';

// todo: 替换为您配置的商品ID及对应的权益
export const PRODUCTS_INFO: ProductInfo[] =
  [{
    type: iap?.ProductType?.NONRENEWABLE,
    productId: 'F0005',
    privileges: [
      {
        id: 'privilege_1',
        icon: $r('app.media.ic_privilege_1'),
        title: '9折商品',
        des: '下单立享整单9折',
      },
      {
        id: 'privilege_2',
        icon: $r('app.media.ic_privilege_2'),
        title: '月月领券',
        des: '每月超多好券等待领取',
      },
      {
        id: 'privilege_3',
        icon: $r('app.media.ic_privilege_3'),
        title: '无限免邮',
        des: '无限次数，自动包邮',
      },
      {
        id: 'privilege_4',
        icon: $r('app.media.ic_privilege_4'),
        title: '免费退换货',
        des: '无限次数，退换不花钱',
      },
    ],
  }];