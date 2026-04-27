import { FormGroup, FormType, ObservedInfoItem, PersonalInfoView } from 'collect_personal_info'
import { CommonHeader, TimeUtil, UserInfo } from 'common';
import { OHPage, phoneRouterControl } from 'oh_router'
import { GenderStringToType, GenderTypeToString } from '../utils/TypeConversion';
import { EditPersonalVM } from '../viewmodel/EditPersonalVM';
import { PersistenceV2 } from '@kit.ArkUI';

@Builder
export function EditPersonalCenterBuilder() {
  EditPersonalCenter();
}

/**
 * @usage: 用于展示个人信息编辑页面。提供用户个人信息的编辑功能，包括头像、姓名、性别、出生日期、手机号码、邮箱、个人简介等字段的修改。
 * 关键数据结构包括UserInfo（用户信息模型，支持PersistenceV2持久化）、ObservedInfoItem（表单项模型，包含type、label、value、
 * onChange等字段）、FormType（表单类型枚举，包含CHOOSE_AVATAR、TEXT_INPUT、DROP_SELECT、DATE_SELECT、PHONE_INPUT、TEXTAREA）、
 * FormGroup（表单分组模型，包含list数组）。包含if逻辑：根据FormType类型渲染不同的表单控件。
 * @layout: 页面采用Column垂直布局。顶部是CommonHeader导航栏（标题"个人信息"和返回按钮），
 * 主体是PersonalInfoView组件（包含3个FormGroup分组：第一组为头像选择avatarItem，第二组为姓名nickNameItem、性别genderItem、
 * 出生日期birthItem，第三组为手机号码phoneItem、邮箱emailItem、个人简介introItem）。每个表单项垂直排列，左对齐。
 * @constraints: UserInfo使用PersistenceV2持久化存储不可修改；头像选择器的图片资源固定；
 * 姓名长度限制2-10字符、邮箱长度限制5-30字符、个人简介长度限制50字符不可修改；性别选项固定为男、女、保密三个选项；
 * 手机号码验证码长度固定为6位；表单项的onChange回调会同步更新UserInfo对应字段。
 * @isGen: true
 * @fileType: page
 * @zhName: 个人信息编辑页面
 * @component: OHPage,CommonHeader,PersonalInfoView
 */

@ComponentV2
export struct EditPersonalCenter {
  @Local userInfo: UserInfo = PersistenceV2.connect(UserInfo, () => new UserInfo())!;
  @Local avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    value: this.userInfo.avatarUrl || $r('app.media.avatar_avatar_12'),
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.userInfo.avatarUrl = param as ResourceStr;
    },
  });
  @Local nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '姓名',
    value: this.userInfo.nickName,
    minLength: 2,
    maxLength: 10,
    placeholderText: '姓名',
    invocation: (_param: Object) => {
      return Promise.resolve();
    },
    validMessageText: '内容为空，请输入后保存',
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
  @Local birthItem: ObservedInfoItem = new ObservedInfoItem({
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
  @Local phoneItem: ObservedInfoItem = new ObservedInfoItem({
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
    validMessageText: '内容为空，请输入后保存',
    onChange: (param?: Object) => {
      this.userInfo.email = param as string
    },
  })
  @Local introItem: ObservedInfoItem = new ObservedInfoItem({
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
  @Local list: FormGroup[] = [
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
  vm: EditPersonalVM = new EditPersonalVM();

  build() {
    OHPage({
      childBuilder: () => {
        this.render();
      },
      isFullScreen: true,
      useSafePadding: true,
      pageBackgroundColor: $r('sys.color.background_secondary')
    })
  }

  // 页面内容渲染
  @Builder
  render() {
    Column() {
      CommonHeader({
        title: '个人信息',
        onReturnClick: () => {
          phoneRouterControl.popPage();
        },
      })
      Column() {
        PersonalInfoView({
          list: this.vm.list,
          themeColor: $r('sys.color.multi_color_07'),
        })
      }
      .width('100%')
      .height('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .justifyContent(FlexAlign.Start)
    .width('100%')
    .height('100%')
    .backgroundColor($r('sys.color.background_secondary'))
  }
}

