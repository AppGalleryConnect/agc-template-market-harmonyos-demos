import { CommonConstants } from 'lib_common';
import { NavHeaderBar } from 'lib_widget';
import { MineServiceApi } from 'lib_news_api';
import { FormGroup, FormType, ObservedInfoItem, PersonalInfoView } from 'module_personal_info';
import { SettingPersonalVM } from '../viewmodels/SettingPersonalVM';

@Builder
export function SettingPersonalBuilder() {
  SettingPersonal()
}

@ComponentV2
struct SettingPersonal {
  @Local vm: SettingPersonalVM = new SettingPersonalVM();

  build() {
    NavDestination() {
      NavHeaderBar({
        title: '个人信息',
        onBack: () => {
          this.vm.customBack();
        },
      })
      Column() {
        PersonalInfoView({
          list: this.list,
          themeColor: $r('app.color.app_theme'),
          fontSizeRatio: this.vm.settingInfo.fontSizeRatio,
        })
      }
      .layoutWeight(1)
      .padding({
        top: CommonConstants.PADDING_M,
        left: this.vm.breakPointModel.pagePadding,
        right: this.vm.breakPointModel.pagePadding,
        bottom: this.vm.windowModel.windowBottomPadding,
      })
    }
    .hideTitleBar(true)
    .backgroundColor($r('sys.color.background_secondary'))
    .onBackPressed(() => {
      this.vm.customBack();
      return true;
    })
  }

  @Local avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.vm.userInfoModel.authorIcon ? this.vm.userInfoModel.authorIcon :
      $r('app.media.ic_user_default'),
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.vm.modifyUserIcon(param as string);
    },
  });
  @Local nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.vm.userInfoModel.authorNickName,
    minLength: 2,
    maxLength: 20,
    placeholderText: '昵称',
    invocation: (param: Object) => {
      return MineServiceApi.modifyPersonalInfo({ authorNickName: param as string })
    },
    onChange: (param?: Object) => {
      this.nickNameItem.value = param as string;
      this.vm.modifyNickName(param as string);
    },
  })
  @Local phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号',
    value: this.vm.userInfoModel.authorPhone,
    phoneInfo: {
      codeLength: 6,
      sendCode: (phone: string) => {
        return MineServiceApi.sendCode(phone);
      },
      verifyCode: (phone: string, code: string) => {
        return MineServiceApi.modifyPersonalInfo({ authorPhone: phone, verifyCode: code });
      },
    },
    onChange: (param?: Object) => {
      this.phoneItem.value = param as string;
      this.vm.modifyContactPhone(param as string);
    },
  })
  @Local introItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXTAREA,
    maxLength: 70,
    label: '个人简介',
    value: this.vm.userInfoModel.authorDesc,
    placeholderText: '简单介绍一下自己吧~~',
    showValue: false,
    invocation: (param: Object) => {
      return MineServiceApi.modifyPersonalInfo({ authorDesc: param as string });
    },
    onChange: (param?: Object) => {
      this.introItem.value = param as string;
      this.vm.modifyPersonalDesc(param as string);
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
    {
      list: [
        this.introItem,
      ],
    },
  ];
}