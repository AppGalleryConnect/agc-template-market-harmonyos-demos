import { ObservedInfoItem, FormGroup, FormType } from 'collect_personal_info';
import { iData, UserInfoModel } from 'lib_foundation';
import { UserApis } from 'lib_network';

enum UserInfoType {
  AVATAR = 'avatar',
  NICKNAME = 'nickname',
  PHONE = 'phone'
}

@ObservedV2
export class EditProfileVM {
  @Trace
  avatar: ResourceStr = '';
  @Trace
  tempNickname: string = '';
  @Trace
  nickname: string = '';
  @Trace
  userInfo: UserInfoModel = iData.global.userInfo;
  @Trace avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfo.avatar ? this.userInfo.avatar : $r('app.media.default_avatar'),
    onChange: async (param?: Object) => {
      const res = await UserApis.updateUserInfo({
        type: UserInfoType.AVATAR,
        value: param as string,
      });
      if (res.code === 0) {
        this.avatarItem.value = param as string;
      }
    },
  });
  @Trace nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.userInfo.nickname,
    minLength: 2,
    maxLength: 10,
    placeholderText: '请输入昵称',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '内容为空，请输入后保存',
    onChange: async (param?: Object) => {
      const res = await UserApis.updateUserInfo({
        type: UserInfoType.NICKNAME,
        value: param as string,
      });
      if (res.code === 0) {
        this.nickNameItem.value = param as string;
      }
    },
  });
  @Trace phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号码',
    value: this.userInfo.anonymousPhone,
    phoneInfo: {
      codeLength: 6,
      sendCode: (_phone: string) => {
        return new Promise((resolve) => {
          setTimeout(() => {
            resolve();
          }, 1000);
        });
      },
      verifyCode: (_phone: string, _code: string) => {
        return new Promise((resolve) => {
          setTimeout(() => {
            resolve(true);
          }, 1000);
        });
      },
    },
    onChange: async (param?: Object) => {
      const res = await UserApis.updateUserInfo({
        type: UserInfoType.PHONE,
        value: param as string,
      });
      if (res.code === 0) {
        this.phoneItem.value = param as string;
      }
    },
  });
  @Trace list: FormGroup[] = [
    {
      list: [this.avatarItem],
    },
    {
      list: [
        this.nickNameItem,
        this.phoneItem,
      ],
    },
  ];
}
