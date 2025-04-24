import { AccountUtil, RouterMap, RouterModule, UserInfo } from 'commonlib';
import { MinePageSetting, SettingItem, SettingType } from '../types';
import { MINE_PAGE_SETTING } from '../constants';

@ObservedV2
export class MinePageVM {
  @Trace userInfo: UserInfo = AccountUtil.getUserInfo();
  minePageSetting: MinePageSetting = MINE_PAGE_SETTING;
  private static _instance: MinePageVM;

  public static get instance() {
    if (!MinePageVM._instance) {
      MinePageVM._instance = new MinePageVM();
    }
    return MinePageVM._instance;
  }

  public getSettingGroupList() {
    const itemList = this.minePageSetting.settingList;
    let list: SettingItem[][] = [];
    let group: SettingItem[] = [];
    let curGroupNum = 1;
    for (let i = 0; i < itemList.length; i++) {
      if (itemList[i].group === curGroupNum) {
        group.push(itemList[i]);
      } else {
        list.push(group);
        group = [];
        curGroupNum++;
        group.push(itemList[i]);
      }
    }
    list.push(group);
    return list;
  }

  public jumpToNext(item: SettingItem) {
    switch (item.type) {
      case SettingType.MY_ORDERS:
        RouterModule.push({
          url: RouterMap.ORDER_LIST,
        });
        break;
      case SettingType.INFO:
        RouterModule.push({
          url: RouterMap.MINE_PRIVACY_POLICY,
        });
        break;
      case SettingType.ACCOUNT:
        RouterModule.push({
          url: RouterMap.MINE_PROFILE_EDIT,
        });
        break;
      default:
        break;
    }
  }
}
