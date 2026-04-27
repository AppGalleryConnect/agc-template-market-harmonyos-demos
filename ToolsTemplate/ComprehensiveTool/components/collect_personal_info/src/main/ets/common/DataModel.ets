import { ISelectOption } from './FormModel';

// 支持的信息类型枚举
export enum DataType {
  AVATAR = 'avatar',
  NICK_NAME = 'nickName',
  FULL_NAME = 'fullName',
  GENDER = 'gender',
  BIRTH_DATE = 'birthDate',
  PHONE_NUMBER = 'phoneNumber',
  INTRO_DESC = 'introDesc',
}

// 性别枚举
export enum GenderType {
  MALE = 0,
  FEMALE = 1,
  CONFIDENTIALITY = 2,
}

// 开关模型
export interface SwitchInfo {
  showAvatar?: boolean;
  showNickName?: boolean;
  showFullName?: boolean;
  showGender?: boolean;
  showBirthDate?: boolean;
  showPhoneNumber?: boolean;
  showIntroDesc?: boolean;
}

// 个人数据模型
export interface PersonalInfo {
  avatar?: ResourceStr;
  nickName?: ResourceStr;
  fullName?: ResourceStr;
  gender?: GenderType;
  birthDate?: Date;
  phoneNumber?: string;
  introDesc?: ResourceStr;
}

// 性别模型
export interface GenderOption extends ISelectOption {
  id: number | string;
  label: ResourceStr;
  value: GenderType;
}

// 云侧接口调用模型
export interface ApiHandler {
  updateAvatar?: (param: Object) => Promise<void>;
  updateNickName?: (param: Object) => Promise<void>;
  updateGender?: (param: Object) => Promise<void>;
  updateBirth?: (param: Object) => Promise<void>;
  updateFullName?: (param: Object) => Promise<void>;
  updateIntro?: (param: Object) => Promise<void>;
  updatePhoneInfo?: PhoneApiInfo;
}

// 手机号码接口调用模型
export interface PhoneApiInfo {
  codeLength?: number;
  sendCode: (phone: string) => Promise<void>;
  verifyCode: (phone: string, code: string) => Promise<void>;
}
