import { PersistenceV2 } from '@kit.ArkUI';
import { emitter } from '@kit.BasicServicesKit';
import { FormGroup, FormType, ObservedInfoItem, PersonalInfoView } from 'collect_personal_info'
import { CommonHeader, Constants, TimeUtil, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { GenderStringToType, GenderTypeToString } from '../utils/TypeConversion';

/**
 * @usage: 个人信息编辑页面，提供用户基本信息的编辑功能。包含头像选择、昵称修改、性别选择、生日设置、身高体重输入等功能。
 * 主要数据结构包括UserInfo（用户信息）、ObservedInfoItem（表单项模型）。包含表单验证逻辑和数据保存功能。
 * @layout: 页面采用垂直布局（Column），顶部为CommonHeader导航栏，下方为表单编辑区域。
 * 表单使用PersonalInfoView组件展示，包含多个FormGroup表单组。
 * @constraints:
 * @domain: 健康医疗
 * @isGen: true
 * @fileType: page
 * @zhName: 个人信息编辑页面
 * @component: CommonHeader,PersonalInfoView,FormGroup,OHPage
 * @image: screenshot/person/EditPersonalCenter.jpg
 */

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

@ComponentV2
export struct EditPersonalCenter {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfo.avatarUrl || $r('app.string.person_info_avatar_default_url'),
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.userInfo.avatarUrl = param as ResourceStr;
    },
  });
  @Local nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    value: this.userInfo.nickName,
    minLength: 2,
    maxLength: 10,
    placeholderText: '昵称',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: $r('app.string.person_info_content_empty_tip'),
    onChange: (param?: Object) => {
      this.nickNameItem.value = param as string;
      this.userInfo.nickName = param as string
    },
  })
  @Local genderItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DROP_SELECT,
    label: '性别',
    selectOptions: [
      {
        id: 0,
        value: 0,
        label: $r('app.string.person_info_sex_man'),
      },
      {
        id: 1,
        value: 1,
        label: $r('app.string.person_info_sex_woman'),
      },
      {
        id: 2,
        value: 2,
        label: $r('app.string.person_info_sex_confidentiality'),
      },
    ],
    value: GenderStringToType(this.userInfo.gender),
    onChange: (param?: Object) => {
      this.genderItem.value = param as number;
      this.userInfo.gender = GenderTypeToString(param as number)
    },
  });
  @Local heightItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '身高',
    value: this.userInfo.height > 0 ? this.userInfo.height.toString() : '',
    unit: '厘米',
    minLength: 1,
    maxLength: 5,
    placeholderText: '身高',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: $r('app.string.person_info_content_empty_tip'),
    onChange: (param?: Object) => {
      try {
        const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(param as string);
        if (isValidInput) {
          this.heightItem.value = param as string;
          this.userInfo.height = Number(param);
          emitter.emit(Constants.onHealthDataChange);
        } else {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.person_info_input_error_tip'),
          });
        }
      } catch (err) {
      }
    },
  })
  @Local weightItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '体重',
    value: this.userInfo.weight > 0 ? this.userInfo.weight.toString() : '',
    unit: '公斤',
    minLength: 1,
    maxLength: 5,
    placeholderText: '体重',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: $r('app.string.person_info_content_empty_tip'),
    onChange: (param?: Object) => {
      try {
        const isValidInput = /^(\d+|\d+\.\d*|\.\d+|\d*\.?)$/.test(param as string);
        if (isValidInput) {
          let tempValue = Number(param);
          let tempInteger = Math.floor(tempValue);
          let tempPoint = Math.floor(tempValue * 10) - tempInteger * 10;
          if (tempPoint === 0) {
            this.weightItem.value = tempValue.toString() + '.0';
          } else if (tempPoint > 5) {
            tempValue = tempInteger + 1;
            this.weightItem.value = tempValue.toString() + '.0';
          } else  {
            tempValue = tempInteger + 0.5;
            this.weightItem.value = tempValue.toString();
          }

          this.userInfo.weight = tempValue;
          emitter.emit(Constants.onHealthDataChange);
        } else {
          this.getUIContext().getPromptAction().showToast({
            message: $r('app.string.person_info_input_error_tip'),
          });
        }
      } catch (err) {
      }
    },
  })
  @Local birthItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DATE_SELECT,
    label: '出生年月',
    sheetTitle: '出生年月',
    value: this.userInfo.birthday,
    sheetOptions: {
      height: 500,
    },
    onChange: (param?: Object) => {
      this.birthItem.value = param as Date;
      this.userInfo.birthday = TimeUtil.formatToDateString(param as string)
    },
  });
  @Local phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号码',
    value: this.userInfo.telephone || $r('app.string.person_info_default_phone'),
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
  @Local emailItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '邮箱',
    value: this.userInfo.email,
    minLength: 5,
    maxLength: 30,
    placeholderText: '',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: $r('app.string.person_info_content_empty_tip'),
    onChange: (param?: Object) => {
      this.userInfo.email = param as string
    },
  })
  @Local introItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXTAREA,
    maxLength: 50,
    label: '个人简介',
    placeholderText: '简单介绍一下自己吧~~',
    value: this.userInfo.introDesc || $r('app.string.person_info_personal_profile_placeholder'),
    showValue: true,
    onChange: (param?: Object) => {
      this.introItem.value = param as string;
      this.userInfo.introDesc = param as string;
    },
  });
  @Local list: FormGroup[] = [
    {
      list: [
        this.avatarItem,
        this.nickNameItem
      ]
    },
    {
      list: [
        this.genderItem,
        this.heightItem,
        this.weightItem,
        this.birthItem,
      ]
    },
    {
      list: [
        this.phoneItem,
        this.emailItem,
        this.introItem
      ]
    }
  ];
  @Local onReturnClick: () => void = () => {
    phoneRouterControl.popPage();
  }

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      useSafePadding: true
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    CommonHeader({
      title: $r('app.string.person_owner_title'),
      onReturnClick: () => {
        phoneRouterControl.popPage();
      },
      leftImageRes: $r('app.media.ic_backward2')
    })

    Column() {
      PersonalInfoView({
        list: this.list,
        themeColor: $r('sys.color.multi_color_07'),
      })
        .layoutWeight(1)
        .width('100%')

      Blank().height($r('app.float.vp_36'))
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

