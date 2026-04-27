import { MockAccountSingleModel } from '../model/MockAccountSingleModel';

// 泛型类型
export type TValueType = string | boolean | number | null | Array<TValueType> | Object | Object[] | (() => void)

export class Constants {
  public static readonly FULL_SIZE = '100%';
  public static readonly TAB_INDEX_ZERO: number = 0;
  public static readonly TAB_INDEX_ONE: number = 1;
  public static readonly TAB_INDEX_TWO: number = 2;
  public static readonly TAB_INDEX_THREE: number = 3;
  public static readonly onMessagePageShowChange: string = 'eventMessagePageShow'
  public static readonly onMessagePageHideChange: string = 'eventMessagePageHide'

  public static getMockNickName(userId: string) {
    const targetUser: MockAccountSingleModel | undefined = MOCK_ACCOUNT_LIST.find(user => user.userId === userId);
    if (targetUser !== undefined) {
      return targetUser.nickName;
    }
    return '';
  }

  public static getMockAvatar(userId: string) {
    const targetUser: MockAccountSingleModel | undefined = MOCK_ACCOUNT_LIST.find(user => user.userId === userId);
    if (targetUser !== undefined) {
      return targetUser.avatarUrl;
    }
    return '';
  }
}

export const MOCK_ACCOUNT_LIST: MockAccountSingleModel[] = [
  {
    userId: 'user_one',
    // todo： mock的用户昵称
    nickName: '',
    // todo： mock的用户手机号
    phone: '',
    avatarUrl: 'user_one_avatar',
    // todo： 需要使用${userId}在腾讯云控制台生成签名，具体见readme
    userSig: '',
    selfSignature : ''
  }
];
