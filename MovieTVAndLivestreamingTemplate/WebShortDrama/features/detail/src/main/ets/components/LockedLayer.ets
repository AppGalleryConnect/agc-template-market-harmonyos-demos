import { getMedia, NAV_PAGE_NAME } from '@agctemplate/resources'
import { AppStorageV2 } from '@kit.ArkUI'
import { AppStorageKeys, BreakPoint, FontModel, fp2pxUtil, UserInfoModel } from '@agctemplate/widgets'
import { appRouter, WindowManager } from '@agctemplate/utils';
import { aggregatedPaymentService, CashierPicker, PaymentType } from 'aggregated_payment';
import { UIContext } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
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

@ComponentV2
export struct LockedLayer {
  @Local isShowUnlockSheet: boolean = false
  @Local _isShowVIPSheet: boolean = false
  @Local isEnableVIPSheet: boolean = true
  @Local isShowBuySheet: boolean = false
  @Local customDialogId: number = 0
  @Local unIndex: number = 0
  @Local userInfo: UserInfoModel = AppStorageV2.connect(UserInfoModel, 'userInfo', () => new UserInfoModel())!
  @Local bonus: number = this.userInfo.bonus
  @Local vipExpiryDate: Date = new Date
  @Local isPaymentChannelSheetShow: boolean = false
  @Local isMemberServiceAgreementSheetShow: boolean = false
  @Local bonusAgree: boolean = true
  @Event onUnLocked: Function
  breakPoint = AppStorageV2.connect(BreakPoint, AppStorageKeys.CURRENT_BREAK_POINT,
    () => new BreakPoint())!;
  @Local purAgree: boolean = false
  private uiContext: UIContext = this.getUIContext();
  private navPathStack: NavPathStack = new NavPathStack();
  @Local fontModel: FontModel = AppStorageV2.connect(FontModel, () => new FontModel())!;

