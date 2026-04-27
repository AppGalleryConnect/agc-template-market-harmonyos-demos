import { UserInfo } from 'types';

@ObservedV2
export class DialogParams {
  @Trace operation: string;
  @Trace content: string;

  constructor(operation: string, content: string) {
    this.operation = operation;
    this.content = content;
  }
}

export class NodeInfo {
  cloneName: string;
  userInfo: UserInfo;

  constructor(cloneName: string, userInfo: UserInfo) {
    this.cloneName = cloneName;
    this.userInfo = userInfo;
  }
}

export enum PersonInfoType {
  GENDER = '性别',
  BIRTHDAY = '生日'
}

export enum GenderType {
  MALE = 0,
  FEMALE = 1
}

export const personalInfoData: PersonInfoType[] =
  [PersonInfoType.GENDER, PersonInfoType.BIRTHDAY];

export const genderData: GenderType[] =
  [GenderType.MALE, GenderType.FEMALE];

