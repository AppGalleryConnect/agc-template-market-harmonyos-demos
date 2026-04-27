import { iap } from '@kit.IAPKit';
import { PersistenceV2 } from '@kit.ArkUI';
import { UtilLog as Logger } from '@hw-agconnect/util-log';
import { MemberStatus, UserServiceApi } from 'module_base';
import { FinishStatus, MemberList, MemberParams, MemberShipPage, ProductInfo } from 'membership';

@ComponentV2
export struct MemberShipSubscribe {
  navPathStack: NavPathStack = new NavPathStack();
  @Local lastPurchaseProductExpireTime: string = '';
  @Local memberStatus: MemberStatus =
    PersistenceV2.connect(MemberStatus, 'MemberStatus', () => new MemberStatus())!;
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList?.length || list.nonRenewList?.length || list.nonConsumeList?.length) {
      Logger.info('您已拥有会员');
    }
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return UserServiceApi.getProductExpireTime(productId, time).then((res) => {
      this.lastPurchaseProductExpireTime = res;
    });
  };

  getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
      this.memberStatus.isMember = true;
    } else if (param.status === FinishStatus.UNFINISHED) {
      message = `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`;
    }
    return message;
  }

  build() {
    NavDestination() {
      MemberShipPage({
        routerModule: this.navPathStack,
        themeColor: '#D3B685',
        linearColors: [['#F5F1E5', 0.0], ['#F1D1A5', 1.0]],
        btnFontColor: $r('sys.color.font_on_primary'),
        isSheet: false,
        lastPurchaseProductExpireTime: this.lastPurchaseProductExpireTime,
        productsInfo: PRODUCTS_INFO,
        privacyContent: PRIVACY_CONTENT,
        subscribeCallBack: this.subscribeEvent,
        queryExpireTime: this.queryExpireTime,
        ownedMemberCallBack: this.ownedMemberEvent,
      });
    }.hideTitleBar(true).onReady((ctx) => {
      this.navPathStack = ctx.pathStack;
    });
  }
}

@Builder
export function MemberShipSubscribeBuilder() {
  MemberShipSubscribe();
}

export const PRIVACY_CONTENT =
  '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
    '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
    '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
    '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';

// todo: 替换为您配置的商品ID及对应的权益
export const PRODUCTS_INFO: ProductInfo[] =
  [
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: '20253',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege_remove_ad'),
          title: '免广告',
          des: '去除广告，免除打扰',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege_remove_restriction'),
          title: '次数无限制',
          des: '无限次数',
        },
        {
          id: 'privilege_3',
          icon: $r('app.media.privilege_time_restriction'),
          title: '素材无限制',
          des: '会员素材尽情使用',
        },
      ],
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: '20252',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege_remove_ad'),
          title: '免广告',
          des: '去除广告，免除打扰',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege_remove_restriction'),
          title: '次数无限制',
          des: '无限次数',
        },
        {
          id: 'privilege_3',
          icon: $r('app.media.privilege_time_restriction'),
          title: '素材无限制',
          des: '会员素材尽情使用',
        },
      ],
    },
  ];
