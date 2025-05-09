import { https, IUserInfo } from 'network';
import { IPositionItem } from 'network/src/main/ets/types/responseTypes/GetPositionListResp';
import { INoticeItem } from 'network/src/main/ets/types/responseTypes/NoticeResp';
import { IUserAccount } from 'network/src/main/ets/types/responseTypes/GetUserAccountResp';

const TAG = '[MinePageVM]';

@ObservedV2
export class MinePageVM {
  private static _instance: MinePageVM;
  @Trace public userInfo: IUserInfo | undefined
  @Trace public userAccount: IUserAccount | undefined
  @Trace public positionList: IPositionItem[] = []
  @Trace public noticeList: INoticeItem[] = []
  @Trace public showMoney: boolean = false
  @Trace public openMock: boolean = true
  @Trace public isLogin: boolean = false
  @Trace public avatar: string = ''
  @Trace public nickname: string = ''

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  init() {
    const isLogin = AppStorage.get<boolean>('isLogin');
    if (isLogin) {
      this.isLogin = isLogin
      this.getUserInfo()
      this.getUserAccount(1)
      this.getPositionList(1, 1, 10)
    }
    this.getNoticeList()
  }

  reFresh() {
    this.isLogin = true
    this.getUserInfo()
    this.getUserAccount(1)
    this.getPositionList(1, 1, 10)
  }

  public async login() {
    const res = await https.userLogin();
    if (res.code === 0) {
      this.userInfo = res.data;
    }
  }

  logout() {
    this.isLogin = false
    this.userInfo = undefined
    this.userAccount = undefined
    this.positionList = []
    this.avatar = ''
    this.nickname = ''
  }

  public async getUserInfo() {
    const res = await https.getUserInfo();
    if (res.code === 0) {
      this.userInfo = res.data;
      this.avatar = this.userInfo.avatar
      this.nickname = this.userInfo.nickname
    }
  }

  public async getUserAccount(userId: number) {
    const res = await https.getUserAccount(userId);
    if (res.code === 0) {
      this.userAccount = res.data;
    }
  }

  public async getPositionList(userId: number, page: number, pageSize: number) {
    const res = await https.getPositionList(userId, page, pageSize);
    if (res.code === 0) {
      this.positionList = res.data;
    }
  }

  public async getNoticeList() {
    const res = await https.getNoticeList();
    if (res.code === 0) {
      this.noticeList = res.data;
    }
  }
}
