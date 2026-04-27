import { iap } from '@kit.IAPKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { UtilLog } from '@hw-agconnect/util-log';
import {
  FinishStatus,
  MemberList,
  MemberParams,
  MemberSheetUtils,
  MemberStatusUtil,
  ProductsInfoOptions,
} from 'membership';
import { UPDATE_MEMBER_STATUS } from '../constant/Index';

@ObservedV2
export class MemberManageUtil {
  constructor(uiContext: UIContext) {
    this.uiContext = uiContext;
  }

  uiContext?: UIContext;
  lastPurchaseProductExpireTime: string = '';
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.uiContext?.getPromptAction().showToast({ message: this.getSubscribeMsg(params) });
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };

  static queryMemberStatus(uiContext: UIContext) {
    return new Promise<boolean>((resolve, reject) => {
      MemberStatusUtil.queryPurchase(uiContext.getHostContext() as common.UIAbilityContext).then((res) => {
        let autoRenewPurchasedList = res.renewList;
        let nonAutoRenewPurchasedList = res.nonRenewList;
        let nonConsumePurchasedList = res.nonConsumeList;

        let isMember = (autoRenewPurchasedList !== undefined && autoRenewPurchasedList?.length !== 0) ||
          nonAutoRenewPurchasedList?.length !== 0 ||
          nonConsumePurchasedList?.length !== 0;
        resolve(isMember);
      }).catch((err: BusinessError) => {
        reject(false);
        UtilLog.error(0xFF00, 'MemberShip',
          `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
      });
    });
  }

  getSubscribeMsg(param: MemberParams) {
    let message = '';
    if (param.status === FinishStatus.FINISHED) {
      message = '会员订阅成功';
      this.uiContext?.getHostContext()!.eventHub.emit(UPDATE_MEMBER_STATUS, true);
      MemberSheetUtils.close();
    } else if (param.status === FinishStatus.UNFINISHED) {
      message = `会员订阅失败，订阅错误码为${param.errCode}，错误原因为${param.errMsg}`;
    }
    return message;
  }

  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.uiContext?.getPromptAction().showToast({ message: `您已拥有会员` });
    }
  };
  queryExpireTime = (productId: string, time?: number): Promise<void> => {
    // 请求开发者服务器获取非周期订阅商品到期时间（涉及商品id、购买次数）
    return new Promise(() => {
      this.lastPurchaseProductExpireTime = 'xxxx-xx-xx';
    });
  };
  productsInfo: ProductsInfoOptions = {
    isSheet: true,
    themeColor: $r('sys.color.background_emphasize'),
    linearColors: [['#E5EDF5', 0.0], ['#0A59F7', 1.0]],
    btnFontColor: $r('sys.color.font_on_primary'),
    productsInfo: [
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
    ],
    privacyContent: '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。',
    lastPurchaseProductExpireTime: '',
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
  };
}