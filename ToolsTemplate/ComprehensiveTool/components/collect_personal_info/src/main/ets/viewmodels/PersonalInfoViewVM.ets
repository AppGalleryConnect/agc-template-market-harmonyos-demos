import { AppStorageV2 } from '@kit.ArkUI';
import { ConfigInfo } from '../common/ConfigModel';
import { GENDER_OPTIONS } from '../common/Constant';
import { PersonalInfo, DataType, SwitchInfo, ApiHandler, GenderType } from '../common/DataModel';
import { FormType, ObservedInfoItem } from '../common/FormModel';
import { WindowModel } from '../common/WindowModel';

@ObservedV2
export class PersonalInfoViewVM {
  @Trace switchInfo: SwitchInfo = {}
  @Trace personalData: PersonalInfo = {};
  @Trace apiInfo: ApiHandler = {}
  @Trace onChange: (type: DataType, data: PersonalInfo) => void = () => {
  };
  @Trace configInfo: ConfigInfo = AppStorageV2.connect(ConfigInfo, () => new ConfigInfo())!;
  @Trace windowModel: WindowModel = AppStorageV2.connect(WindowModel, () => new WindowModel())!;
  @Trace avatarItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.CHOOSE_AVATAR,
    label: '头像',
    onChange: (param?: Object) => {
      this.avatarItem.value = param as string;
      this.personalData.avatar = param as string;
      this.onChange(DataType.AVATAR, this.personalData);
    },
  })
  @Trace nickNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '昵称',
    minLength: 2,
    maxLength: 10,
    placeholderText: '昵称',
    validMessageText: '昵称不能为空',
    onChange: (param?: Object) => {
      this.nickNameItem.value = param as string;
      this.personalData.nickName = param as string;
      this.onChange(DataType.NICK_NAME, this.personalData);
    },
  })
  @Trace fullNameItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXT_INPUT,
    label: '姓名',
    minLength: 2,
    maxLength: 10,
    placeholderText: '姓名',
    validMessageText: '姓名不能为空',
    onChange: (param?: Object) => {
      this.fullNameItem.value = param as string;
      this.personalData.fullName = param as string;
      this.onChange(DataType.FULL_NAME, this.personalData);
    },
  })
  @Trace genderItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DROP_SELECT,
    label: '性别',
    selectOptions: GENDER_OPTIONS,
    onChange: (param?: Object) => {
      const tempGenderValue = param as GenderType;
      this.genderItem.value = tempGenderValue;
      this.personalData.gender = tempGenderValue;
      this.onChange(DataType.GENDER, this.personalData);
    },
  });
  @Trace birthItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.DATE_SELECT,
    label: '出生日期',
    sheetTitle: '出生日期',
    sheetOptions: {
      height: 500,
    },
    onChange: (param?: Object) => {
      this.birthItem.value = param as Date;
      this.personalData.birthDate = param as Date;
      this.onChange(DataType.BIRTH_DATE, this.personalData);
    },
  });
  @Trace phoneItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.PHONE_INPUT,
    label: '手机号',
    maxLength: 11,
    validMessageText: '手机号码不能为空',
    onChange: (param?: Object) => {
      this.phoneItem.value = param as string;
      this.personalData.phoneNumber = param as string;
      this.onChange(DataType.PHONE_NUMBER, this.personalData);
    },
  })
  @Trace introItem: ObservedInfoItem = new ObservedInfoItem({
    type: FormType.TEXTAREA,
    maxLength: 70,
    label: '个人简介',
    placeholderText: '简单介绍一下自己吧~~',
    showValue: false,
    onChange: (param?: Object) => {
      this.introItem.value = param as string;
      this.personalData.introDesc = param as string;
      this.onChange(DataType.INTRO_DESC, this.personalData);
    },
  });
  @Trace list1: ObservedInfoItem[] = [];
  @Trace list2: ObservedInfoItem[] = [];
  @Trace list3: ObservedInfoItem[] = [];
  @Trace list4: ObservedInfoItem[] = [];

  assignSwitchInfo(data: SwitchInfo) {
    this.switchInfo.showAvatar = data.showAvatar ?? true;
    this.switchInfo.showNickName = data.showNickName ?? true;
    this.switchInfo.showFullName = data.showFullName ?? true;
    this.switchInfo.showGender = data.showGender ?? true;
    this.switchInfo.showBirthDate = data.showBirthDate ?? true;
    this.switchInfo.showPhoneNumber = data.showPhoneNumber ?? true;
    this.switchInfo.showIntroDesc = data.showIntroDesc ?? true;
  }

  assignPersonalInfo(data: PersonalInfo) {
    this.personalData.avatar = data.avatar ?? '';
    this.personalData.nickName = data.nickName ?? '';
    this.personalData.fullName = data.fullName ?? '';
    this.personalData.gender = data.gender ?? 0;
    this.personalData.birthDate = data.birthDate ?? new Date();
    this.personalData.phoneNumber = data.phoneNumber ?? '';
    this.personalData.introDesc = data.introDesc ?? '';
  }

  assignApiInfo(apiInfo: ApiHandler) {
    this.apiInfo.updateAvatar = apiInfo.updateAvatar ?? (() => new Promise((resolve) => resolve()));
    this.apiInfo.updateNickName = apiInfo.updateNickName ?? (() => new Promise((resolve) => resolve()));
    this.apiInfo.updateGender = apiInfo.updateGender ?? (() => new Promise((resolve) => resolve()));
    this.apiInfo.updateBirth = apiInfo.updateBirth ?? (() => new Promise((resolve) => resolve()));
    this.apiInfo.updateFullName = apiInfo.updateFullName ?? (() => new Promise((resolve) => resolve()));
    this.apiInfo.updatePhoneInfo = apiInfo.updatePhoneInfo ?? {
      codeLength: 6,
      sendCode: (phone: string) => {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            resolve()
          }, 100)
        })
      },
      verifyCode: (phone: string, code: string) => {
        return new Promise((resolve, reject) => {
          setTimeout(() => {
            resolve()
          }, 100)
        })
      },
    };
    this.apiInfo.updateIntro = apiInfo.updateIntro ?? (() => new Promise((resolve) => resolve()));
  }

  assignExtraInfo(themeColor: string | Resource, onChange: (type: DataType, data: PersonalInfo) => void) {
    this.configInfo.themeColor = themeColor;
    this.onChange = (type: DataType, data: PersonalInfo) => {
      onChange(type, data);
    };
  }

  collectList() {
    if (this.switchInfo.showAvatar) {
      this.avatarItem.value = this.personalData.avatar!;
      this.avatarItem.invocation = this.apiInfo.updateAvatar!;
      this.list1.push(this.avatarItem);
    }
    if (this.switchInfo.showNickName) {
      this.nickNameItem.value = this.personalData.nickName!;
      this.nickNameItem.invocation = this.apiInfo.updateNickName!;
      this.list2.push(this.nickNameItem);
    }
    if (this.switchInfo.showGender) {
      this.genderItem.value = this.personalData.gender!;
      this.genderItem.invocation = this.apiInfo.updateGender!;
      this.list2.push(this.genderItem);
    }
    if (this.switchInfo.showBirthDate) {
      this.birthItem.value = this.personalData.birthDate!;
      this.birthItem.invocation = this.apiInfo.updateBirth!;
      this.list2.push(this.birthItem);
    }
    if (this.switchInfo.showFullName) {
      this.fullNameItem.value = this.personalData.fullName!;
      this.fullNameItem.invocation = this.apiInfo.updateFullName!;
      this.list3.push(this.fullNameItem);
    }
    if (this.switchInfo.showPhoneNumber) {
      this.phoneItem.value = this.personalData.phoneNumber!;
      this.phoneItem.phoneInfo = this.apiInfo.updatePhoneInfo!;
      this.list3.push(this.phoneItem);
    }
    if (this.switchInfo.showIntroDesc) {
      this.introItem.value = this.personalData.introDesc!;
      this.introItem.invocation = this.apiInfo.updateIntro!;
      this.list4.push(this.introItem);
    }
  }
}