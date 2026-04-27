import { BaseViewModel, BreakpointType, RouterMap, RouterUtils } from 'lib_common';
import { ApiController, UserInfo } from 'atomicservice_login'
import { SettingItemModel } from '../components/SettingItem';

@ObservedV2
export class MinePageVM extends BaseViewModel {
  @Trace userInfo: UserInfo = new UserInfo()
  public controller: ApiController = new ApiController()
  public unBindPhone = async (): Promise<void> => {
    this.userInfoModel.isLink = false;
    this.userInfo = new UserInfo()
  }
  public settingList: SettingItemModel[] = [
    {
      icon: $r('sys.symbol.heart'),
      label: '我的点赞',
      clickEvent: () => RouterUtils.pushPathByName(RouterMap.MINE_LIKE_PAGE),
    },
    {
      icon: $r('sys.symbol.doc_plaintext_and_pencil'),
      label: '意见反馈',
      clickEvent: () => RouterUtils.pushPathByName(RouterMap.FEEDBACK_SUBMIT_PAGE),
    },
  ];
  public lanesMap: BreakpointType<number> = new BreakpointType<number>({
    sm: 1,
    md: 1,
    lg: 2,
    xl: 2,
  });

  queryUserInfo() {
    this.userInfo.phoneNumber = this.userInfoModel.authorPhone;
    this.userInfo.userName = this.userInfoModel.authorNickName;
    this.userInfo.avatar = this.userInfoModel.authorIcon;
  }

  setUserInfoModel() {
    this.userInfoModel.authorPhone = this.userInfo.phoneNumber ?? '';
    this.userInfoModel.authorNickName = this.userInfo.userName ?? '';
    this.userInfoModel.authorIcon = this.userInfo.avatar || $r('app.media.avatar_grey');
  }

  public bindPhone() {
    this.contextModel.showToast({ message: '请通过临时登录凭证获取真实手机号' });
    this.userInfoModel.isLink = false;
    this.userInfo.phoneNumber = '';
    this.userInfo.userName = '华为用户';
    this.userInfo.avatar = $r('app.media.avatar_grey');
    this.setUserInfoModel();
  }

  public onGetPhoneError(err: BusinessError) {
    if (err.code === 1001502014) {
      this.contextModel.showToast({ message: '元服务未获取phone权限或用户授权，此为模拟关联。' });
      this.userInfoModel.isLink = true;
      this.userInfo.phoneNumber = '120****4456';
      this.userInfo.userName = '华为用户';
      this.userInfo.avatar = $r('app.media.avatar_grey');
      this.setUserInfoModel();
    }
  }
}