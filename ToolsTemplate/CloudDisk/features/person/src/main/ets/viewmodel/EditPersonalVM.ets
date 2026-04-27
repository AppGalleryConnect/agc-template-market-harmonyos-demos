import { FormGroup, FormType, ObservedInfoItem } from 'collect_personal_info'
import { TimeUtil, UserInfo } from 'common';
import { PersistenceV2 } from '@kit.ArkUI';
import { GenderStringToType, GenderTypeToString } from '../utils/TypeConversion';

@ObservedV2
export class EditPersonalVM {
  @Trace userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Trace avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfo.avatarUrl || $r('app.media.avatar_avatar_12'),
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.userInfo.avatarUrl = param as ResourceStr;
    },
  });
  @Trace nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.userInfo.nickName === '' ? this.userInfo.nickName = '华为用户' : this.userInfo.nickName,
    minLength: 2,
    maxLength: 10,
    placeholderText: '昵称',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '内容为空，请输入后保存',
    onChange: (param?: Object) => {
      this.nickNameItem.value = param as string;
      this.userInfo.nickName = param as string
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
    value: GenderStringToType(this.userInfo.gender),
    onChange: (param?: Object) => {
      this.genderItem.value = param as number;
      this.userInfo.gender = GenderTypeToString(param as number)
    },
  });
  @Trace birthItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DATE_SELECT,
    label: '出生日期',
    value: this.userInfo.birthday,
    sheetOptions: {
      height: 500,
    },
    onChange: (param?: Object) => {
      this.birthItem.value = param as Date;
      this.userInfo.birthday = TimeUtil.formatToDateString(param as string)
    },
  });
  @Trace phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号码',
    value: this.userInfo.telephone || '100**2222',
    phoneInfo: {
      codeLength: 6,
      sendCode: (_phone: string) => {
        return new Promise((resolve, _reject) => {
          setTimeout(() => {
            resolve()
          }, 1000)
        })
      },
      verifyCode: (_phone: string, _code: string) => {
        return new Promise((resolve, _reject) => {
          setTimeout(() => {
            resolve()
          }, 1000)
        })
      },
    },
    onChange: (param?: Object) => {
      this.phoneItem.value = param as string;
      this.userInfo.telephone = param as string
    },
  })
  @Trace emailItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '邮箱',
    value: this.userInfo.email,
    minLength: 5,
    maxLength: 30,
    placeholderText: '',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '内容为空，请输入后保存',
    onChange: (param?: Object) => {
      this.userInfo.email = param as string
    },
  })
  @Trace introItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXTAREA,
    maxLength: 50,
    label: '个人简介',
    placeholderText: '简单介绍一下自己吧~~',
    value: this.userInfo.introDesc || '简单介绍一下自己吧~~',
    showValue: true,
    onChange: (param?: Object) => {
      this.introItem.value = param as string;
      this.userInfo.introDesc = param as string;
    },
  });
  @Trace list: FormGroup[] = [
    {
      list: [
        this.avatarItem,
        this.nickNameItem,
      ],

    }, {
    list: [
      this.emailItem,
    ]
  }, {
    list: [
      this.genderItem,
      this.birthItem,
    ],
  },
    {
      list: [
        this.phoneItem,
      ]
    }, {
    list: [
      this.introItem
    ]
  }
  ];
}