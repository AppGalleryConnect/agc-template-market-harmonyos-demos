import { AppStorageV2 } from '@kit.ArkUI';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { PersonalInfo } from 'type';
import Logger from './Logger';

const TAG = 'ACCOUNT';

@ObservedV2
export class UserInfo {
  @Trace avatar?: ResourceStr;
  @Trace phone?: string;
  @Trace nickName?: string
  @Trace address?: functionalButtonComponentManager.ChooseAddressResult;
}

@ObservedV2
export class HUAWEIAccountModel {
  @Trace idToken?: string = '';
  @Trace openID?: string = '';
  @Trace unionID?: string = '';
  @Trace signOpenID?: string = '';
  @Trace authCode?: string = '';
  @Trace loginToken?: string = '';
}

@ObservedV2
export class AccountUtil {
  private static _personalInfo: PersonalInfo = AppStorageV2.connect(PersonalInfo, 'PersonalInfo', () => new PersonalInfo())!;

  public static getNickName() {
    return AccountUtil._personalInfo.nickName;
  }

  public static getAvatar() {
    return AccountUtil._personalInfo.avatar;
  }

  public static getUserId() {
    return AccountUtil._personalInfo.uid;
  }

  public static setUserId(uid: string) {
    AccountUtil._personalInfo.uid = uid;
  }

  public static setAvatar(avatar: ResourceStr) {
    AccountUtil._personalInfo.avatar = avatar;
  }

  public static setNickName(nickName: string) {
    AccountUtil._personalInfo.nickName = nickName;
  }

  public static getPersonalInfo() {
    return AccountUtil._personalInfo
  }

  public static setPersonalInfo(personalInfo: PersonalInfo) {
    AccountUtil._personalInfo = personalInfo
  }
}