  @Local lastPurchaseProductExpireTime: string = '';
  subscribeEvent = async (params: MemberParams): Promise<void> => {
    this.userInfo.isVip = true;
    this.getUIContext().getPromptAction().showToast({ message: '会员订阅成功' });
    if (params.type === iap?.ProductType.NONRENEWABLE && params.status === FinishStatus.FINISHED) {
      this.queryExpireTime(params.productId, params.purchaseTime);
    }
  };
  ownedMemberEvent = async (list: MemberList): Promise<void> => {
    if (list.renewList.length || list.nonRenewList.length) {
      this.userInfo.isVip = true;
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
    themeColor: '#BD9164',
    linearColors: [['#FFFFFF', 0.0], ['#FCF5EB', 0.5], ['#F2D2A6', 1.0]],
    btnFontColor: $r('sys.color.font_on_primary'),
    // todo: 替换为您配置的商品ID及对应的权益
    productsInfo: [{
      type: iap?.ProductType.AUTORENEWABLE,
      productId: 'F0001',
      privileges: [
        {
          id: 'privilege_1',
          icon: $r('app.media.privilege'),
          title: '商品1-权益1',
          des: '商品1-权益介绍1',
        },
        {
          id: 'privilege_2',
          icon: $r('app.media.privilege'),
          title: '商品1-权益2',
          des: '商品1-权益介绍2',
        },
      ],
      privacyName: '连续包周服务协议',
      privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
        '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
        '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
        '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
    },
      {
        type: iap?.ProductType.AUTORENEWABLE,
        productId: 'F0006',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品2-权益1',
            des: '商品2-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品2-权益2',
            des: '商品2-权益介绍2',
          },
        ],
        privacyName: '连续包月服务协议',
        privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
          '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
          '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
          '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
      },
      {
        type: iap?.ProductType.AUTORENEWABLE,
        productId: 'F0007',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品3-权益1',
            des: '商品3-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品3-权益2',
            des: '商品3-权益介绍2',
          },
        ],
        privacyName: '连续包季服务协议',
        privacyContent: '   本协议是您（以下简称“用户”）与xxx（以下简称“开发者”）就您通过华为应用内支付（HUAWEI IAP）服务购买开发者提供的续期订阅商品（以下简称“订阅商品”）所订立的具有法律约束力的服务协议。华为服务（香港）有限公司（以下简称“华为”）为您提供应用内支付技术支持服务，您在使用本连续包期服务前，应仔细阅读并充分理解本协议所有条款，尤其是涉及您重大权益的条款（包括但不限于续期规则、取消方式、费用条款、免责声明等）。您通过华为应用内支付完成订阅商品购买或激活连续包期服务，即视为您已完全接受本协议全部内容，同意受本协议约束。\n' +
          '   本协议适用于用户通过华为IAP服务购买的所有续期订阅商品的连续包期服务，涵盖订阅激活、服务使用、自动续期、订阅管理（取消、恢复、切换）、费用支付、退款处理等全流程相关权利义务约定。\n' +
          '   用户可随时取消连续包期服务，取消操作不影响当期订阅服务的使用，仅停止下一期自动续期。取消路径：打开华为应用市场/相关应用 → 进入“我的”→ 找到“支付与购买”→ 选择“订阅管理”→ 找到对应订阅商品 → 点击“取消订阅”，按提示完成操作（也可通过应用内提供的“订阅管理”入口跳转至华为订阅管理页面）。\n' +
          '   取消订阅后，用户仍可在当期订阅周期结束前享受完整服务，周期结束后服务自动终止，不再产生续期扣费。',
      },
      {
        type: iap?.ProductType.NONRENEWABLE,
        productId: 'F0003',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品4-权益1',
            des: '商品4-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品4-权益2',
            des: '商品4-权益介绍2',
          },
        ],
      },
      {
        type: iap?.ProductType.NONRENEWABLE,
        productId: 'F0002',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品5-权益1',
            des: '商品5-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品5-权益2',
            des: '商品5-权益介绍2',
          },
        ],
      },
      {
        type: iap?.ProductType.NONRENEWABLE,
        productId: 'F0005',
        privileges: [
          {
            id: 'privilege_1',
            icon: $r('app.media.privilege'),
            title: '商品6-权益1',
            des: '商品6-权益介绍1',
          },
          {
            id: 'privilege_2',
            icon: $r('app.media.privilege'),
            title: '商品6-权益2',
            des: '商品6-权益介绍2',
          },
        ],
      },
      {
        type: iap?.ProductType.NONCONSUMABLE,
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
            title: '商品8-权益2',
            des: '商品8-权益介绍2',
          },
        ],
      }],
    privacyContent: '   欢迎您使用“xxxx”。“xxxx”采用收费与免费结合的方式。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，您就可以使用会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
      '   本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“xxxx"提供的各种付费服务签订的服务协议，描述了华为与xxxx付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，您可享受会员权益。 \n' +
      '   您同意本“xxxx"付费服务协议条款即表示同意遵守《xxxx用户协议》《关于xxxx与隐私的声明》（以下称“基础协议"），本协议未涉及事项以《xxxx用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。 \n' +
      '   华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。请您仔细审阅并决定接受或不接受本服务协议。',
    lastPurchaseProductExpireTime: '',
    subscribeCallBack: this.subscribeEvent,
    queryExpireTime: this.queryExpireTime,
    ownedMemberCallBack: this.ownedMemberEvent,
  };

  queryMemberStatus() {
    MemberStatusUtil.queryPurchase(this.getUIContext().getHostContext() as common.UIAbilityContext).then((res) => {
      let autoRenewPurchasedList = res.renewList;
      let nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.userInfo.isVip = true;
        this.getUIContext().getPromptAction().showToast({ message: '您已开通会员' });
      } else {
        MemberSheetUtils.open(this.productsInfo, this.getUIContext());
        this.isEnableVIPSheet = true
      }
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'MemberShip',
        `Failed to query purchase record. Code is ${err.code}, message is ${err.message}`);
    });
  }

  private cashierPicker: CashierPicker = new CashierPicker(this.uiContext)
    .onRealPayment(async (type: PaymentType) => {
      // todo: 根据支付类型向服务器请求支付所需参数
      if (type === PaymentType.ALIPAY) {
        /**
         * 请求拉起支付宝
         *
         * 临时测试时，orderInfo 不推荐传入空字符串，这会导致跳转至支付宝行为仅仅是跳转，不会有支付相关的交互
         * 未安装支付宝且参数真实时，SDK 会尝试使用 this.navPathStack 跳转至 H5 页面继续支付，该参数可不传
         */
        aggregatedPaymentService.requestPaymentByAliPay({ orderInfo: 'ORDER_INFO' }, this.navPathStack);
      } else if (type === PaymentType.HUAWEI) {
        /**
         * 请求拉起华为支付
         */
        if (deviceInfo.marketName === 'emulator') {
          this.showToast('华为支付在模拟器场景下无任何响应');
          return;
        }
        aggregatedPaymentService.requestPaymentByHuawei(this.uiContext, { orderStr: '' });
      } else if (type === PaymentType.WECHAT) {
        /**
         * 请求拉起微信支付
         *
         * 微信支持获取拉起结果，如果拉起成功，则可以进一步尝试等待支付回调。如果拉起失败，则不会有支付回调。
         */
        const isWeChatOpenSuccess: boolean =
          await aggregatedPaymentService.requestPaymentByWeChat(this.uiContext, {
            partnerId: '',
            prepayId: '',
            nonceStr: '',
            timeStamp: '',
            sign: ''
          });
        if (!isWeChatOpenSuccess) {
          this.showToast('微信拉起失败');
        }
      }
    })
    .onWillDismiss((reason: DismissReason) => {
      if (reason === DismissReason.TOUCH_OUTSIDE) {
        this.showToast('已拦截点击其它区域进行关闭的交互方式');
      } else {
        this.cashierPicker.close();
      }
    });

  private showToast(msg: string): void {
    this.uiContext.getPromptAction().showToast({ message: `Test: ${msg}` });
  }

  public aboutToAppear(): void {
    // todo: 端侧支付回调仅可用于参考，以辅助提升支付结果判定效率，不建议完全依赖。如：实际支付成功，但支付回调没有触发。
    aggregatedPaymentService.registerPaymentCallback(
      (type: PaymentType, isSuccess: boolean) => {
      }
    );
  }

  public aboutToDisappear(): void {
    aggregatedPaymentService.unregisterAllPaymentCallbacks();
  }

  build() {
    Stack() {
      Column() {
        Row() {
          Row() {
            Image(getMedia('app.media.ic_lock'))
              .width(16)
              .margin({ left: 16, right: 8 })
            Text('看点解锁/单集购买')
              .width(135)
              .height(21)
              .font({ weight: 500, size: fp2pxUtil(16) })
              .fontColor($r('sys.color.font_on_primary'))
          }
          .width('100%')
        }
        .width(191)
        .height(40)
        .borderRadius(20)
        .backgroundColor('#BD9164')
        .margin({ bottom: 24 })
        .bindSheet($$this.isShowUnlockSheet, this.unlockSheet(), {
          height: 468,
          showClose: true,
          title: { title: '解锁剧集' },
          preferType: SheetType.CENTER,
          backgroundColor: $r('sys.color.comp_background_tertiary'),
          blurStyle: BlurStyle.COMPONENT_ULTRA_THICK
        })
        .onClick(() => {
          if (this.userInfo.isPhoneAssociated) {
            this.isShowUnlockSheet = !this.isShowUnlockSheet
          } else {
            WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
            appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
          }
        })

        Text('开通会员看全集 >')
          .enabled(this.isEnableVIPSheet)
          .font({ weight: 500, size: this.fontModel.getFg(16) })
          .fontColor('#fff')
          .onClick(() => {
            this.isEnableVIPSheet = false
            if (this.userInfo.isPhoneAssociated) {
              this.queryMemberStatus();
            } else {
              WindowManager.setWindowSystemBarProperties({ statusBarContentColor: '#e6000000' })
              appRouter.push({ builderName: NAV_PAGE_NAME.LoginPage.name, params: { isChange: true } })
              this.isEnableVIPSheet = true
            }
          })
      }
    }
    .zIndex(200)
    .width('100%')
    .height(this.breakPoint.value === 'sm' ? '93%' : '100%')
    // .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
    .id('LockLayer')
  }

  @Builder
  unlockSheet() {
    Column() {
      Text(this.unIndex === 0 ? `看点余额：${this.userInfo.bonus}` : '单集购买')
        .font({ weight: 400, size: 14 })
        .width('100%')
        .margin({ bottom: 12, top: 12 })

      Row() {
        Column() {
          Text('看点解锁')
            .fontSize(14)
            .fontColor(this.userInfo.bonus >= 100 ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })

          Column() {
            Text() {
              Span('100')
                .fontWeight(600)
                .fontSize(28)
              Span('点')
                .fontWeight(400)
                .fontSize(14)
            }
            .fontColor(this.userInfo.bonus >= 100 ? $r('sys.color.font_primary') : $r('sys.color.font_tertiary'))
          }
        }
        .border({
          width: this.unIndex === 0 ? 2 : 1,
          color: this.unIndex === 0 && this.userInfo.bonus >= 100 ? '#BD9164' : '#0d000000',
        })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(16)
        .width(160)
        .height(90)
        .margin({ right: 8 })
        .clip(true)
        .onClick(() => {
          this.unIndex = 0
        })
        .justifyContent(FlexAlign.Center)

        Column() {
          Text('单集购买')
            .fontSize(14)
            .fontColor($r('sys.color.font_primary'))
            .fontWeight(FontWeight.Medium)
            .margin({ bottom: 8 })

          Column() {
            Text() {
              Span('¥')
                .fontWeight(400)
                .fontSize(14)
              Span('1')
                .fontWeight(600)
                .fontSize(28)
              Span('¥3')
                .fontSize(12)
                .fontColor($r('sys.color.font_tertiary'))
                .decoration({ type: TextDecorationType.LineThrough })
            }
          }
        }
        .backgroundColor($r('sys.color.comp_background_primary'))
        .border({
          width: this.unIndex === 1 ? 2 : 1,
          color: this.unIndex === 1 ? '#BD9164' : '#0d000000',
        })
        .borderRadius(16)
        .width(160)
        .height(90)
        .clip(true)
        .onClick(() => {
          this.unIndex = 1
        })
        .justifyContent(FlexAlign.Center)
      }
      .margin({ bottom: 12 })

      Row() {
        if (this.unIndex === 0) {
          Checkbox({ name: this.unIndex === 0 ? 'checkbox1' : '2' })
            .select(this.unIndex === 0 ? this.bonusAgree : this.purAgree)
            .selectedColor(true ? '#EC6E45' : $r('sys.color.comp_background_emphasize'))
            .onChange((value) => {
              if (this.unIndex === 0) {
                this.bonusAgree = value
              } else {
                this.purAgree = value
              }
            })
            .width(20)
            .aspectRatio(1)

          Text(this.unIndex === 0 ? '自动解锁下一集' : '自动购买下一集')
            .font({ weight: 400, size: 12 })
        } else {
          Blank()
            .height(28)
        }
      }
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 111 })
      .width('100%')

      Button(this.unIndex === 0 ? '立即开通' : '立即购买')
        .backgroundColor(this.unIndex === 0 && this.userInfo.bonus < 100 ? '#D6C6B6' : '#BD9164')
        .fontColor($r('sys.color.font_on_primary'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('sys.float.Body_L'))
        .width('100%')
        .height(40)
        .margin({ bottom: 8 })
        // .enabled(this.unIndex === 0 ? this.userInfo.bonus >= 100 ? true : false : true)
        .onClick(() => {
          if (this.unIndex === 0 && this.userInfo.bonus >= 100) {
            // 单集解锁
            this.bonus -= 100
            this.isShowUnlockSheet = false
            this.onUnLocked?.()
          } else if (this.unIndex === 1) {
            this.isShowUnlockSheet = false
            this.cashierPicker
              .reset() // 内部状态重置
              .setAmount(100) // 支付金额，单位：分
              .setTradeSummary('单集购买') // 订单摘要 (可选，不填则不显示)
              .open();
          } else if (this.userInfo.bonus < 100) {
            this.getUIContext().getPromptAction().showToast({ message: '看点余额不足' })
          }
        })

      Column() {
        Text('开通会员')
          .fontColor('#BD9164')
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
      }
      .enabled(this.isEnableVIPSheet)
      .width('100%')
      .height(40)
      .justifyContent(FlexAlign.Center)
      .onClick(() => {
        this.isEnableVIPSheet = false;
        this.queryMemberStatus();
      })
    }
    .padding({ left: 16, right: 16 })
  }

  @Builder
  memberServiceAgreementSheet() {
    Column() {
      Image($r('app.media.pic'))
        .height(30)
        .margin({ bottom: 18 })

      Text('会员服务协议')
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 4 })

      Text('更新日期：2025年5月25日')
        .fontSize(14)
        .fontWeight(400)
        .lineHeight(19)
        .fontColor($r('sys.color.font_secondary'))
        .margin({ bottom: 24 })

      Column() {
        Text('欢迎您使用“华为短剧”。“华为短剧”采用收费。您须注册华为账号后，才能继续进行购买服务。通过购买程序支付费用后，' +
          '您就可以使用短剧会员所提供的收费服务。在开始购买程序之前，请您首先同意并接受以下服务条款。\n' +
          '本协议是您与华为软件技术有限公司（以下统称“华为”）之间关于“华为直播”提供的各种付费服务签订的服务协议，' +
          '描述了华为与直播付费服务用户之间关于软件许可以及服务使用及相关方面的权利义务。同意本协议，' +
          '您可享受会员权益。\n您同意本“华为短剧”付费服务协议条款即表示同意遵守《华为短剧用户协议》《关于华为短剧与隐私的声明》' +
          '（以下称“基础协议”），本协议未涉及事项以《华为短剧用户协议》为准，若您拒绝接受本协议，不影响已同意的基础协议。\n' +
          '华为在此特别提醒，请事先仔细阅读本服务协议中各项条款，包括但不限于免除或者限制华为责任的免责条款以及对用户的权利限制条款。' +
          '请您仔细审阅并决定接受或不接受本服务协议。若您拒绝接受本协议，不影响已同意的基础协议。')
          .fontSize(16)
          .fontWeight(400)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
      }
    }
    .margin({ top: 72 })
    .height(636)
    .padding({ left: 16, right: 16 })
  }

  @Builder
  automaticRenewalAgreement() {
    Column() {
      Text('自动续费规则')
        .fontSize(20)
        .fontWeight(700)
        .lineHeight(27)
        .fontColor($r('sys.color.font_primary'))
        .margin({ bottom: 15 })
      Column() {
        Text('1.自动续费前5日将通过push方式、短信\n' +
          '方式提醒您；\n' +
          '2.开通服务后，系统通过订阅用户账户\n' +
          '扣除下一计费周期（月/季/年），同时\n' +
          '在会员到期当天/前一天自动续费，不同\n' +
          '支付平台，不同会员的到期自动续费时\n' +
          '间不同；\n' +
          '3.您可以通过以下任一方式取消自动续\n' +
          '费：\n' +
          '1）本应用内：在本应用中前往“我的”>\n' +
          '“会员中心”>“会员管理”，该页面展示了\n' +
          '所有自动续订项目，点击相应连包会员\n' +
          '卡片，进入“订阅详情”页面，您可根据\n' +
          '需要取消自动续订服务；\n' +
          '2）支付宝支付:前往“支付宝”>“我的’\n' +
          '，点击“设置”图标，前往“支付设置”>“\n' +
          '免密支付/自动扣款”，找到签约的本应\n' +
          '用自动续订服务，并关闭该服务，即可\n' +
          '取消自动续订；\n' +
          '3）微信支付：前往“微信”>“我”>“服务\n' +
          '”>“钱包”>“支付设置”>“自动续费”，找\n' +
          '到签约的本应用自动续订服务，并关闭\n' +
          '该服务，即可取消自动续订')
          .fontSize(16)
          .margin({ bottom: 16 })
          .fontWeight(400)
          .lineHeight(21)
          .fontColor($r('sys.color.font_primary'))
      }

      Text('知道了')
        .fontColor(true ? '#EC6E45' : $r('sys.color.comp_background_emphasize'))
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(21)
        .padding(9)
        .onClick(() => {
          this.getUIContext().getPromptAction().closeCustomDialog(this.customDialogId)
        })
    }
    .padding({
      top: 15,
      bottom: 9,
      left: 24,
      right: 24
    })
  }

  @Builder
  titleBuilder() {
    Row() {
      Image(getMedia('app.media.arrow_back'))
        .width(40)
        .margin({ right: 8 })
        .onClick(() => {
          this._isShowVIPSheet = false
        })
      Text('开通会员')
        .font({ weight: 700, size: 20 })
    }
    .width('100%')
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Center)
  }
}

@Builder
export function
lockedBuilder(onUnlocked: Function) {
  LockedLayer({
    onUnLocked: onUnlocked
  })
}