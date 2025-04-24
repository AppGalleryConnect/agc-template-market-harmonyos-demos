import { Type } from '@kit.ArkUI';

@ObservedV2
export class User {
  @Trace public unionID: string = '';
  @Trace public openID: string = '';
  @Trace public avatar: string = '';
  @Trace public nickname: string = '';
  @Trace public phone: string = '';
  @Trace public isLogin: boolean = false;
}

@ObservedV2
export class UserInfo {
  @Type(User)
  @Trace users: Map<string, User> = new Map()
  @Trace isLogin: boolean = false;
  @Trace unionID: string = '';
  @Trace nickname: string = '';
  @Trace avatar: string = '';
}

