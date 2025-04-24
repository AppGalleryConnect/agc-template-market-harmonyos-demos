// PreferencesManager.ets（数据存储）
import preferences from '@ohos.data.preferences';


export class DataManager {
  static login() {
    const dataPreferences = DataManager.getPreferences();
    dataPreferences.putSync(DataManager.getBoundFlagKey(), 'LoggedIn');
    dataPreferences.flush();
  }

  static logout() {
    const dataPreferences = DataManager.getPreferences();
    dataPreferences.deleteSync(DataManager.getBoundFlagKey());
    dataPreferences.flush();
  }

  static isLoggedIn(): boolean {
    const dataPreferences = DataManager.getPreferences();
    return dataPreferences.hasSync(DataManager.getBoundFlagKey());
  }

  static getPreferences() {
    return preferences.getPreferencesSync(getContext(), { 'name': 'account' })
  }

  static getBoundFlagKey(): string {
    return 'login_status';
  }
}