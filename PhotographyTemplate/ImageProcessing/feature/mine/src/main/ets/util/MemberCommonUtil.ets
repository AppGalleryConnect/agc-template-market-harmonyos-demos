import { BusinessError } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { iap } from '@kit.IAPKit';
import { FinishStatus, MemberList, MemberParams, MemberSheetUtils, MemberStatusUtil, ProductInfo, ProductsInfoOptions } from 'membership';
import { HttpApi, Logger, User, UserInfo } from 'commonlib';

/**
 * 会员相关公共工具类
 */
export class MemberCommonUtil {
  // 隐私政策内容
  static readonly PRIVACY_CONTENT =
    '   欢迎您使用"xxxx"。"xxxx"采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称"华为"）之间关于"xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本"xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称"基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。';

  // 产品信息配置
  static readonly PRODUCTS_INFO: ProductInfo[] = [
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: '20253',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '海量素材资源，随意使用',
          des: '专属趣味贴纸，特殊文字',
        },
      ],
    },
    {
      type: iap?.ProductType?.NONRENEWABLE,
      productId: '20252',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '海量素材资源，随意使用',
          des: '专属趣味贴纸，特殊文字',
        },
      ],
    },
    {
      type: iap?.ProductType?.AUTORENEWABLE,
      productId: 'F0001',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '权益1-1',
          des: '简介1-1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '权益1-2',
          des: '简介1-2',
        },
      ],
    },
  ];

  /**
   * 创建通用的产品信息配置（用于Sheet形式）
   */
  static createProductsInfoForSheet(
    subscribeCallBack: (params: MemberParams) => Promise<void>,
    queryExpireTime: (productId: string, time?: number) => Promise<string>,
    ownedMemberCallBack: (list: MemberList) => Promise<void>,
    lastPurchaseProductExpireTime: string = ''
  ): ProductsInfoOptions {
    return {
      isSheet: true,
      themeColor: '#8981F7',
      linearColors: [['#C1BDF8', 0.5], ['#F1A5F0', 1.0]],
      btnFontColor: $r('sys.color.font_on_primary'),
      productsInfo: MemberCommonUtil.PRODUCTS_INFO.filter(p => p.type === iap?.ProductType?.NONRENEWABLE),
      privacyContent: MemberCommonUtil.PRIVACY_CONTENT,
      lastPurchaseProductExpireTime: lastPurchaseProductExpireTime,
      subscribeCallBack: subscribeCallBack,
      queryExpireTime: queryExpireTime,
      ownedMemberCallBack: ownedMemberCallBack,
    };
  }

  /**
   * 通用订阅回调日志
   */
  static subscribeEventLogger(params: MemberParams): void {
    if (params.status === FinishStatus.FINISHED) {
      Logger.info('MemberShip', 'Subscription successful');
    } else if (params.status === FinishStatus.UNFINISHED) {
      Logger.error('MemberShip', `Subscription failed. Error code: ${params.errCode}, message: ${params.errMsg}`);
    }
  }

  /**
   * 通用会员状态查询回调
   */
  static async ownedMemberEvent(list: MemberList, onHasMember: () => void, onNoMember: () => void): Promise<void> {
    if (list.renewList.length || list.nonRenewList.length) {
      onHasMember();
    } else {
      onNoMember();
    }
  }

  /**
   * 显示Toast消息
   */
  static showToast(uiContext: UIContext, message: ResourceStr): void {
    const prompt = uiContext.getPromptAction();
    try {
      prompt.showToast({ message });
    } catch (e) {
      Logger.error('MemberShip', `showToast failed. error: ${JSON.stringify(e)}`);
    }
  }

  /**
   * 订阅成功，更新用户的会员状态, mock操作
   */
  static async subscribeMembership(userInfo: UserInfo) {
    const curExpireTime = userInfo.vipExpireTime;
    const nextYearTimestamp = new Date().setFullYear(new Date(curExpireTime).getFullYear() + 1);
    const data = {
      userId: userInfo.id,
      isVip: 1,
      vipExpireTime: nextYearTimestamp,
    } as User;
    await HttpApi.updateUserInfo(data);
    userInfo.isVip = true;
    userInfo.vipExpireTime = nextYearTimestamp;
  }
}