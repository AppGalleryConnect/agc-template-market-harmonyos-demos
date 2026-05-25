import { ExamService, Video} from '@ohos_agcit/driver_license_exam_datasource'
import { AccountUtil, CommonConstants, CommonModel, showToast } from '@ohos_agcit/driver_license_exam_commonlib'
import { iap } from '@kit.IAPKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { common } from '@kit.AbilityKit';
import {
  FinishStatus,
  MemberSheetUtils,
  MemberParams,
  ProductsInfoOptions,
  MemberStatusUtil,
  MemberList,
} from 'membership';


@Builder
export function VideoListViewBuild() {
  VideoListView()
}

@ComponentV2
struct VideoListView {
  vm: CommonModel = CommonModel.instance;
  examService: ExamService = ExamService.instance(this.getUIContext().getHostContext() as Context);
  @Local videoList:Video[] = this.examService.getVideList();
  @Local bottomRectHeight: number = 0;
  @Local topRectHeight: number = 0;

  aboutToAppear(): void {
    this.bottomRectHeight = AppStorage.get('bottomRectHeight') || 0;
    this.topRectHeight = AppStorage.get('topRectHeight') || 0;
  }

  @Local lastPurchaseProductExpireTime: string = '';
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.getUIContext().getPromptAction().showToast({ message: '会员订阅成功' });
    MemberSheetUtils.close();
    if (params.type === iap.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.getUIContext().getPromptAction().showToast({ message: `您已拥有会员` });
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
    themeColor: $r('app.color.theme_green'),
    linearColors: [['#FFFFFF', 0.0], ['#E5EDF5', 0.5], ['#0A59F7', 1.0]],
    btnFontColor: $r('sys.color.font_on_primary'),
    // todo: 替换为您配置的商品ID及对应的权益
    productsInfo: [{
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
            icon: $r('app.media.privilege'),
            title: '权益2-1',
            des: '简介2-1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益2-2',
            des: '简介2-2',
          },
        ],
      },
      {
        type: iap?.ProductType?.NONRENEWABLE,
        productId: 'F0003',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '权益3-1',
            des: '简介3-1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益3-2',
            des: '简介3-2',
          },
          {
            id: 'privilege_3',
            icon: $r('app.media.privilege'),
            title: '权益3-3',
            des: '简介3-3',
          },
          {
            id: 'privilege_4',
            icon: $r('app.media.privilege'),
            title: '权益3-4',
            des: '简介3-4',
          },
          {
            id: 'privilege_5',
            icon: $r('app.media.privilege'),
            title: '权益3-5',
            des: '简介3-5',
          },
          {
            id: 'privilege_6',
            icon: $r('app.media.privilege'),
            title: '权益3-6',
            des: '简介3-6',
          },
          {
            id: 'privilege_7',
            icon: $r('app.media.privilege'),
            title: '权益3-7',
            des: '简介3-7',
          },
        ],
      },
      {
        type: iap?.ProductType?.NONRENEWABLE,
        productId: 'F0004',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '权益4-1',
            des: '简介4-1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益4-2',
            des: '简介4-2',
          },
        ],
      },
      {
        type: iap?.ProductType?.NONRENEWABLE,
        productId: 'F0005',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '权益5-1',
            des: '简介5-1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益5-2',
            des: '简介5-2',
          },
        ],
      },
      {
        type: iap?.ProductType?.AUTORENEWABLE,
        productId: 'F0006',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '权益6-1',
            des: '简介6-1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益16-2',
            des: '简介6-2',
          },
        ],
        privacyName: '连续包月服务协议',
        privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
          '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
          '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
          '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
      },
      {
        type: iap?.ProductType?.AUTORENEWABLE,
        productId: 'F0007',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '权益7-1',
            des: '简介7-1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益7-2',
            des: '简介7-2',
          },
        ],
        privacyName: '连续包季服务协议',
        privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
          '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
          '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
          '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
      },
      {
        type: iap?.ProductType?.NONCONSUMABLE,
        productId: 'F0008',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品8-权益1',
            des: '商品8-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '权益8-2',
            des: '简介8-2',
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

  queryMemberStatus(item:Video) {
    MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
      let autoRenewPurchasedList = res.renewList;
      let nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        // this.getUIContext().getPromptAction().showToast({ message: '您已开通会员' });
        this.vm.navStack.pushPathByName('videoDetailView', item)
      } else {
        MemberSheetUtils.open(this.productsInfo, this.getUIContext());
      }
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
    });
  }

  // 跳转登录页面
  private jumpLoginPage(quickLoginAnonymousPhone: string | undefined) {
    if (quickLoginAnonymousPhone) {
      const params: Record<string, Object> = { 'anonymousPhone': quickLoginAnonymousPhone };
      this.vm.navStack.pushPathByName('QuickLoginPage', params, true);
    } else {
      const hint: string = (this.getUIContext().getHostContext() as Context).resourceManager.getStringSync($r('app.string.get_mobile_number_error').id);
      showToast(hint, this.getUIContext());
    }
  }

  build() {
    NavDestination() {
      Column() {
        List({space:12}) {
          ForEach(this.videoList, (item:Video) => {
            ListItem() {
              Row({space:12}) {
                RelativeContainer() {
                  Image(item.poster)
                    .height(CommonConstants.FULL_HEIGHT)
                    .width(CommonConstants.FULL_WIDTH)
                    .borderRadius(8)

                  Image($r('app.media.player_btn_list'))
                    .height(24)
                    .height(24)
                    .alignRules({
                      bottom:{anchor:'__container__', align:VerticalAlign.Center},
                      left:{anchor:'__container__', align:HorizontalAlign.Center}
                    })
                    .offset({
                      x: -12,
                      y: 12
                    })

                  Text(item.time)
                    .fontSize(10)
                    .fontColor(Color.White)
                    .maxFontScale(1)
                    .alignRules({
                      bottom:{anchor:'__container__', align: VerticalAlign.Bottom},
                      right: {anchor:'__container__',align: HorizontalAlign.End}
                    })
                    .offset({
                      x: -8,
                      y: -10,
                    })
                }
                .height(CommonConstants.FULL_HEIGHT)
                .width(124)

                Column({space:8}) {
                  Row() {
                    Text(item.simpleDescription)
                      .fontSize(16)
                      .fontColor($r('sys.color.font_primary'))
                      .fontWeight(FontWeight.Medium)
                      .textOverflow({
                        overflow:TextOverflow.Ellipsis
                      })
                      .ellipsisMode(EllipsisMode.END)
                      .maxLines(1)
                      .maxFontScale(1)
                      .layoutWeight(1)

                    if (item.needVip) {
                      Image($r('app.media.vip'))
                        .width(24)
                        .height(24)
                    }
                  }

                  Text(item.description)
                    .fontSize(14)
                    .fontColor($r('sys.color.font_secondary'))
                    .fontWeight(FontWeight.Regular)
                    .maxFontScale(1)
                    .textOverflow({
                      overflow:TextOverflow.Ellipsis
                    })
                    .ellipsisMode(EllipsisMode.END)
                    .maxLines(3)
                }
                .layoutWeight(1)
              }
              .height(106)
              .width(CommonConstants.FULL_WIDTH)
              .backgroundColor($r('sys.color.background_primary'))
              .borderRadius(16)
              .padding(12)
              .onClick(() => {
                if (item.needVip && AccountUtil.getAccountInfo().idToken === '') {
                  AccountUtil.quickLogin();
                  // mock登录，真实使用场景需删除
                  this.jumpLoginPage('a000******00');
                } else if (item.needVip) {
                  this.queryMemberStatus(item);
                } else {
                  this.vm.navStack.pushPathByName('videoDetailView', item)
                }
              })
            }

          }, (item:Video) => JSON.stringify(item))
        }
        .scrollBar(BarState.Off)
      }
      .width(CommonConstants.FULL_WIDTH)
      .padding({
        top:12,
        left: 16,
        right: 16
      })
    }
    .title('视频课程')
    .height(CommonConstants.FULL_HEIGHT)
    .width(CommonConstants.FULL_WIDTH)
    .padding({
      top:this.getUIContext().px2vp(this.topRectHeight),
      bottom: this.getUIContext().px2vp(this.bottomRectHeight)
    })
    .backgroundColor($r('sys.color.background_secondary'))
  }
}
