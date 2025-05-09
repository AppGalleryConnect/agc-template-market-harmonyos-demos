import {
  AccountUtil,
  CloudStorageUtil,
  FormatUtil,
  FullLoading,
  Logger,
  RouterModule,
  UserInfo,
  UserInfoModel,
} from 'commonlib';
import { BusinessError } from '@kit.BasicServicesKit';
import { functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { promptAction } from '@kit.ArkUI';
import fs from '@ohos.file.fs';
import { util } from '@kit.ArkTS';
import { https } from 'network';

const TAG = '[UserInfoEditVM]';

@ObservedV2
export class UserInfoEditVM {
  private static _instance: UserInfoEditVM;
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace editInfo: UserInfoModel = new UserInfoModel();
  @Trace avatarUri: string = '';
  @Trace isLoading: boolean = false;

  public static get instance() {
    if (!UserInfoEditVM._instance) {
      UserInfoEditVM._instance = new UserInfoEditVM();
    }
    return UserInfoEditVM._instance;
  }

  public initData() {
    this.editInfo.avatar = this.userInfo.avatar;
    this.editInfo.nickname = this.userInfo.nickname;
    this.editInfo.phone = this.userInfo.phone;
    this.editInfo.wechat = this.userInfo.wechat;
    this.editInfo.birthday = this.userInfo.birthday;
  }

  public getAvatarSrc(error: BusinessError, data: functionalButtonComponentManager.ChooseAvatarResult) {
    if (error) {
      promptAction.showToast({ message: '获取头像失败，请稍后重试' });
      return;
    }
    let avatarFile: fs.File | null = null;
    try {
      avatarFile = fs.openSync(data.avatarUri!, fs.OpenMode.READ_ONLY);
      let newPath = getContext().cacheDir + `/${util.generateRandomUUID(false)}.png`;
      fs.copyFileSync(avatarFile.fd, newPath);
      this.editInfo.avatar = 'file://' + newPath;
    } catch (err) {
      Logger.error(TAG, 'get photo error:' + err);
    } finally {
      if (avatarFile) {
        try {
          fs.closeSync(avatarFile);
          this.avatarUri = data.avatarUri!;
        } catch (err) {
          Logger.error(TAG, 'close file failed,error:' + JSON.stringify(err));
        }
      }
    }
  }

  public handleBirthdayChange(value: Date) {
    let month: string = (value.getMonth() + 1).toString();
    if (month.length === 1) {
      month = '0' + month;
    }
    let day: string = value.getDate().toString();
    if (day.length === 1) {
      day = '0' + day;
    }
    this.editInfo.birthday = value.getFullYear() + '-' + month + '-' + day;
  }

  public getPhoneNumber(): string {
    return FormatUtil.formatSecretPhone(this.editInfo.phone);
  }

  public updateUserInfo() {
    const uploadData: UserInfo = {
      avatar: this.editInfo.avatar,
      nickname: this.editInfo.nickname,
      phone: this.editInfo.phone,
      studentID: this.editInfo.studentID,
      wechat: this.editInfo.wechat,
      birthday: this.editInfo.birthday,
    };
    this.isLoading = true;
    FullLoading.show('保存中...');
    if (this.editInfo.avatar && this.editInfo.avatar !== this.userInfo.avatar) {
      CloudStorageUtil.upload(this.avatarUri, (url: string) => {
        if (url) {
          uploadData.avatar = url;
          this.submitUserInfo(uploadData);
        } else {
          promptAction.showToast({ message: '用户信息修改失败，请稍后重试~' });
        }
        this._deleteCacheAvatarFile(this.editInfo.avatar);
      });
    } else {
      this.submitUserInfo(uploadData);
    }
  }

  public async submitUserInfo(data: UserInfo) {
    const res = await https.updateUserInfo(data);
    if (res.ret.code === 0) {
      AccountUtil.setUserInfo(res.result);
      promptAction.showToast({ message: '用户信息修改成功！' });
      RouterModule.pop();
    } else {
      promptAction.showToast({ message: '用户信息修改失败，请稍后重试~' });
    }
    this.isLoading = false;
    FullLoading.hide();
  }

  private _deleteCacheAvatarFile(avatarPath: string) {
    const tempArr = avatarPath.split('file://');
    if (tempArr.length === 2) {
      const uri = tempArr[1];
      try {
        fs.unlinkSync(uri);
      } catch (err) {
        Logger.error(TAG, 'delete cache avatar file failed. err:' + JSON.stringify(err));
      }
    }
  }
}
