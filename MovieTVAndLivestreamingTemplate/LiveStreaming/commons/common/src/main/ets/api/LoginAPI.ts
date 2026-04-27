export class UserInfo {
  id: string = ''
  name: string = ''
  image: string = ''
  phone: string = ''

  constructor(userInfo?: any) {
    this.id = userInfo?.id || '';
    this.name = userInfo?.name || '';
    this.image = userInfo?.image || '';
    this.phone = userInfo?.phone || '';
  }
}

export class LoginAPI {
  refreshToken: (force?: boolean) => Promise<boolean>;

  login: () => Promise<boolean>;

  checkLoginStatus: () => Promise<boolean>;

  logout: () => Promise<void>;

  getAccessToken: () => string | undefined;

  getUserInfo: () => UserInfo | undefined;
}