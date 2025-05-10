import { ServerItem, SettingItem } from '../types/Index';
import { AccountUtil, RouterMap, UserInfo } from 'commonlib';

const TAG = '[MinePageVM]';

@ObservedV2
export class MinePageVM {
  @Trace serverList: ServerItem[] =
    [{ icon: $r('app.media.icon_my_recipe'), label: '我的菜谱', page: RouterMap.MY_RECIPE },
      { icon: $r('app.media.ic_public_star'), label: '我的收藏', page: RouterMap.MY_COLLECTION },
      { icon: $r('app.media.icon_record'), label: '浏览记录', page: RouterMap.BROWSING_HISTORY },
      { icon: $r('app.media.icon_setting'), label: '设置', page: RouterMap.SETTINGS_PAGE }];
  @Trace settingList: SettingItem[] =
    [{ label: '个人信息', page: RouterMap.PERSON_INFO_PAGE },
      { label: '隐私政策', page: RouterMap.TERMS_OF_SERVICE_PAGE },
      { label: '用户协议', page: RouterMap.PRIVACY_POLICY_PAGE },
      { label: '清除缓存', page: RouterMap.CACHE_PAGE }];
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  @Trace authCode: string = '';
  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  logout() {
    // 退出登录并清除登录信息
    this.userInfo.id = 0
    this.userInfo.avatar = ''
    this.userInfo.name = ''
    this.userInfo.nickname = ''
    this.userInfo.sex = ''
    this.userInfo.cellphone = ''
    this.userInfo.birthday = ''
    this.userInfo.code = ''
    this.userInfo.isLogin = false
  }
}
