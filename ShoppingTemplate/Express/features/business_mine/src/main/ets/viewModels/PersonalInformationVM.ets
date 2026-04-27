import { FormGroup, FormType, ObservedInfoItem } from 'collect_personal_info';
import { BaseViewModel, CommonUtil, HttpApi, User } from 'lib_foundation';


@ObservedV2
export class PersonalInformationVM extends BaseViewModel {
  @Trace avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfoModel.avatar ? this.userInfoModel.avatar : $r('app.media.ic_default_avatar'),
    onChange: (param?: Object) => {
      const avatarUri = param as string;
      this.avatarItem.value = avatarUri;
      this.userInfoModel.avatar = avatarUri;
      // 更新用户头像
      const data = {
        userId: this.userInfoModel.id,
        avatar: avatarUri,
      } as User;
      HttpApi.updateUserInfo(data);
    },
  });
  @Trace nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.userInfoModel.nickname,
    minLength: 2,
    maxLength: 20,
    placeholderText: '昵称',
    invocation: (param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '昵称不能为空',
    onChange: (param?: Object) => {
      const nickName = param as string;
      this.nickNameItem.value = nickName;
      this.userInfoModel.nickname = nickName;
      // 更新用户昵称
      const data = {
        userId: this.userInfoModel.id,
        nickname: nickName,
      } as User;
      HttpApi.updateUserInfo(data);
    },
  })
  @Trace genderItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DROP_SELECT,
    label: '性别',
    selectOptions: [
      {
        id: 0,
        value: 0,
        label: '男',
      },
      {
        id: 1,
        value: 1,
        label: '女',
      },
      {
        id: 2,
        value: 2,
        label: '保密',
      },
    ],
    value: this.userInfoModel.gender,
    onChange: (param?: Object) => {
      const gender = param as number;
      this.genderItem.value = param as number;
      this.userInfoModel.gender = gender;
      // 更新用户性别
      const data = {
        userId: this.userInfoModel.id,
        gender: gender,
      } as User;
      HttpApi.updateUserInfo(data);
    },
  });
  @Trace fullNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '姓名',
    minLength: 2,
    maxLength: 10,
    placeholderText: '姓名',
    validMessageText: '姓名不能为空',
    value: this.userInfoModel.name,
    onChange: (param?: Object) => {
      const fullName = param as string;
      this.fullNameItem.value = fullName;
      this.userInfoModel.name = fullName;
      // 更新用户姓名
      const data = {
        userId: this.userInfoModel.id,
        realName: fullName,
      } as User;
      HttpApi.updateUserInfo(data);
    },
  })
  @Trace birthItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DATE_SELECT,
    label: '出生日期',
    sheetTitle: '出生日期',
    sheetOptions: {
      height: 500,
    },
    value: this.userInfoModel.birthday ? new Date(this.userInfoModel.birthday) : undefined,
    onChange: (param?: Object) => {
      this.birthItem.value = param as Date;
      const birthday = CommonUtil.formatDate(param as Date)
      this.userInfoModel.birthday = birthday;
      // 更新用户出生日期
      const data = {
        userId: this.userInfoModel.id,
        birthday: birthday,
      } as User;
      HttpApi.updateUserInfo(data);
    },
  });
  @Trace phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号码',
    maxLength: 11,
    validMessageText: '手机号码不能为空',
    value: this.userInfoModel.phone,
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
    onChange: (param?: Object) => {
      const phone = param as string;
      this.phoneItem.value = phone;
      this.userInfoModel.phone = phone;
      // 更新用户手机号
      const data = {
        userId: this.userInfoModel.id,
        phone: phone,
      } as User;
      HttpApi.updateUserInfo(data);
    },
  })
  @Trace list: FormGroup[] = [
    {
      list: [this.avatarItem],
    },
    {
      list: [
        this.nickNameItem,
        this.genderItem,
        this.birthItem,
      ],
    },
    {
      list: [
        this.fullNameItem,
        this.phoneItem,
      ],
    },
  ];
}
