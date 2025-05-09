import axios from 'axios';

export interface UserInfoRes {
  mobileNumber: string
  userName: string
  avatar: string,
  unionID: string
};
export async function getUserInfoByAccessToken(authorizationCode: string): Promise<UserInfoRes> {
  let data = {
    grant_type: 'authorization_code',
    // 应用OAuth 2.0客户端ID（凭据）的clientId
    client_id: "xxxx",
    // 应用OAuth 2.0客户端ID（凭据）的client Secret
    client_secret: "xxxxxx",
    code: authorizationCode
  }
  try {
    const response = await axios.post('https://oauth-login.cloud.huawei.com/oauth2/v3/token', data, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      }
    });
    const userInfoData = {
      access_token: response.data.access_token,
      getNickName: 1
    }
    // 拿到token后获取用户信息
    const userInfo =
      await axios.post('https://account.cloud.huawei.com/rest.php?nsp_svc=GOpen.User.getInfo', userInfoData, {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        }
      });
    return Promise.resolve(userInfo.data)
  } catch (error) {
    return Promise.reject(error)
  }
}
