import { iap } from '@kit.IAPKit';
import { ProductInfo } from 'membership';


export class PackageConstants {
  public static packageInfo: ProductInfo[] = [
    {
      type: iap?.ProductType?.AUTORENEWABLE,
      productId: 'F0001',
      privileges: [
        {
          id: 'privilege_2',
          icon: $r('app.media.skin'),
          title: '会员主题',
          des: '',
        },
      ],
      privacyName: '连续包周服务协议',
      privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
        '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
        '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
        '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: 'F0002',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.ad'),
          title: '免广告',
          des: '',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.skin'),
          title: '个性皮肤',
          des: '',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.questions'),
          title: '提问咨询',
          des: '',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.service'),
          title: '专属客服',
          des: '',
        },
      ],
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: 'F0002',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.ad'),
          title: '免广告',
          des: '',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.skin'),
          title: '个性皮肤',
          des: '',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.questions'),
          title: '提问咨询',
          des: '',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.service'),
          title: '专属客服',
          des: '',
        },
      ],
    },
  ]

  public static PRIVACY_CONTENT =
    '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';
}
