import { https, IUserInfo } from 'network';
import { AccountUtil, AppStorageMap, FormatUtil, Logger, RouterMap, RouterModule, UserInfoModel, } from 'commonlib';
import { IPositionRedemptionInfo } from 'network/src/main/ets/types/responseTypes/GetPositionRedemptionResp';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';
import { IRedemptionButton } from '../types';
import { MockStorageMap } from 'network/src/main/ets/mocks/Constants';
import { redemptionButtonData } from '../constants';
import { promptAction } from '@kit.ArkUI';

const TAG = '[RedemptionVM]';

@ObservedV2
export class RedemptionVM {
  private static _instance: RedemptionVM;
  @Trace public redemptionButton: IRedemptionButton[] = redemptionButtonData
  @Trace public userInfo: IUserInfo | undefined
  @Trace public userAccount: IUserAccount | undefined
  @Trace public positionRedemption: IPositionRedemptionInfo | undefined
  @Trace public share: ResourceStr | undefined
  @Trace public verificationCode: string = ''
  @Trace public isVerificationCodeRight: boolean = true
  @Trace public second: number = 60
  @Trace public timer: number | null = null
  @Trace public isRepeat: boolean = false
  @Trace public selectedMoneyIndex: number = 4
  @Trace public clock: number | undefined

  @Monitor('second')
  secondChange() {
    if (this.second === 0) {
      this.isRepeat = true
      clearInterval(this.timer)
      this.timer = null
      this.second = 60
    }
  }

  public static get instance() {
    if (!RedemptionVM._instance) {
      RedemptionVM._instance = new RedemptionVM();
    }
    return RedemptionVM._instance;
  }

  async init() {
    const userInfo = AppStorage.get<IUserInfo>(MockStorageMap.USER_INFO)
    if (userInfo) {
      this.userInfo = userInfo
    }
    await this.getUserAccount(1)
    const param = RouterModule.getNavParam<number>({
      url: RouterMap.POSITION_INFO,
    });
    if (param && this.userAccount !== undefined) {
      await this.getPositionRedemption(this.userAccount.id, param)
    }
  }

  clear() {
    this.userInfo = undefined
    this.userAccount = undefined
    this.positionRedemption = undefined
    this.share = undefined
    this.verificationCode = ''
    this.isVerificationCodeRight = true
    this.second = 60
    this.timer = null
    this.isRepeat = false
    this.selectedMoneyIndex = 4
    this.clock = undefined
  }

  public async getUserAccount(userId: number) {
    const res = await https.getUserAccount(userId);
    if (res.code === 0) {
      this.userAccount = res.data;
    }
  }

  public async getPositionRedemption(userId: number, id: number) {
    const res = await https.getPositionRedemption(userId, id);
    if (res.code === 0) {
      this.positionRedemption = res.data;
    }
  }

  public getRedemptionButton(index: number) {
    switch (index) {
      case 0:
        if (this.positionRedemption) {
          this.share = Math.floor(this.positionRedemption.share / 4) + ''
        }
        break
      case 1:
        if (this.positionRedemption) {
          this.share = Math.floor(this.positionRedemption.share / 3) + ''
        }
        break
      case 2:
        if (this.positionRedemption) {
          this.share = Math.floor(this.positionRedemption.share / 2) + ''
        }
        break
      case 3:
        if (this.positionRedemption) {
          this.share = Math.floor(this.positionRedemption.share) + ''
        }
        break
    }
  }

  public async sendVerificationCode(userId: number) {
    await https.sendVerificationCode(userId);
  }

  public async submitVerificationCode(code: string) {
    const res = await https.submitVerificationCode(code)
    if (res.code === 0) {
      if (res.data === 1) {
        this.isVerificationCodeRight = true
      } else {
        this.isVerificationCodeRight = false
      }
    }
  }

  public async submitPositionRedemption(id: number, userId: number, share: number, bankCardNo: string) {
    const res = await https.submitPositionRedemption({
      id,
      userId,
      share,
      bankCardNo,
    });
    if (res.code === 0) {
      this.positionRedemption = res.data;
    }
  }

  public countdown() {
    if (this.userAccount) {
      this.sendVerificationCode(this.userAccount.id)
    }
    this.timer = setInterval(() => {
      this.second = this.second - 1
    }, 1000)
  }

  public clearTimer() {
    this.isRepeat = false
    clearInterval(this.timer)
    this.timer = null
    this.second = 60
    this.verificationCode = ''
  }

  public getTimeText(): string {
    if (this.timer) {
      return `重新发送(${this.second}s)`
    } else {
      if (this.isRepeat) {
        return '重新发送'
      } else {
        return '点击发送'
      }
    }
  }

  public checkShare(): boolean {
    if (this.share && this.share !== '0') {
      return true
    }
    return false
  }

  public checkVerificationCode(): boolean {
    if (!this.verificationCode) {
      return true
    } else {
      if (this.isVerificationCodeRight) {
        return true
      } else {
        return false
      }
    }
  }

  public async submit(): Promise<boolean> {
    if (this.positionRedemption === undefined || this.userAccount === undefined) {
      return false
    }
    if (!this.verificationCode) {
      return false
    }
    if (this.share === undefined || this.share === '0') {
      return false
    }
    await this.submitVerificationCode(this.verificationCode)
    if (this.isVerificationCodeRight) {
      await this.submitPositionRedemption(this.positionRedemption.id, this.userAccount.id, Number(this.share),
        this.userAccount.bankCardNo)
      promptAction.showToast({ message: '赎回成功！', alignment: Alignment.Center, duration: 2000 });
      RouterModule.pop()
      return true
    } else {
      return false
    }
  }
}
