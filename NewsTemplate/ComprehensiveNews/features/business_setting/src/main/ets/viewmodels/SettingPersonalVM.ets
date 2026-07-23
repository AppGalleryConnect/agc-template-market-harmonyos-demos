import { BaseViewModel, Logger, PhoneNumberUtils, RouterUtils } from 'lib_common';
import { MineServiceApi } from 'lib_news_api';

const TAG = '[SettingPersonalVM]';

@ObservedV2
export class SettingPersonalVM extends BaseViewModel {
  @Trace hasModify: boolean = false;

  modifyNickName(nickName: string) {
    this.userInfoModel.authorNickName = nickName;
    this.hasModify = true;
  }

  modifyContactPhone(contactPhone: string) {
    this.userInfoModel.authorPhone = PhoneNumberUtils.encryptPhone(contactPhone);
    this.hasModify = true;
  }

  modifyPersonalDesc(personalDesc: string) {
    this.userInfoModel.authorDesc = personalDesc;
    this.hasModify = true;
  }

  modifyUserIcon(uri: string) {
    if (!uri) {
      return;
    }
    Logger.info(TAG, 'user icon saved success, url:' + uri);
    MineServiceApi.modifyPersonalInfo({ authorIcon: uri });
    this.userInfoModel.authorIcon = uri;
    this.hasModify = true;
  }

  customBack() {
    RouterUtils.pop(this.hasModify ? 'modify-flag' : undefined);
  }
}