import { TabListItem } from '../types';
import { homePageBuilder } from 'home';
import { minePageBuilder } from 'mine';
import { vipPageBuilder } from 'vip';
import { AccountUtil, HUAWEIAccountModel, RouterModule, UserInfo, UserInfoModel } from 'commonlib';
import { GetHotelUserInfoResp, HotelUserLoginResp, https } from 'network';

const TAG: string = 'MainEntryVM';

@ObservedV2
export class MainEntryVM {
  // 路由栈实例
  @Trace navStack: NavPathStack = RouterModule.stack;
  // 底部tab页签列表
  public tabList: TabListItem[] = [
    {
      label: '首页',
      icon: $r('app.media.ic_home'),
      iconChecked: $r('app.media.ic_home_checked'),
      component: wrapBuilder(homePageBuilder),
    },
    {
      label: '会员',
      icon: $r('app.media.ic_vip'),
      iconChecked: $r('app.media.ic_vip_checked'),
      component: wrapBuilder(vipPageBuilder),
    },
    {
      label: '我的',
      icon: $r('app.media.ic_mine'),
      iconChecked: $r('app.media.ic_mine_checked'),
      component: wrapBuilder(minePageBuilder),
    },
  ];
  // 当前页签
  @Trace curIndex: number = 0;
  // 避让区
  @Trace accountInfo: HUAWEIAccountModel = AccountUtil.getAccountInfo();
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  private static _instance: MainEntryVM;

  public static get instance() {
    if (!MainEntryVM._instance) {
      MainEntryVM._instance = new MainEntryVM();
    }
    return MainEntryVM._instance;
  }

  // 初始化
  public async init() {
    if (this.accountInfo) {
      this.getLoginUserInfo();
    }
  }

  public async getLoginUserInfo() {
    const loginToken = this.accountInfo.loginToken;
    if (!loginToken) {
      const res = await https.hotelUserLogin();
      if (res.code === 0) {
        this.accountInfo.loginToken = res.data.loginToken;
        this.updateUserInfo(res.data);
      }
    } else {
      const res = await https.getHotelUserInfo();
      if (res.code === 0) {
        this.updateUserInfo(res.data);
      }
    }
  }

  public updateUserInfo(data: HotelUserLoginResp | GetHotelUserInfoResp) {
    const info: UserInfo = {
      avatar: data.avatar ? data.avatar : '',
      name: data.name,
      nickname: data.nickname,
      sex: data.sex,
      cellphone: data.cellphone,
      birthday: data.birthday,
      id: data.id,
      memberInfo: data.memberMsg,
    };
    AccountUtil.updateUserInfo(info);
  }
}
