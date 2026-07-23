import { AccountUtil, UserInfoModel } from 'lib_foundation';
import { FormGroup, FormType, ObservedInfoItem } from 'collect_personal_info';

@ObservedV2
export class ProfileVM {
  @Trace userInfo: UserInfoModel = AccountUtil.getUserInfo();
  @Trace list: FormGroup[] = [];

  /**
   * 构建信息列表
   */
  public buildList(): void {
    this.list = [];
    const avatarItem = new ObservedInfoItem({
      type: FormType.CHOOSE_AVATAR,
      label: '头像',
      value: this.userInfo.avatar ? this.userInfo.avatar : $r('app.media.ic_user_default'),
      onChange: (param?: Object) => {
        this.userInfo.avatar = param as string;
        avatarItem.value = param as string;
      },
    });

    const nickNameItem = new ObservedInfoItem({
      type: FormType.TEXT_INPUT,
      label: '昵称',
      value: this.userInfo.nickname,
      minLength: 2,
      maxLength: 10,
      placeholderText: '昵称',
      validMessageText: '昵称不能为空',
      invocation: () => {
        return Promise.resolve();
      },
      onChange: (param?: Object) => {
        this.userInfo.nickname = param as string;
        nickNameItem.value = param as string;
      },
    });

    const phoneItem = new ObservedInfoItem({
      type: FormType.PHONE_INPUT,
      label: '手机号',
      value: this.userInfo.cellphone,
      maxLength: 11,
      validMessageText: '手机号码不能为空',
      phoneInfo: {
        codeLength: 6,
        sendCode: (_phone: string) => {
          return new Promise((resolve) => {
            setTimeout(() => {
              resolve()
            }, 300)
          })
        },
        verifyCode: (_phone: string, _code: string) => {
          return new Promise((resolve) => {
            setTimeout(() => {
              resolve(true)
            }, 300)
          })
        },
      },
      onChange: (param?: Object) => {
        this.userInfo.cellphone = param as string;
        phoneItem.value = param as string;
      },
    });

    this.list = [
      {
        list: [avatarItem],
      },
      {
        list: [
          nickNameItem,
          phoneItem,
        ],
      },
    ];
  }
}