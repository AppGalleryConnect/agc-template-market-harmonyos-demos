@ObservedV2
export class SettingsPageVM {
  private static _instance: SettingsPageVM;

  public static get instance() {
    if (!SettingsPageVM._instance) {
      SettingsPageVM._instance = new SettingsPageVM();
    }
    return SettingsPageVM._instance;
  }
}