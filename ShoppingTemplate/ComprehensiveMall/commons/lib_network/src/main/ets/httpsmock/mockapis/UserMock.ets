import { PersistenceV2 } from '@kit.ArkUI';
import { AxiosRequestConfig, HttpStatusCode } from '@ohos/axios';
import dayjs from 'dayjs';
import { iData } from 'lib_foundation';
import AxiosMockAdapter from '@hw-agconnect/axios-mock-adapter';
import { RequestUrlMap } from '../../constants/RequestUrlMap';
import { UpdateUserInfoReq, UserLoginReq } from '../../types/RequestTypes';
import { BaseResponse } from '../../types/responses/BaseResponse';
import {
  MembershipInfo,
  MembershipInfoResp,
} from '../../types/responses/UserResponse';

@ObservedV2
export class MembershipInfoModel implements MembershipInfo {
  startDate: string = '';
  expireDate: string = '';
  isSubscribed: boolean = false;
}

export class UserMockApis {
  public start(adapter: AxiosMockAdapter) {
    // 用户登录
    adapter.onGet(RequestUrlMap.USER_LOGIN).reply((config: AxiosRequestConfig) => {
      const params = config.params as UserLoginReq;
      iData.global.isLogin = true;
      iData.global.userInfo.reset();
      iData.global.userInfo.nickname = '华为用户';
      const phone = params?.phoneNumbers ?? '12345678900';
      iData.global.userInfo.phone = phone;
      iData.global.userInfo.anonymousPhone = phone.slice(0, 3) + '****' + phone.slice(7);
      iData.global.userInfo.avatar = '';
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
