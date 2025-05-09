import axios from 'axios';

export interface ResponseUserInfo {
  loginMobileNumber: string
  userName: string
  avatar: string
}

export interface UserInfo {
  idToken: string
  authCode: string
  userName: string
  avatar: string
  phoneNumber: string
}

export async function getAccessToken(authorizationCode: string, logger): Promise<ResponseUserInfo> {
  /*
  :todo
  */
  let data = {
    grant_type: 'authorization_code',
    client_id: "xxxxx",
    client_secret: "xxxxx",
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
    // 拿到access_token之后获取手机号等信息
    const userInfo =
      await axios.post('https://account.cloud.huawei.com/rest.php?nsp_svc=GOpen.User.getInfo', userInfoData, {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        }
      });
    return Promise.resolve(userInfo.data)
  } catch (error) {
    logger.info(JSON.stringify(error))
    return Promise.reject(error)
  }
}
