@ObservedV2
export class BulletSettingItem {
  @Trace rowsNum: number = 2;
  @Trace notOpacity: number = 80;
  @Trace danMuSpeed: string = '适中';
  @Trace danMuSize: string = '适中';
}

@ObservedV2
export class BulletSettingStorage {
  static singleton: BulletSettingStorage;
  static instance() {
    if(!BulletSettingStorage.singleton) {
      BulletSettingStorage.singleton = new BulletSettingStorage();
    };
    return BulletSettingStorage.singleton;
  }
  @Trace setting: Map<string,BulletSettingItem> = new Map();
}