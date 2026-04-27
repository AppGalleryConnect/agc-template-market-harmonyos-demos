import { getUserInfo } from 'lib_foundation';
import { BaseViewModel, contextUtil, Logger } from 'module_base'
import { emitter } from '@kit.BasicServicesKit';
import { MemberStatusUtil } from 'membership';
import { common } from '@kit.AbilityKit';

@ObservedV2
export class QuickLoginPageVM extends BaseViewModel {
  private static _instance: QuickLoginPageVM;
  @Trace public openMock: boolean = true

  public static get instance() {
    if (!QuickLoginPageVM._instance) {
      QuickLoginPageVM._instance = new QuickLoginPageVM();
    }
    return QuickLoginPageVM._instance;
  }

  public async login() {
    const res = await getUserInfo();
    this.queryMemberStatus()
    this.userInfoModel.isLogin = true
    this.userInfoModel.id = res.id
    this.userInfoModel.name = res.name
    this.userInfoModel.nickname = res.nickname
    this.userInfoModel.sex = res.sex
    this.userInfoModel.cellphone = res.cellphone
    this.userInfoModel.birthday = res.birthday
    this.userInfoModel.avatar = res.avatar
    this.userInfoModel.isVip = res.isVip
    this.userInfoModel.points = res.id
    this.userInfoModel.couponList = res.couponList
    this.userInfoModel.realNameAuthFlag = res.realNameAuthFlag
    let info: emitter.EventData = {
      data: {
        login: true,
      },
    };
    try {
      emitter.emit('login', info);
    } catch (e) {
      Logger.error(JSON.stringify(e))
    }
  }


  async queryMemberStatus() {
    const res = await MemberStatusUtil.queryPurchase(contextUtil.getContext() as common.UIAbilityContext)
    if (res) {
      const autoRenewPurchasedList = res.renewList;
      const nonAutoRenewPurchasedList = res.nonRenewList;

      if (autoRenewPurchasedList?.length || nonAutoRenewPurchasedList?.length) {
        this.userInfoModel.isVip = true
      } else {
        this.userInfoModel.isVip = false
      }
    } else {
      this.userInfoModel.isVip = false
    }
  }
}
