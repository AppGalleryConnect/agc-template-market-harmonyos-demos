import { preferences } from '@kit.ArkData';
import { ContactSearchModel } from '../viewmodel/ContactSearchModel';

export class SearchModelManager {
  /**
   * 设置搜索模式 入参是0 则为默认本地mock数据搜索；若是大于0的任何值 则执行云端搜索 需自行开通腾讯imsdk的云端搜索功能
   * @param value
   */
  public static setSearchModel(value: number) {
    preferences.getPreferencesSync(getContext(), { name: 'SearchRealData' }).putSync('SearchRealData', value);
    preferences.getPreferencesSync(getContext(), { name: 'SearchRealData' }).flushSync();
  }

  /**
   * 获取搜索模式
   * @param value
   */
  public static getSearchModel(): number {
    let model = preferences.getPreferencesSync(getContext(), { name: 'SearchRealData' }).getSync('SearchRealData', 0);
    return model === undefined ? 0 : model as number;
  }

  public static parseContactSearchModel(userId: string, nickName: string, avatarUrl: string): ContactSearchModel {
    let contact = new ContactSearchModel(userId, nickName, avatarUrl);
    return contact
  }
}