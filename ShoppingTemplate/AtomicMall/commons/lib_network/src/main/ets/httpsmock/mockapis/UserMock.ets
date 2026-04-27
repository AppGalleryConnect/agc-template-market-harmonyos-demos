import { PersistenceV2 } from '@kit.ArkUI';
import axios, { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import dayjs from 'dayjs';
import { iData } from 'lib_foundation';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { UpdateUserInfoReq, UserLoginReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  MembershipInfo, MembershipInfoResp,
} from '../../types/responses/UserResponse';
import { MockImageData, MockImageMap } from '../mockdata/MockImageMap';

@ObservedV2
export class MembershipInfoModel implements MembershipInfo {
  startDate: string = '';
  expireDate: string = '';
  isSubscribed: boolean = false;
}


export class UserMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 用户登录
    adapter.onGet(RequestUrlMap.USER_LOGIN).reply(async (config: AxiosRequestConfig) => {
      iData.global.userInfo.reset();
      const params = config.params as UserLoginReq;
      const userInfo = await getPhoneNumber(params?.authorizationCode);
      iData.global.userInfo.nickname = '华为用户';
      const phone = userInfo?.mobileNumber ?? '12345678900';
      iData.global.userInfo.phone = phone;
      iData.global.userInfo.anonymousPhone = phone.slice(0, 3) + '****' + phone.slice(7);
      iData.global.userInfo.avatar = MockImageData.getImageResource(MockImageMap.DEFAULT_AVATAR);
      iData.global.isLogin = true;
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });
    // 用户登出
    adapter.onGet(RequestUrlMap.USER_LOGOUT).reply(() => {
      iData.global.userInfo.reset();
      iData.global.isLogin = false;
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });
    // 更新用户信息
    adapter.onPut(RequestUrlMap.USER_INFO).reply((config: AxiosRequestConfig) => {
      const data = JSON.parse(config.data) as UpdateUserInfoReq;
      switch (data.type) {
        case 'avatar':
          iData.global.userInfo.avatar = data.value;
          break;
        case 'nickname':
          iData.global.userInfo.nickname = data.value;
          break;
        case 'phone':
          iData.global.userInfo.phone = data.value;
          if (data.value.length === 11) {
            iData.global.userInfo.anonymousPhone = data.value.slice(0, 3) + '****' + data.value.slice(7);
          }
          break;
        default:
          break;
      }
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 开通/续费年卡会员
    adapter.onPost(RequestUrlMap.USER_MEMBERSHIP).reply(() => {
      const infoModel = PersistenceV2.connect(
        MembershipInfoModel,
        'membershipInfo',
        () => new MembershipInfoModel())!;
      if (!infoModel.isSubscribed || (infoModel.isSubscribed && !infoModel.startDate)) {
        infoModel.isSubscribed = true;
        const curDate = dayjs();
        infoModel.startDate = dayjs(curDate).format('YYYY-MM-DD');
        infoModel.expireDate = dayjs(curDate).set('year', curDate.year() + 1).format('YYYY-MM-DD');
      } else {
        const curDate: dayjs.Dayjs = dayjs(infoModel.expireDate);
        infoModel.expireDate =
          dayjs(new Date(infoModel.expireDate)).set('year', curDate.year() + 1).format('YYYY-MM-DD');
      }
      const res: BaseResponse = {
        code: 0,
      };
      return [HttpStatusCode.Ok, res];
    });

    // 查询会员信息
    adapter.onGet(RequestUrlMap.USER_MEMBERSHIP).reply(() => {
      const infoModel = PersistenceV2.connect(
        MembershipInfoModel,
        'membershipInfo',
        () => new MembershipInfoModel())!;
      if (iData.global.userInfo.isMember && !infoModel.isSubscribed) {
        infoModel.isSubscribed = true;
        const curDate = dayjs();
        infoModel.startDate = dayjs(curDate).format('YYYY-MM-DD');
        infoModel.expireDate = dayjs(curDate).set('year', curDate.year() + 1).format('YYYY-MM-DD');
      }
      const res: MembershipInfoResp = {
        code: 0,
        data: {
          isSubscribed: infoModel.isSubscribed,
          startDate: infoModel.startDate,
          expireDate: infoModel.expireDate,
        },
      };
      return [HttpStatusCode.Ok, res];
    });
  }
}


interface AuthLoginReq {
  grant_type: string,

  // todo: client_id和client_secret配置，用于获取真实手机号，使用前需参考README申请scope权限
  client_id: string, //填写应用OAuth 2.0客户端ID（凭据）的clientId
  client_secret: string, //填写应用OAuth 2.0客户端ID（凭据）的client Secret
  code: string,
}

interface AuthLoginResp {
  data: BindPhoneReq
}

interface BindPhoneReq {
  access_token: string,
  getNickName: number,
}

interface BindPhoneResp {
  data: UserInfoData
}

interface UserInfoData {
  mobileNumber: string,
  openID: string,
  phoneCountryCode: string,
  purePhoneNumber: string,
  unionID: string
}

async function getPhoneNumber(authorizationCode?: string): Promise<UserInfoData | undefined> {
  if (!authorizationCode) {
    return undefined;
  }
  let data: AuthLoginReq = {
    grant_type: 'authorization_code',
    // todo: client_id和client_secret配置，用于获取真实手机号，使用前需参考README申请scope权限
    client_id: 'xxx', //填写应用OAuth 2.0客户端ID（凭据）的clientId
    client_secret: 'xxx', //填写应用OAuth 2.0客户端ID（凭据）的client Secret
    code: authorizationCode,
  };
  try {
    const response: AuthLoginResp = await axios.post('https://oauth-login.cloud.huawei.com/oauth2/v3/token', data, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });
    const userInfoData: BindPhoneReq = {
      access_token: response.data.access_token,
      getNickName: 1,
    };
    // 拿到access_token之后获取手机号等信息
    const userInfo: BindPhoneResp = await axios.post(
      'https://account.cloud.huawei.com/rest.php?nsp_svc=GOpen.User.getInfo',
      userInfoData,
      {
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      },
    );
    return Promise.resolve(userInfo.data);
  } catch (error) {
    return Promise.reject(error);
  }
}