import { FormGroup, FormType, ObservedInfoItem, PersonalInfoView } from 'collect_personal_info';
import { UserServiceApi } from 'module_base';
import { MineVM } from '../viewmodel/MineVM';

@Builder
export function ProfilePageBuilder() {
  ProfilePage();
}

@ComponentV2
export struct ProfilePage {
  vm: MineVM = MineVM.instance;
  @Local avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.vm.userInfoModel.userIcon,
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.vm.userInfoModel.userIcon = param as string
      this.vm.updateUserInfo({ userIcon: param as string });
    },
  });
  @Local nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.vm.userInfoModel.userNickName,
    minLength: 2,
    maxLength: 10,
    placeholderText: '请输入昵称',
    invocation: (param: Object) => {
      return UserServiceApi.modifyPersonalInfo({ userNickName: param as string })
    },
    validMessageText: '内容为空，请输入后保存',
    onChange: (param?: Object) => {
      this.nickNameItem.value = param as string;
      this.vm.userInfoModel.userNickName = param as string;
    },
  });
  @Local phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号码',
    value: `${this.vm.userInfoModel.userPhone}`,
    phoneInfo: {
      codeLength: 6,
      sendCode: (phone: string) => {
        return UserServiceApi.sendCode(phone)
      },
      verifyCode: (phone: string, code: string) => {
        return UserServiceApi.modifyPersonalInfo({ userPhone: phone, verifyCode: code });
      },
    },
    onChange: (param?: Object) => {
      this.phoneItem.value = param as string;
      this.vm.userInfoModel.userPhone = param as string;
      UserServiceApi.modifyPersonalInfo({ userPhone: param as string })
    },
  });
  @Local list: FormGroup[] = [
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

  build() {
    NavDestination() {
      Column() {
        PersonalInfoView({
          list: this.list,
          themeColor: $r('sys.color.icon_emphasize'),
        });
      }
      .width('100%')
      .height('100%')
      .padding(16);
    }
    .title('个人信息')
    .backgroundColor($r('sys.color.background_secondary'));
  }
}